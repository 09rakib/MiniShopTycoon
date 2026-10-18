class_name ShopProgression
extends RefCounted
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/progression.json"))

func _init() -> void:
	assert(validate(config).is_empty(), validate(config))

static func validate(data: Dictionary) -> String:
	if not ProductCatalog.integer_in_range(data.get("xp_per_customer"), 1, 1000):
		return "Invalid customer XP."
	if not data.get("levels") is Array or data["levels"].is_empty() or data["levels"].size() > 100:
		return "Invalid level list."
	var previous: int = -1
	for level: Variant in data["levels"]:
		if not level is Dictionary or not ProductCatalog.integer_in_range(level.get("xp"), 0, 1000000000):
			return "Invalid level XP."
		if int(level["xp"]) <= previous or not level.get("name") is String:
			return "Level thresholds must increase."
		previous = int(level["xp"])
	if int(data["levels"][0]["xp"]) != 0 or not data.get("goals") is Array:
		return "Level 1 must start at zero XP."
	for goal: Variant in data["goals"]:
		if not goal is Dictionary or not goal.get("title") is String or not goal.get("metric") in ["stock_spending", "customers", "upgrades", "products", "level"] or not ProductCatalog.integer_in_range(goal.get("target"), 1, 1000000000):
			return "Invalid progression goal."
	return ""

func xp_for(customers: int) -> int:
	return customers * int(config["xp_per_customer"])

func level_for(customers: int) -> int:
	var result: int = 1
	var xp: int = xp_for(customers)
	for index: int in config["levels"].size():
		if xp >= int(config["levels"][index]["xp"]):
			result = index + 1
	return result

func level_name(level: int) -> String:
	return config["levels"][clampi(level - 1, 0, config["levels"].size() - 1)]["name"]

func xp_text(customers: int) -> String:
	var level: int = level_for(customers)
	if level == config["levels"].size():
		return "%d XP • Max level" % xp_for(customers)
	return "%d / %d XP" % [xp_for(customers), int(config["levels"][level]["xp"])]

func goal_rows(customers: int, spent: int, upgrades: int, products: int) -> Array[Dictionary]:
	var metrics: Dictionary = {"customers": customers, "stock_spending": spent,
		"upgrades": upgrades, "products": products, "level": level_for(customers)}
	var rows: Array[Dictionary] = []
	for goal: Dictionary in config["goals"]:
		var value: int = int(metrics[goal["metric"]])
		var target: int = int(goal["target"])
		rows.append({"title": goal["title"], "value": mini(value, target), "target": target, "complete": value >= target})
	return rows
