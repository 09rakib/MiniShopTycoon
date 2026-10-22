class_name ShopExpansion
extends RefCounted
## Additional machines reuse the same production and handling primitives.
var unlocked: bool = false
var furniture: bool = false
var spending: int = 0
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/expansion.json"))
var production: ProductionState = ProductionState.new("fries_press")
var handling: BurgerHandling = BurgerHandling.new("fries_machine", 4)

func _init() -> void:
	production.active = false

func reset() -> void:
	unlocked = false
	furniture = false
	spending = 0
	handling.reset()
	production.active = false
	production.stock = 0
	production.level = 1
	production.capacity_level = 1
	production.price_level = 1
	production.stock_changed.emit()

func seats() -> int:
	return int(config["seats"]) if furniture else 0

func snapshot() -> Dictionary:
	return {"unlocked": unlocked, "furniture": furniture, "spending": spending,
		"production": production.snapshot(), "handling": handling.snapshot()}

func restore(data: Dictionary) -> bool:
	if not data.get("unlocked") is bool or not data.get("furniture") is bool or not ProductCatalog.integer_in_range(data.get("spending"), 0, 1000000000000):
		return false
	if not data.get("production") is Dictionary or not data.get("handling") is Dictionary:
		return false
	var machine: ProductionState = ProductionState.new("fries_press")
	var inventory: BurgerHandling = BurgerHandling.new("fries_machine", 4)
	if not machine.restore(data["production"]) or not inventory.restore(data["handling"]):
		return false
	if machine.active != data["unlocked"] or (not data["unlocked"] and machine.stock + inventory.carried + inventory.counter > 0):
		return false
	unlocked = data["unlocked"]
	furniture = data["furniture"]
	spending = int(data["spending"])
	handling.restore(inventory.snapshot())
	production.restore(machine.snapshot())
	return true
