class_name ProductionController
extends Node
## One-shot engine timer. Full/inactive machines do not wake for production.
var state: ProductionState
var cycle_timer: Timer
var save_timer: Timer
var paused: bool = false

func _ready() -> void:
	if state == null:
		state = Game.economy.production
	cycle_timer = Timer.new()
	cycle_timer.one_shot = true
	cycle_timer.timeout.connect(_produce)
	add_child(cycle_timer)
	save_timer = Timer.new()
	save_timer.wait_time = float(state.config["autosave_seconds"])
	save_timer.timeout.connect(_autosave)
	add_child(save_timer)
	if state == Game.economy.production:
		save_timer.start()
	state.stock_changed.connect(_state_changed)
	Game.production_changed.connect(sync)
	Game.changed.connect(sync)
	Game.machine_upgraded.connect(_upgrade_cycle)
	sync()

func _upgrade_cycle(kind: String) -> void:
	# A bought speed tier starts a fresh cycle at the new interval; no free item.
	if kind == "speed" and state == Game.economy.production:
		cycle_timer.stop()
	sync()

func sync() -> void:
	if paused or not state.can_produce():
		cycle_timer.stop()
	elif cycle_timer.is_stopped():
		cycle_timer.start(state.interval())

func _produce() -> void:
	if paused:
		return
	state.produce_one()
	sync()

func _state_changed() -> void:
	Game.production_dirty = true
	Game.production_changed.emit()

func _autosave() -> void:
	if Game.production_dirty:
		Game.persist()

func set_paused(value: bool) -> void:
	paused = value
	sync()
