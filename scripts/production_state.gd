class_name ProductionState
extends RefCounted
signal stock_changed
## Persistent stock and independent speed/capacity/price upgrades.
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/machines.json"))
var stock: int = 0
var level: int = 1
var capacity_level: int = 1
var price_level: int = 1
var active: bool = true
var machine_id: String

func _init(id: String = "burger_press") -> void:
	machine_id = id
	assert(validate(config).is_empty(), validate(config))
	assert(not definition().is_empty(), "Unknown production machine.")

static func validate(data: Dictionary) -> String:
	var cadence: Variant = data.get("autosave_seconds")
	if not (cadence is int or cadence is float) or not is_finite(float(cadence)) or float(cadence) < 1.0:
		return "Invalid production autosave cadence."
	if not data.get("machines") is Array or data["machines"].is_empty():
		return "Missing production definitions."
	var ids: Array[String] = []
	for machine: Variant in data["machines"]:
		if not machine is Dictionary or not machine.get("id") is String or machine["id"] in ids:
			return "Invalid machine ID."
		ids.append(machine["id"])
		if not machine.get("product_id") is String or not ProductCatalog.integer_in_range(machine.get("selling_price"), 1, 1000000):
			return "Invalid machine product/price."
		if not machine.get("levels") is Array or machine["levels"].is_empty():
			return "Missing machine levels."
		var previous_capacity: int = 0
		for tier: Variant in machine["levels"]:
			if not tier is Dictionary or not ProductCatalog.integer_in_range(tier.get("capacity"), previous_capacity + 1, 1000) or not ProductCatalog.integer_in_range(tier.get("upgrade_cost"), 0, 1000000000):
				return "Invalid machine capacity/cost."
			var interval_value: Variant = tier.get("interval")
			if not (interval_value is int or interval_value is float) or not is_finite(float(interval_value)) or float(interval_value) < 0.1:
				return "Invalid production interval."
			previous_capacity = int(tier["capacity"])
		if not machine.get("capacity_upgrade_costs") is Array or machine["capacity_upgrade_costs"].size() != machine["levels"].size():
			return "Missing capacity costs."
		for cost: Variant in machine["capacity_upgrade_costs"]:
			if not ProductCatalog.integer_in_range(cost, 0, 1000000000):
				return "Invalid capacity cost."
		if not machine.get("price_levels") is Array or machine["price_levels"].is_empty():
			return "Missing price upgrades."
		var previous_price: int = 0
		for tier: Variant in machine["price_levels"]:
			if not tier is Dictionary or not ProductCatalog.integer_in_range(tier.get("price"), previous_price + 1, 1000000) or not ProductCatalog.integer_in_range(tier.get("upgrade_cost"), 0, 1000000000):
				return "Invalid price tier."
			previous_price = int(tier["price"])
	return ""

func reset() -> void:
	stock = 0
	level = 1
	capacity_level = 1
	price_level = 1
	active = true
	stock_changed.emit()

func definition() -> Dictionary:
	for machine: Dictionary in config["machines"]:
		if machine["id"] == machine_id:
			return machine
	return {}

func capacity() -> int:
	return int(definition()["levels"][capacity_level - 1]["capacity"])

func interval() -> float:
	return float(definition()["levels"][level - 1]["interval"])

func selling_price() -> int:
	return int(definition()["price_levels"][price_level - 1]["price"])

func upgrade_level(kind: String) -> int:
	return level if kind == "speed" else capacity_level if kind == "capacity" else price_level if kind == "price" else 0

func upgrade_cost(kind: String) -> int:
	var current: int = upgrade_level(kind)
	if current <= 0:
		return -1
	var tiers: Array = definition()["price_levels"] if kind == "price" else definition()["levels"]
	if current >= tiers.size():
		return -1
	return int(definition()["capacity_upgrade_costs"][current]) if kind == "capacity" else int(tiers[current]["upgrade_cost"])

func apply_upgrade(kind: String) -> void:
	if kind == "speed":
		level += 1
	elif kind == "capacity":
		capacity_level += 1
	elif kind == "price":
		price_level += 1

func can_produce() -> bool:
	return active and stock < capacity()

func produce_one() -> bool:
	if not can_produce():
		return false
	stock += 1
	stock_changed.emit()
	return true

func take(requested: int) -> int:
	# Shared bounded inventory primitive for future player/employee transfers.
	if requested <= 0:
		return 0
	var amount: int = mini(requested, stock)
	stock -= amount
	if amount > 0:
		stock_changed.emit()
	return amount

func snapshot() -> Dictionary:
	return {"id": definition()["id"], "stock": stock, "level": level, "capacity_level": capacity_level, "price_level": price_level, "active": active}

func restore(data: Dictionary) -> bool:
	if data.get("id") != definition()["id"] or not data.get("active") is bool:
		return false
	if not ProductCatalog.integer_in_range(data.get("level"), 1, definition()["levels"].size()):
		return false
	var loaded_level: int = int(data["level"])
	# Pre-G level represented the coupled speed/capacity tier; retain both.
	var loaded_capacity: Variant = data.get("capacity_level", loaded_level)
	var loaded_price: Variant = data.get("price_level", 1)
	if not ProductCatalog.integer_in_range(loaded_capacity, 1, definition()["levels"].size()) or not ProductCatalog.integer_in_range(loaded_price, 1, definition()["price_levels"].size()):
		return false
	var maximum: int = int(definition()["levels"][int(loaded_capacity) - 1]["capacity"])
	if not ProductCatalog.integer_in_range(data.get("stock"), 0, maximum):
		return false
	level = loaded_level
	capacity_level = int(loaded_capacity)
	price_level = int(loaded_price)
	stock = int(data["stock"])
	active = data["active"]
	stock_changed.emit()
	return true
