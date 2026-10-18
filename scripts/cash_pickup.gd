class_name CashPickup
extends RefCounted
## Uses the existing cash fixture's approach point, never a HUD coordinate.
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/cash_pickup.json"))
var point: Vector2 = Vector2.INF

func _init() -> void:
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_layout.json"))
	for fixture: Dictionary in layout["fixtures"]:
		if fixture["id"] == "cash_point":
			point = Vector2(fixture["hint_point"][0], fixture["hint_point"][1])
	assert(point.is_finite(), "Missing cash pickup point.")
	assert(float(config["interaction_radius"]) > 0 and float(config["interaction_radius"]) <= 60)

func is_near(worker_position: Vector2) -> bool:
	return worker_position.is_finite() and worker_position.distance_squared_to(point) <= pow(float(config["interaction_radius"]), 2)
