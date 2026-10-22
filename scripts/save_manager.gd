class_name LocalSave
extends RefCounted
## Validated local records, recovery candidates and explicit archived reset.
var directory: String
var blocked: bool = false
var message: String = ""

func _init(save_directory: String = "user://") -> void:
	directory = save_directory

func load_into(economy: ShopEconomy) -> void:
	blocked = false
	message = ""
	var found: bool = false
	for filename: String in ["progress.json", "progress.backup.json", "progress.tmp.json"]:
		var path: String = directory.path_join(filename)
		if not FileAccess.file_exists(path):
			continue
		found = true
		var data: Variant = _read_json(path)
		if data is Dictionary and (data.get("schema_version") is float or data.get("schema_version") is int):
			if float(data["schema_version"]) > 8:
				blocked = true
				message = "This save needs a newer game version. Original files are preserved."
				return
		if data is Dictionary and economy.restore(data):
			message = "Recovered a valid local save." if filename != "progress.json" else ""
			return
	if found:
		blocked = true
		message = "Save could not be read. Original files are preserved. Restart progress only if you want to replace them."

func write(economy: ShopEconomy) -> bool:
	if blocked:
		return false
	if not DirAccess.dir_exists_absolute(directory):
		message = "Cannot save progress. Check free storage."
		return false
	var target: String = directory.path_join("progress.json")
	var temporary: String = directory.path_join("progress.tmp.json")
	var backup: String = directory.path_join("progress.backup.json")
	var file: FileAccess = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		message = "Cannot save progress. Check free storage."
		return false
	file.store_string(JSON.stringify(economy.snapshot()))
	file.flush()
	var result: Error = file.get_error()
	file.close()
	if result != OK:
		message = "Could not finish saving. Previous save preserved."
		return false
	# Copy only a validated primary to backup; never replace recovery data with corruption.
	if FileAccess.file_exists(target):
		var old: Variant = _read_json(target)
		var validator: ShopEconomy = ShopEconomy.new()
		if old is Dictionary and validator.restore(old):
			if DirAccess.copy_absolute(target, backup) != OK:
				message = "Could not back up progress. Previous save preserved."
				return false
	if DirAccess.rename_absolute(temporary, target) != OK:
		message = "Could not replace save. Recovery files preserved."
		return false
	message = ""
	return true

func reset_with(economy: ShopEconomy) -> bool:
	# Prepare replacement before touching either live state or recovery files.
	if not DirAccess.dir_exists_absolute(directory):
		message = "Restart failed. Existing save preserved."
		return false
	var fresh: ShopEconomy = ShopEconomy.new()
	var prepared: String = directory.path_join("progress.reset.json")
	var file: FileAccess = FileAccess.open(prepared, FileAccess.WRITE)
	if file == null:
		message = "Restart failed. Existing save preserved."
		return false
	file.store_string(JSON.stringify(fresh.snapshot()))
	file.flush()
	var result: Error = file.get_error()
	file.close()
	if result != OK:
		message = "Restart failed. Existing save preserved."
		return false
	for filename: String in ["progress.json", "progress.backup.json", "progress.tmp.json"]:
		var path: String = directory.path_join(filename)
		if FileAccess.file_exists(path):
			var archive: String = path + ".before-reset"
			if DirAccess.dir_exists_absolute(archive):
				message = "Restart failed. Existing save preserved."
				return false
			if DirAccess.copy_absolute(path, archive) != OK:
				message = "Restart failed. Existing save preserved."
				return false
	if DirAccess.rename_absolute(prepared, directory.path_join("progress.json")) != OK:
		message = "Restart failed. Existing save preserved."
		return false
	for filename: String in ["progress.backup.json", "progress.tmp.json"]:
		var path: String = directory.path_join(filename)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	economy.reset()
	blocked = false
	message = ""
	return true

func _read_json(path: String) -> Variant:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return null
	return parser.data
