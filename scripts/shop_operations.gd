class_name ShopOperations
extends RefCounted
## One useful employee first. Carried items remain durable during a trip.
var hired: bool = false
var carried: int = 0
var spending: int = 0
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/operations.json"))

func reset() -> void:
	hired = false
	carried = 0
	spending = 0

func snapshot() -> Dictionary:
	return {"hired": hired, "carried": carried, "spending": spending}

func restore(data: Dictionary) -> bool:
	var carrying: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/burger_handling.json"))
	if not data.get("hired") is bool or not ProductCatalog.integer_in_range(data.get("carried"), 0, int(carrying["carry_capacity"])) or not ProductCatalog.integer_in_range(data.get("spending"), 0, 1000000000000):
		return false
	if not data["hired"] and int(data["carried"]) != 0:
		return false
	hired = data["hired"]
	carried = int(data["carried"])
	spending = int(data["spending"])
	return true
