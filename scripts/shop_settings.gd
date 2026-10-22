class_name ShopSettings
extends RefCounted
var enabled: bool = true
var directory: String

func _init(folder: String = "user://") -> void:
	directory = folder

func load_settings() -> bool:
	enabled = true
	var path: String = directory.path_join("preferences.cfg")
	if not FileAccess.file_exists(path):
		return true
	var config: ConfigFile = ConfigFile.new()
	if config.load(path) != OK:
		return false
	var value: Variant = config.get_value("audio", "enabled", true)
	if not value is bool:
		return false
	enabled = value
	return true

func save_enabled(value: bool) -> bool:
	if not DirAccess.dir_exists_absolute(directory):
		return false
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "enabled", value)
	var temporary: String = directory.path_join("preferences.tmp.cfg")
	if config.save(temporary) != OK or DirAccess.rename_absolute(temporary, directory.path_join("preferences.cfg")) != OK:
		return false
	enabled = value
	return true
