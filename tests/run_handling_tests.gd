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
	var handling: BurgerHandling = BurgerHandling.new()
	var machine: ProductionState = ProductionState.new()
	var pickup: Vector2 = handling.station_point("pickup")
	var delivery: Vector2 = handling.station_point("deliver")
	check(handling.carry_capacity() == 2 and handling.counter_capacity() == 8 and BurgerHandling.validate(handling.config).is_empty(), "Configured two-item carry limit and independent eight-item counter")
	for index: int in 10:
		machine.produce_one()
	var result: Dictionary = handling.transfer("pickup", Vector2.ZERO, machine)
	check(result["amount"] == 0 and handling.carried == 0 and machine.stock == 10, "Distant pickup rejected without changing inventory")
	check(handling.transfer("pickup", Vector2.INF, machine)["amount"] == 0 and handling.transfer("invalid", pickup, machine)["amount"] == 0, "Non-finite position and unknown action rejected")
	var observed: Array[int] = []
	var observer: Callable = func() -> void: observed.append(machine.stock + handling.carried + handling.counter)
	machine.stock_changed.connect(observer)
	result = handling.transfer("pickup", pickup, machine)
	check(result["amount"] == 2 and machine.stock == 8 and handling.carried == 2, "Pickup moves exactly two burgers from machine to worker")
	check(observed == [10], "Stock-changed observers see both sides of the same atomic transfer")
	machine.stock_changed.disconnect(observer)
	check(handling.transfer("pickup", pickup, machine)["amount"] == 0 and machine.stock == 8, "Repeated pickup with full hands cannot duplicate or discard stock")
	check(handling.transfer("deliver", pickup, machine)["amount"] == 0 and handling.carried == 2 and handling.counter == 0, "Distant counter delivery rejected without losing carried food")
	check(handling.transfer("deliver", delivery, machine)["amount"] == 2 and handling.carried == 0 and handling.counter == 2, "Delivery transfers carried burgers into counter")
	check(handling.transfer("deliver", delivery, machine)["amount"] == 0 and handling.counter == 2, "Repeated empty delivery cannot duplicate counter inventory")
	for trip: int in 3:
		handling.transfer("pickup", pickup, machine)
		handling.transfer("deliver", delivery, machine)
	handling.transfer("pickup", pickup, machine)
	check(handling.counter == 8 and handling.carried == 2 and machine.stock == 0, "Four full trips fill counter and next pickup respects carry capacity")
	check(handling.transfer("deliver", delivery, machine)["amount"] == 0 and handling.carried == 2 and handling.counter == 8, "Full counter rejects delivery while preserving hands")
	var conserved: bool = true
	for index: int in 10000:
		handling.transfer("deliver", delivery, machine)
		handling.transfer("pickup", pickup, machine)
		conserved = conserved and machine.stock + handling.carried + handling.counter == 10
	check(conserved, "Ten thousand repeated invalid transfers conserve every burger")
	handling.counter = 7
	check(handling.transfer("deliver", delivery, machine)["amount"] == 1 and handling.carried == 1 and handling.counter == 8, "Partial counter delivery keeps undeliverable burger in hand")
	handling.reset()
	machine.produce_one()
	check(handling.transfer("pickup", pickup, machine)["amount"] == 1 and handling.carried == 1 and machine.stock == 0, "Single available burger is picked up without inventing a second")
	var edge: Vector2 = pickup + Vector2(float(handling.config["interaction_radius"]), 0)
	check(handling.is_near("pickup", edge) and not handling.is_near("pickup", edge + Vector2(1, 0)), "Configured proximity boundary is enforced exactly")
	var restored: BurgerHandling = BurgerHandling.new()
	check(restored.restore(JSON.parse_string(JSON.stringify(handling.snapshot()))) and restored.carried == 1, "Carried/counter JSON round trip")
	for field: String in ["carried", "counter"]:
		for value: Variant in [-1, 1000, 0.5, "1"]:
			var invalid: Dictionary = handling.snapshot()
			invalid[field] = value
			check(not restored.restore(invalid) and restored.carried == 1, "Reject invalid handling field %s=%s without mutation" % [field, str(value)])
	var bad_config: Dictionary = handling.config.duplicate(true)
	bad_config["interaction_radius"] = 10000
	check(not BurgerHandling.validate(bad_config).is_empty(), "Reject unlimited interaction distance configuration")
	var economy: ShopEconomy = ShopEconomy.new()
	economy.buy_upgrade("pantry")
	economy.buy("bread", 5)
	for index: int in 5:
		economy.production.produce_one()
	var legacy: Dictionary = economy.snapshot()
	legacy["schema_version"] = 4
	legacy.erase("burger_handling")
	var loaded: ShopEconomy = ShopEconomy.new()
	check(loaded.restore(JSON.parse_string(JSON.stringify(legacy))) and loaded.coins == 340 and loaded.stock["bread"] == 5 and loaded.capacity("bread") == 30 and loaded.production.stock == 5 and loaded.handling.carried == 0 and loaded.handling.counter == 0, "Schema 4 migrates without losing money, upgrades or existing machine burgers")
	loaded.handling.transfer("pickup", pickup, loaded.production)
	loaded.handling.transfer("deliver", delivery, loaded.production)
	loaded.handling.transfer("pickup", pickup, loaded.production)
	var snapshot: Dictionary = loaded.snapshot()
	check(snapshot["schema_version"] == 8 and economy.restore(JSON.parse_string(JSON.stringify(snapshot))) and economy.production.stock == 1 and economy.handling.carried == 2 and economy.handling.counter == 2, "Schema 8 retains machine, carried and counter quantities together")
	var invalid_save: Dictionary = snapshot.duplicate(true)
	invalid_save["burger_handling"]["carried"] = 3
	invalid_save["coins"] = 1
	check(not economy.restore(invalid_save) and economy.coins == 340 and economy.handling.carried == 2 and economy.production.stock == 1, "Invalid carrying data cannot partially apply wallet or machine fields")
	var folder: String = "user://handling-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	game.storage = LocalSave.new(folder)
	var scene: Node2D = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	for index: int in 5:
		game.economy.production.produce_one()
	scene.world.player.position = pickup
	scene._update_location()
	check(scene.action_button.visible and not scene.action_button.disabled and scene.action_button.text == "Collect 2", "Nearby stocked machine shows contextual Collect button")
	scene.action_button.pressed.emit()
	check(game.economy.handling.carried == 2 and game.economy.production.stock == 3 and scene.world.player.carried_count == 2 and scene.carry_label.text.contains("Carry 2/2"), "Real button updates authoritative transfer, carried art and HUD")
	check(scene.action_button.disabled and scene.action_button.text == "Hands full", "Full hands disable further pickup")
	game.storage.load_into(loaded)
	check(loaded.handling.carried == 2 and loaded.production.stock == 3, "Pickup immediately saves both inventory sides")
	scene.world.player.position = delivery
	scene._update_location()
	check(scene.action_button.text == "Deliver 2" and not scene.action_button.disabled, "Counter proximity offers delivery")
	scene.action_button.pressed.emit()
	check(game.economy.handling.carried == 0 and game.economy.handling.counter == 2 and scene.world.player.carried_count == 0 and scene.carry_label.text.contains("Counter 2/8"), "Delivery button updates counter, hands and HUD")
	game.storage.load_into(loaded)
	check(loaded.handling.counter == 2 and loaded.handling.carried == 0 and loaded.production.stock == 3, "Counter delivery saves all burger inventories")
	check(game.economy.coins == 500 and game.economy.revenue == 0 and game.economy.customers == 0, "Handling never creates money, sales, customers or XP")
	scene.world.player.position = pickup
	scene._update_location()
	scene.world.player.position = Vector2(350, 800)
	scene.action_button.pressed.emit()
	check(game.economy.handling.carried == 0 and game.economy.production.stock == 3, "Stale prompt cannot collect after worker moves away")
	scene.world.player.position = pickup
	scene.open_menu()
	scene._interact()
	check(game.economy.handling.carried == 0 and not scene.action_button.visible, "Menu blocks burger actions and hides prompt")
	scene.close_menu()
	game.economy.handling.carried = 2
	game.economy.handling.counter = 7
	game.handling_changed.emit()
	scene.world.player.position = delivery
	scene._update_location()
	check(scene.action_button.text == "Deliver 1", "Partial space is accurately shown in action prompt")
	scene.action_button.pressed.emit()
	check(game.economy.handling.carried == 1 and game.economy.handling.counter == 8 and scene.action_button.disabled, "UI preserves leftover carried burger at full counter")
	game.storage.load_into(loaded)
	check(loaded.handling.carried == 1 and loaded.handling.counter == 8, "Leftover held burger survives save/load")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	game.storage.load_into(loaded)
	check(loaded.handling.carried == 1 and loaded.handling.counter == 8, "Pause flush retains carried burgers and full counter")
	game.restart()
	check(game.economy.handling.carried == 0 and game.economy.handling.counter == 0 and scene.world.player.carried_count == 0, "Confirmed reset clears handling state and visual stack")
	scene.production_controller.set_paused(false)
	for index: int in 10:
		game.economy.production.produce_one()
	scene.world.player.position = pickup
	scene._update_location()
	scene.action_button.pressed.emit()
	check(game.economy.production.stock == 8 and game.economy.handling.carried == 2 and not scene.production_controller.cycle_timer.is_stopped(), "Physical pickup from full machine immediately resumes actual production timer")
	scene.queue_free()
	await process_frame
	print("HANDLING RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
