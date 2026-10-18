extends SceneTree
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _run() -> void:
	var state: ProductionState = ProductionState.new()
	check(ProductionState.validate(state.config).is_empty() and state.capacity() == 10 and is_equal_approx(state.interval(), 2.0), "Default machine is active with 10 capacity and 2-second production")
	for index: int in 10:
		state.produce_one()
	check(state.stock == 10 and not state.produce_one() and not state.can_produce(), "Production stops at exact capacity")
	var overproduced: bool = false
	for index: int in 10000:
		overproduced = overproduced or state.produce_one()
	check(not overproduced and state.stock == 10, "Ten thousand full-machine ticks cannot overproduce")
	check(state.take(2) == 2 and state.stock == 8 and state.can_produce(), "Removing stock frees capacity")
	check(state.take(0) == 0 and state.take(-2) == 0 and state.stock == 8, "Invalid removals preserve stock")
	check(state.take(9223372036854775807) == 8 and state.stock == 0 and state.take(1) == 0, "Bounded removal cannot create negative stock or overflow")
	state.active = false
	check(not state.produce_one() and state.stock == 0, "Inactive machine produces nothing")
	state.reset()
	for index: int in 5:
		state.produce_one()
	var restored: ProductionState = ProductionState.new()
	check(restored.restore(JSON.parse_string(JSON.stringify(state.snapshot()))) and restored.stock == 5, "Machine JSON round trip preserves stock")
	for value: Variant in [-1, 11, 0.5, "5"]:
		var invalid: Dictionary = state.snapshot()
		invalid["stock"] = value
		check(not restored.restore(invalid) and restored.stock == 5, "Reject invalid machine stock: " + str(value))
	var invalid: Dictionary = state.snapshot()
	invalid["level"] = 999
	check(not restored.restore(invalid), "Reject invalid machine upgrade level")
	invalid = state.snapshot()
	invalid["active"] = "true"
	check(not restored.restore(invalid), "Reject invalid active flag")
	invalid = state.snapshot()
	invalid["id"] = "unknown"
	check(not restored.restore(invalid), "Reject mismatched machine ID")
	var bad: Dictionary = state.config.duplicate(true)
	bad["machines"][0]["levels"][0]["interval"] = 0
	check(not ProductionState.validate(bad).is_empty(), "Reject zero production interval")
	bad = state.config.duplicate(true)
	bad["machines"].append(bad["machines"][0].duplicate(true))
	check(not ProductionState.validate(bad).is_empty(), "Reject duplicate machine IDs")
	var economy: ShopEconomy = ShopEconomy.new()
	economy.buy_upgrade("pantry")
	economy.buy("bread", 5)
	var legacy: Dictionary = economy.snapshot()
	legacy["schema_version"] = 3
	legacy.erase("production")
	var migrated: ShopEconomy = ShopEconomy.new()
	check(migrated.restore(JSON.parse_string(JSON.stringify(legacy))) and migrated.coins == 340 and migrated.stock["bread"] == 5 and migrated.capacity("bread") == 30 and migrated.production.stock == 0, "Phase B schema-3 migration preserves grocery progress and safely starts machine empty")
	migrated.production.produce_one()
	var current: Dictionary = migrated.snapshot()
	var loaded: ShopEconomy = ShopEconomy.new()
	check(current["schema_version"] == 5 and loaded.restore(JSON.parse_string(JSON.stringify(current))) and loaded.production.stock == 1, "Current schema preserves machine alongside existing economy")
	current["production"]["stock"] = 500
	check(not loaded.restore(current) and loaded.production.stock == 1 and loaded.coins == 340, "Malformed machine record rejects entire save without partial mutation")
	var folder: String = "user://production-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	game.storage = LocalSave.new(folder)
	var controller: Node = load("res://scripts/world/production_controller.gd").new()
	root.add_child(controller)
	check(not controller.cycle_timer.is_stopped() and is_equal_approx(controller.cycle_timer.wait_time, 2.0), "Production starts automatically with engine-native one-shot timer")
	await create_timer(1.0).timeout
	check(game.economy.production.stock == 0, "Machine does not produce before its interval")
	await create_timer(1.15).timeout
	check(game.economy.production.stock == 1 and game.production_dirty and game.economy.coins == 500 and game.economy.revenue == 0 and game.economy.customers == 0, "Real timer creates one burger without crediting wallet, sales or XP")
	for index: int in 9:
		game.economy.production.produce_one()
	check(game.economy.production.stock == 10 and controller.cycle_timer.is_stopped(), "Full machine stops its production timer")
	await create_timer(2.1).timeout
	check(game.economy.production.stock == 10 and controller.cycle_timer.is_stopped(), "Full machine stays idle beyond another interval")
	game.economy.production.take(1)
	check(game.economy.production.stock == 9 and not controller.cycle_timer.is_stopped(), "Stock removal automatically resumes production timer")
	await create_timer(2.15).timeout
	check(game.economy.production.stock == 10 and controller.cycle_timer.is_stopped(), "Resumed machine produces exactly one replacement and stops full")
	controller.set_paused(true)
	game.economy.production.take(2)
	await create_timer(2.1).timeout
	check(game.economy.production.stock == 8 and controller.cycle_timer.is_stopped(), "Paused machine neither produces nor catches up")
	controller._autosave()
	game.storage.load_into(loaded)
	check(loaded.production.stock == 8 and not game.production_dirty and loaded.coins == 500, "Batched save stores exact machine count and wallet")
	controller.set_paused(false)
	check(not controller.cycle_timer.is_stopped() and game.economy.production.stock == 8, "Resume starts a fresh interval without instant stock")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	game.storage.load_into(loaded)
	check(loaded.production.stock == 8, "Application pause flushes production progress to disk")
	game.restart()
	check(game.economy.production.stock == 0 and not controller.cycle_timer.is_stopped() and game.economy.coins == 500, "Confirmed progress reset empties machine and restarts production")
	controller.queue_free()
	await process_frame
	print("PRODUCTION RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
