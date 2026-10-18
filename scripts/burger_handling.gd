class_name BurgerHandling
extends RefCounted
## All machine → worker → counter transfers are synchronous and bounded.
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/burger_handling.json"))
var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_layout.json"))
var carried: int = 0
var counter: int = 0

func _init() -> void:
	assert(validate(config).is_empty(), validate(config))

static func validate(data: Dictionary) -> String:
	if not ProductCatalog.integer_in_range(data.get("carry_capacity"), 1, 8) or not ProductCatalog.integer_in_range(data.get("counter_capacity"), 1, 100):
		return "Invalid burger carrying/counter capacity."
	var radius: Variant = data.get("interaction_radius")
	if not (radius is int or radius is float) or not is_finite(float(radius)) or float(radius) < 20 or float(radius) > 100:
		return "Invalid burger interaction radius."
	return ""

func reset() -> void:
	carried = 0
	counter = 0

func carry_capacity() -> int:
	return int(config["carry_capacity"])

func counter_capacity() -> int:
	return int(config["counter_capacity"])

func station_point(action: String) -> Vector2:
	var id: String = "burger_machine" if action == "pickup" else "serving_counter" if action == "deliver" else ""
	for fixture: Dictionary in layout["fixtures"]:
		if fixture["id"] == id:
			return Vector2(fixture["hint_point"][0], fixture["hint_point"][1])
	return Vector2.INF

func is_near(action: String, position: Vector2) -> bool:
	return position.is_finite() and station_point(action).is_finite() and position.distance_squared_to(station_point(action)) <= pow(float(config["interaction_radius"]), 2)

func nearby_action(position: Vector2) -> String:
	for action: String in ["pickup", "deliver"]:
		if is_near(action, position):
			return action
	return ""

func available_amount(action: String, machine: ProductionState) -> int:
	if action == "pickup":
		return mini(machine.stock, carry_capacity() - carried)
	if action == "deliver":
		return mini(carried, counter_capacity() - counter)
	return 0

func transfer(action: String, position: Vector2, machine: ProductionState) -> Dictionary:
	if not action in ["pickup", "deliver"]:
		return {"amount": 0, "error": "Unknown burger interaction."}
	if not is_near(action, position):
		return {"amount": 0, "error": "Move closer to the machine." if action == "pickup" else "Move closer to the serving counter."}
	var amount: int = available_amount(action, machine)
	if amount <= 0:
		var message: String
		if action == "pickup":
			message = "Hands full — deliver your burgers." if carried >= carry_capacity() else "The machine is cooking. Wait for a burger."
		else:
			message = "Counter full — your burgers stay in your hands." if counter >= counter_capacity() else "Collect burgers from the machine first."
		return {"amount": 0, "error": message}
	if action == "pickup":
		# Credit the destination before take() emits stock_changed, so every
		# observer/save sees both sides of the same completed transfer.
		carried += amount
		machine.take(amount)
	else:
		carried -= amount
		counter += amount
	return {"amount": amount, "error": ""}

func snapshot() -> Dictionary:
	return {"carried": carried, "counter": counter}

func restore(data: Dictionary) -> bool:
	if not ProductCatalog.integer_in_range(data.get("carried"), 0, carry_capacity()) or not ProductCatalog.integer_in_range(data.get("counter"), 0, counter_capacity()):
		return false
	carried = int(data["carried"])
	counter = int(data["counter"])
	return true
