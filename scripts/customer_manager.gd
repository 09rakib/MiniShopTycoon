class_name ShopCustomers
extends Node
signal movement_changed
signal purchase(product_name: String, amount: int)

var slots: Array[Dictionary] = []
var spawn_clock: float = 1.5
var sequence: int = 0

func _ready() -> void:
	for index: int in int(Game.economy.catalog["max_customers"]):
		slots.append({"active": false, "progress": 0.0, "product": 0, "sold": false, "color": index})
	var tick: Timer = Timer.new()
	tick.wait_time = 0.05
	tick.timeout.connect(_tick)
	add_child(tick)
	tick.start()

func clear() -> void:
	for slot: Dictionary in slots:
		slot["active"] = false
	spawn_clock = 1.5
	movement_changed.emit()

func _tick() -> void:
	if not Game.running:
		return
	spawn_clock -= 0.05
	if spawn_clock <= 0.0:
		_spawn()
		spawn_clock = float(Game.economy.catalog["customer_interval"])
	var moved: bool = false
	for slot: Dictionary in slots:
		if not slot["active"]:
			continue
		moved = true
		slot["progress"] = float(slot["progress"]) + 0.05 / float(Game.economy.catalog["customer_duration"])
		if float(slot["progress"]) >= 0.72 and not slot["sold"]:
			slot["sold"] = true # Mark before emitting any transaction signals.
			var product: Dictionary = Game.economy.products[int(slot["product"])]
			if Game.sell(product["id"]):
				purchase.emit(product["name"], int(product["price"]))
		if float(slot["progress"]) >= 1.0:
			slot["active"] = false
	if moved:
		movement_changed.emit()

func _spawn() -> void:
	var available: Array[int] = []
	for index: int in Game.economy.products.size():
		if int(Game.economy.stock[Game.economy.products[index]["id"]]) > 0:
			available.append(index)
	if available.is_empty():
		return
	for slot: Dictionary in slots:
		if not slot["active"]:
			slot["active"] = true
			slot["progress"] = 0.0
			slot["sold"] = false
			slot["product"] = available[sequence % available.size()]
			sequence += 1
			return
