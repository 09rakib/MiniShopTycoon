class_name StockerController
extends Node
## One visible worker follows a clear fixed aisle; no inventory teleportation.
var actors: Node2D
var worker: WorkerCharacter
var route: Array[Vector2] = []
var waypoint: int = 0
var destination: String = ""
var paused: bool = false
var decision_timer: Timer

func _ready() -> void:
	decision_timer = Timer.new()
	decision_timer.wait_time = float(Game.economy.operations.config["decision_seconds"])
	decision_timer.timeout.connect(_decide)
	add_child(decision_timer)
	decision_timer.start()
	Game.changed.connect(sync)
	Game.handling_changed.connect(sync)
	sync()

func sync() -> void:
	if not Game.economy.operations.hired:
		if is_instance_valid(worker):
			worker.queue_free()
		worker = null
		route.clear()
		destination = ""
		return
	if not is_instance_valid(worker):
		worker = WorkerCharacter.new()
		worker.staff_style = true
		worker.speed = float(Game.economy.operations.config["speed"])
		var first: Array = Game.economy.operations.config["route"][0]
		worker.position = Vector2(first[0], first[1])
		actors.add_child(worker)
		worker.controls_blocked = paused
		_set_route("deliver" if Game.economy.operations.carried > 0 else "pickup")
	worker.set_carried_count(Game.economy.operations.carried)

func _set_route(action: String) -> void:
	destination = action
	route.clear()
	for values: Array in Game.economy.operations.config["route"]:
		route.append(Vector2(values[0], values[1]))
	if action == "pickup":
		route.reverse()
	# Already at the machine when hired/reloaded: do not walk the route backwards.
	if action == "pickup" and worker.position.distance_to(route.back()) < 3:
		route = [route.back()]
	waypoint = 0

func _physics_process(delta: float) -> void:
	if paused or not is_instance_valid(worker):
		return
	while waypoint < route.size() and worker.position.distance_to(route[waypoint]) < 2:
		waypoint += 1
	if waypoint >= route.size():
		worker.set_move_vector(Vector2.ZERO)
	else:
		worker.set_move_vector((route[waypoint] - worker.position).limit_length(worker.speed * delta) / (worker.speed * delta))

func _decide() -> void:
	if paused or not is_instance_valid(worker) or waypoint < route.size():
		return
	var held: int = Game.economy.operations.carried
	if held > 0:
		if destination != "deliver":
			_set_route("deliver")
		elif Game.economy.handling.is_near("deliver", worker.position):
			Game.stocker_transfer("deliver", worker.position)
			if Game.economy.operations.carried == 0:
				_set_route("pickup")
	else:
		if destination != "pickup":
			_set_route("pickup")
		elif Game.economy.handling.counter < Game.economy.handling.counter_capacity() and Game.economy.handling.is_near("pickup", worker.position):
			if Game.stocker_transfer("pickup", worker.position) > 0:
				_set_route("deliver")

func set_paused(value: bool) -> void:
	paused = value
	decision_timer.paused = value
	if is_instance_valid(worker):
		worker.controls_blocked = value
		if value:
			worker.stop()
