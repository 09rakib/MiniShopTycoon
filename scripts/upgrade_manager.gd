class_name ShelfUpgrades
extends RefCounted
var definitions: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/upgrades.json"))

func _init() -> void:
	assert(validate(definitions).is_empty(), validate(definitions))

static func validate(data: Array) -> String:
	if data.size() != 3:
		return "Define exactly three shelf groups."
	var ids: Array[String] = []
	var shelves: Array[int] = []
	for entry: Variant in data:
		if not entry is Dictionary:
			return "Invalid upgrade definition."
		if not entry.get("id") is String or String(entry["id"]).is_empty() or entry["id"] in ids or not entry.get("name") is String:
			return "Invalid upgrade ID/name."
		if not ProductCatalog.integer_in_range(entry.get("shelf"), 0, 2) or int(entry["shelf"]) in shelves:
			return "Invalid shelf group."
		if not ProductCatalog.integer_in_range(entry.get("base_cost"), 1, 1000000) or not ProductCatalog.integer_in_range(entry.get("capacity_per_level"), 1, 100):
			return "Invalid upgrade price or benefit."
		if not entry.get("requirements") is Array or entry["requirements"].is_empty() or entry["requirements"].size() > 8:
			return "Invalid upgrade steps."
		var previous: int = 1
		for requirement: Variant in entry["requirements"]:
			if not ProductCatalog.integer_in_range(requirement, previous, 100):
				return "Upgrade requirements must not decrease."
			previous = int(requirement)
		ids.append(entry["id"])
		shelves.append(int(entry["shelf"]))
	return ""

func find(id: String) -> Dictionary:
	for definition: Dictionary in definitions:
		if definition["id"] == id:
			return definition
	return {}

func cost(id: String, current: int) -> int:
	var definition: Dictionary = find(id)
	if definition.is_empty() or current < 0 or current >= definition["requirements"].size():
		return -1
	return int(definition["base_cost"]) * (1 << current)

func bonus(shelf: int, levels: Dictionary) -> int:
	for definition: Dictionary in definitions:
		if int(definition["shelf"]) == shelf:
			return int(levels.get(definition["id"], 0)) * int(definition["capacity_per_level"])
	return 0
