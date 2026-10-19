class_name ProductionController
extends Node
## One-shot engine timer. Full/inactive machines do not wake for production.
var cycle_timer: Timer
var save_timer: Timer
var paused: bool = false

func _ready() -> void:
	cycle_timer = Timer.new()
	cycle_timer.one_shot = true
	cycle_timer.timeout.connect(_produce)
	add_child(cycle_timer)
	save_timer = Timer.new()
	save_timer.wait_time = float(Game.economy.production.config["autosave_seconds"])
	save_timer.timeout.connect(_autosave)
	add_child(save_timer)
	save_timer.start()
	Game.economy.production.stock_changed.connect(_state_changed)
	Game.production_changed.connect(sync)
	Game.changed.connect(sync)
	Game.machine_upgraded.connect(_upgrade_cycle)
	sync()

func _upgrade_cycle(kind: String) -> void:
	# A bought speed tier starts a fresh cycle at the new interval; no free item.
	if kind == "speed":
		cycle_timer.stop()
	sync()

func sync() -> void:
	if paused or not Game.economy.production.can_produce():
		cycle_timer.stop()
	elif cycle_timer.is_stopped():
		cycle_timer.start(Game.economy.production.interval())

func _produce() -> void:
	if paused:
		return
	Game.economy.production.produce_one()
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
