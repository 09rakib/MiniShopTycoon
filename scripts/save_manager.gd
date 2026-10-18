class_name LocalSave
extends RefCounted
## Minimal Phase 1 persistence. Expanded migrations/lifecycle tests belong to Phase 4.
var directory: String
var blocked: bool = false
var message: String = ""

func _init(save_directory: String = "user://") -> void:
	directory = save_directory

func load_into(economy: ShopEconomy) -> void:
	var found: bool = false
	for filename: String in ["progress.json", "progress.backup.json", "progress.tmp.json"]:
		var path: String = directory.path_join(filename)
		if not FileAccess.file_exists(path):
			continue
		found = true
		var data: Variant = _read_json(path)
		if data is Dictionary and economy.restore(data):
			message = "Recovered a valid local save." if filename != "progress.json" else ""
			return
	if found:
		blocked = true
		message = "Save could not be read. Original files are preserved. Restart progress only if you want to replace them."

func write(economy: ShopEconomy) -> bool:
	if blocked:
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
	# Keep the old files as a recovery archive even after explicit reset.
	for filename: String in ["progress.json", "progress.backup.json", "progress.tmp.json"]:
		var path: String = directory.path_join(filename)
		if FileAccess.file_exists(path):
			var archive: String = path + ".before-reset"
			if DirAccess.rename_absolute(path, archive) != OK:
				message = "Restart failed. Existing save preserved."
				return false
	blocked = false
	economy.reset()
	return write(economy)

func _read_json(path: String) -> Variant:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return null
	return parser.data
