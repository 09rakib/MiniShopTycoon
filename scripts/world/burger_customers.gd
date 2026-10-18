class_name BurgerCustomers
extends Node
## Bounded right-hand lane; only the queue head may start checkout.
var actors: Node2D
var visitors: Array[BurgerCustomer] = []
var queue: Array[BurgerCustomer] = []
var spawn_timer: Timer
var paused: bool = false
var config: Dictionary

func point(key: String) -> Vector2:
	return Vector2(config[key][0], config[key][1])

func _ready() -> void:
	config = Game.economy.burger_sales.config
	spawn_timer = Timer.new()
	spawn_timer.wait_time = float(config["spawn_seconds"])
	spawn_timer.timeout.connect(spawn_customer)
	add_child(spawn_timer)
	spawn_timer.start()
	Game.changed.connect(_sync_reset)

func spawn_customer() -> void:
	if paused:
		return
	var ticket: int = Game.economy.burger_sales.register_customer()
	if ticket == 0:
		return
	var visitor: BurgerCustomer = BurgerCustomer.new()
	visitor.ticket = ticket
	visitor.speed = float(config["speed"])
	visitor.position = point("entrance")
	actors.add_child(visitor)
	visitors.append(visitor)
	queue.append(visitor)
	_retarget()

func _retarget() -> void:
	for index: int in queue.size():
		var visitor: BurgerCustomer = queue[index]
		if visitor.state != BurgerCustomer.State.BUYING:
			visitor.target = point("queue_front") + Vector2(0, index * float(config["queue_spacing"]))

func _leave(visitor: BurgerCustomer) -> void:
	queue.erase(visitor)
	visitor.state = BurgerCustomer.State.LEAVING
	visitor.elapsed = 0
	visitor.route_elapsed = 0
	visitor.target = Vector2(float(config["exit_lane_x"]), visitor.position.y)
	visitor.queue_redraw()
	_retarget()

func _remove(visitor: BurgerCustomer) -> void:
	queue.erase(visitor)
	visitors.erase(visitor)
	Game.economy.burger_sales.retire(visitor.ticket)
	visitor.queue_free()
	_retarget()

func _physics_process(_delta: float) -> void:
	if paused:
		return
	for visitor: BurgerCustomer in visitors.duplicate():
		if visitor.route_elapsed > float(config["route_timeout"]):
			# A changed/blocked layout must never leak customers or generate a sale.
			_remove(visitor)
			continue
		match visitor.state:
			BurgerCustomer.State.ENTERING, BurgerCustomer.State.QUEUING:
				if visitor.at_target():
					visitor.state = BurgerCustomer.State.WAITING_FOR_STOCK
					visitor.elapsed = 0
					visitor.queue_redraw()
			BurgerCustomer.State.WAITING_FOR_STOCK:
				if visitor.elapsed >= float(config["wait_seconds"]):
					_leave(visitor)
				elif queue[0] == visitor and visitor.at_target() and Game.economy.handling.counter > 0:
					visitor.state = BurgerCustomer.State.BUYING
					visitor.target = point("checkout")
					visitor.elapsed = 0
					visitor.queue_redraw()
			BurgerCustomer.State.BUYING:
				if visitor.at_target() and visitor.elapsed >= float(config["service_seconds"]):
					visitor.paid = Game.sell_burger(visitor.ticket)
					if visitor.paid:
						_leave(visitor)
					else:
						visitor.state = BurgerCustomer.State.QUEUING
						visitor.elapsed = 0
						_retarget()
			BurgerCustomer.State.LEAVING:
				if visitor.at_target():
					if visitor.exit_stage == 0:
						visitor.exit_stage = 1
						visitor.target = Vector2(float(config["exit_lane_x"]), point("entrance").y)
					else:
						_remove(visitor)

func _sync_reset() -> void:
	for visitor: BurgerCustomer in visitors.duplicate():
		if not Game.economy.burger_sales.tickets.has(visitor.ticket):
			_remove(visitor)

func set_paused(value: bool) -> void:
	paused = value
	for visitor: BurgerCustomer in visitors:
		visitor.paused = value
	spawn_timer.paused = value

func _exit_tree() -> void:
	for visitor: BurgerCustomer in visitors:
		Game.economy.burger_sales.retire(visitor.ticket)
