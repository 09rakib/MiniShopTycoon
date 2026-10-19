extends SceneTree
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(value: bool, description: String) -> void:
	checks += 1
	if value:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _run() -> void:
	var economy: ShopEconomy = ShopEconomy.new()
	for index: int in 10:
		economy.production.produce_one()
	check(economy.purchase_operation("speed").is_empty() and economy.coins == 320 and is_equal_approx(economy.production.interval(), 1.7) and economy.production.capacity() == 10 and economy.production.stock == 10, "Speed purchase costs 180, preserves stock and leaves capacity independent")
	check(economy.purchase_operation("capacity").is_empty() and economy.coins == 200 and economy.production.capacity() == 12 and economy.production.stock == 10 and is_equal_approx(economy.production.interval(), 1.7), "Capacity purchase costs 120, preserves full machine and frees space without changing speed")
	var ticket: int = economy.burger_sales.register_customer()
	economy.handling.counter = 1
	check(economy.burger_sales.purchase(ticket, economy.handling, economy.production) == 20, "Initial price creates exact original payment")
	economy.burger_sales.retire(ticket)
	check(economy.purchase_operation("price").is_empty() and economy.production.selling_price() == 25 and economy.coins == 60, "Independent price tier costs 140 wallet coins")
	ticket = economy.burger_sales.register_customer()
	economy.handling.counter = 1
	check(economy.burger_sales.purchase(ticket, economy.handling, economy.production) == 25 and economy.burger_sales.uncollected_cash == 45 and economy.burger_sales.revenue == 45, "New price affects next successful sale without repricing historical cash")
	economy.burger_sales.retire(ticket)
	check(not economy.purchase_operation("stocker").is_empty() and not economy.operations.hired and economy.coins == 60 and economy.operations.spending == 440, "Insufficient funds reject hiring and preserve expenses/wallet")
	economy.burger_sales.uncollected_cash = 10000
	economy.burger_sales.revenue = 10000
	economy.burger_sales.sold = 500
	check(not economy.purchase_operation("stocker").is_empty() and not economy.operations.hired, "Pending cash cannot buy an employee")
	economy.coins = 300
	check(economy.purchase_operation("stocker").is_empty() and economy.operations.hired and economy.coins == 0 and economy.operations.spending == 740, "Hire exactly one stocker with wallet funds")
	check(not economy.purchase_operation("stocker").is_empty() and economy.coins == 0, "Repeated hiring cannot charge again or create more staff")
	check(not economy.purchase_operation("unknown").is_empty(), "Unknown purchase rejected")
	economy.operations.spending = ShopEconomy.MAX_TOTAL
	economy.coins = 1000
	check(not economy.purchase_operation("speed").is_empty() and economy.coins == 1000 and economy.production.level == 2, "Expense ceiling blocks purchase before mutation")
	var maxed: ShopEconomy = ShopEconomy.new()
	maxed.coins = 20000
	for kind: String in ["speed", "capacity", "price"]:
		for tier: int in 4:
			check(maxed.purchase_operation(kind).is_empty(), "%s upgrade tier %d succeeds with sufficient wallet" % [kind, tier + 2])
		var before: int = maxed.coins
		check(not maxed.purchase_operation(kind).is_empty() and maxed.coins == before, "%s maximum cannot overcharge or overlevel" % kind)
	check(is_equal_approx(maxed.production.interval(), 0.9) and maxed.production.capacity() == 22 and maxed.production.selling_price() == 48, "Maximum actual speed/capacity/price match their configurations")
	var loaded: ShopEconomy = ShopEconomy.new()
	check(loaded.restore(JSON.parse_string(JSON.stringify(maxed.snapshot()))) and loaded.production.capacity() == 22 and loaded.production.selling_price() == 48 and loaded.operations.spending == maxed.operations.spending, "Schema 7 round trip retains independent upgrades and business spending")
	var legacy: Dictionary = maxed.snapshot()
	legacy["schema_version"] = 6
	legacy.erase("operations")
	legacy["production"].erase("capacity_level")
	legacy["production"].erase("price_level")
	check(loaded.restore(legacy) and loaded.production.level == 5 and loaded.production.capacity_level == 5 and loaded.production.stock == 0 and loaded.production.selling_price() == 20 and not loaded.operations.hired, "Pre-G coupled machine level migrates to matching speed/capacity, base price and no staff")
	var baseline: Dictionary = maxed.snapshot()
	for field: String in ["capacity_level", "price_level"]:
		for invalid_value: Variant in [-1, 999, 1.5, "2"]:
			var invalid: Dictionary = baseline.duplicate(true)
			invalid["production"][field] = invalid_value
			invalid["coins"] = 1
			check(not loaded.restore(invalid) and loaded.coins == maxed.coins, "Reject invalid %s=%s without partial wallet mutation" % [field, str(invalid_value)])
	for field: String in ["hired", "carried", "spending"]:
		var invalid: Dictionary = baseline.duplicate(true)
		invalid["operations"][field] = "invalid"
		check(not loaded.restore(invalid) and loaded.coins == maxed.coins, "Invalid employee %s cannot partially load" % field)
	var invalid: Dictionary = baseline.duplicate(true)
	invalid["operations"]["carried"] = 1
	check(not loaded.restore(invalid), "Unhired employee cannot own carried stock in save")
	invalid = baseline.duplicate(true)
	invalid["production"].erase("capacity_level")
	check(not loaded.restore(invalid), "Schema 7 cannot silently replace missing upgrade data with legacy defaults")
	var shared: ShopEconomy = ShopEconomy.new()
	var pickup: Vector2 = shared.handling.station_point("pickup")
	var delivery: Vector2 = shared.handling.station_point("deliver")
	shared.production.stock = 3
	check(shared.handling.transfer("pickup", pickup, shared.production, shared.operations)["amount"] == 0 and shared.production.stock == 3, "Unhired staff cannot transfer stock")
	shared.purchase_operation("stocker")
	check(shared.handling.transfer("pickup", Vector2.ZERO, shared.production, shared.operations)["amount"] == 0, "Employee shares player proximity validation")
	shared.handling.transfer("pickup", pickup, shared.production)
	check(shared.handling.transfer("pickup", pickup, shared.production, shared.operations)["amount"] == 1 and shared.handling.carried == 2 and shared.operations.carried == 1 and shared.production.stock == 0, "Player and stocker competing for three burgers conserve all food")
	shared.handling.counter = 8
	check(shared.handling.transfer("deliver", delivery, shared.production, shared.operations)["amount"] == 0 and shared.operations.carried == 1, "Full counter keeps employee's undeliverable burger")
	shared.handling.counter = 7
	shared.operations.carried = 2
	check(shared.handling.transfer("deliver", delivery, shared.production, shared.operations)["amount"] == 1 and shared.operations.carried == 1 and shared.handling.counter == 8, "Partial employee delivery uses same bounded transfer as player")
	var conserved: bool = true
	for index: int in 10000:
		shared.handling.transfer("deliver", delivery, shared.production, shared.operations)
		shared.handling.transfer("pickup", pickup, shared.production, shared.operations)
		conserved = conserved and shared.handling.counter + shared.operations.carried + shared.handling.carried + shared.production.stock == 11
	check(conserved and shared.operations.carried == 1, "Ten thousand rejected staff transfers cannot duplicate or destroy food")
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	var folder: String = "user://operations-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.customer_controller.set_paused(true)
	check(not is_instance_valid(scene.stocker_controller.worker), "No employee actor before hiring")
	game.economy.coins = 5000
	for index: int in 10:
		game.economy.production.produce_one()
	game.purchase_operation("capacity")
	check(game.economy.production.stock == 10 and not scene.production_controller.cycle_timer.is_stopped() and game.economy.production.capacity() == 12, "Capacity purchase restarts an actually full machine without deleting stock")
	game.purchase_operation("speed")
	check(is_equal_approx(scene.production_controller.cycle_timer.wait_time, 1.7) and game.economy.production.stock == 10, "Speed purchase resets actual timer at new interval without granting burger")
	await create_timer(1.8).timeout
	check(game.economy.production.stock == 11, "New interval produces exactly one real burger")
	scene.production_controller.set_paused(true)
	var coins_before: int = game.economy.coins
	game.storage.blocked = true
	game.storage.message = "Test disk failure."
	check(not game.purchase_operation("price") and game.economy.production.price_level == 1 and game.economy.coins == coins_before, "Failed upgrade save rolls back tier and wallet before publishing")
	check(not game.purchase_operation("stocker") and not game.economy.operations.hired and not is_instance_valid(scene.stocker_controller.worker), "Failed hire save rolls back and never spawns unpaid employee")
	game.storage.blocked = false
	scene.open_menu()
	scene._open_operations()
	scene.operations_panel.refresh()
	check(scene.operations_layer.visible and scene.world.player.controls_blocked and scene.operations_panel.buttons["price"].text.contains("20 coins") and scene.operations_panel.buttons["price"].text.contains("25"), "Workshop shows current/next price with player controls blocked")
	scene.operations_panel.buttons["price"].pressed.emit()
	check(game.economy.production.price_level == 2 and scene.operations_panel.buttons["price"].text.contains("30"), "Real workshop button buys price tier and refreshes next value")
	scene.operations_panel.buttons["stocker"].pressed.emit()
	check(game.economy.operations.hired and is_instance_valid(scene.stocker_controller.worker) and scene.stocker_controller.worker.staff_style and scene.operations_panel.buttons["stocker"].disabled, "Workshop hire spawns one visibly distinct bounded worker")
	game.storage.load_into(loaded)
	check(loaded.operations.hired and loaded.production.level == 2 and loaded.production.capacity_level == 2 and loaded.production.price_level == 2 and loaded.coins == game.economy.coins, "Purchases immediately persist wallet, all machine tiers and employee")
	scene.close_menu()
	var staff: Node = scene.stocker_controller
	staff.worker.speed = 900
	await create_timer(0.4).timeout
	check(game.economy.operations.carried == 2 and game.economy.production.stock == 9 and staff.worker.carried_count == 2 and game.economy.handling.counter == 0, "Visible stocker picks up two at machine but cannot teleport them to counter")
	game.storage.load_into(loaded)
	check(loaded.operations.carried == 2 and loaded.production.stock == 9, "Employee's in-transit burgers persist with matching machine deduction")
	staff.set_paused(true)
	var position_before: Vector2 = staff.worker.position
	await create_timer(0.12).timeout
	check(staff.worker.position == position_before and game.economy.operations.carried == 2, "Employee suspension freezes movement and retains carried food")
	game.economy.handling.counter = 7
	staff.set_paused(false)
	await create_timer(1.1).timeout
	check(game.economy.handling.counter == 8 and game.economy.operations.carried == 1 and staff.worker.position.distance_to(delivery) < 3, "Real worker follows aisle and partially delivers at counter")
	await create_timer(0.4).timeout
	check(game.economy.operations.carried == 1 and game.economy.handling.counter == 8, "Full-counter employee waits in place without food loss")
	var in_transit: Dictionary = game.economy.snapshot()
	ticket = game.economy.burger_sales.register_customer()
	check(game.sell_burger(ticket) and game.economy.burger_sales.uncollected_cash == 25, "Employee-stocked counter sells at upgraded current price without paying wallet")
	game.economy.burger_sales.retire(ticket)
	await create_timer(0.4).timeout
	check(game.economy.operations.carried == 0 and game.economy.handling.counter == 8, "Freed counter slot accepts employee's remaining burger exactly once")
	staff.set_paused(true)
	check(loaded.restore(in_transit) and loaded.operations.carried == 1, "Save restores held employee burger independently of player carry")
	scene.queue_free()
	await process_frame
	game.economy = loaded
	scene = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	scene.stocker_controller.set_paused(true)
	check(scene.stocker_controller.worker.carried_count == 1 and game.economy.handling.counter == 8 and game.economy.operations.hired, "Relaunch recreates one hired worker with saved in-transit stack, no duplication")
	game.restart()
	check(not game.economy.operations.hired and game.economy.operations.carried == 0 and not is_instance_valid(scene.stocker_controller.worker) and game.economy.production.capacity() == 10 and game.economy.production.selling_price() == 20, "Explicit reset clears employee, held food and independent machine upgrades")
	game.purchase_operation("stocker")
	game.purchase_operation("speed")
	scene.world.player.position = game.economy.cash_pickup.point
	scene.production_controller.set_paused(false)
	scene.customer_controller.set_paused(false)
	scene.stocker_controller.set_paused(false)
	await create_timer(10.5).timeout
	check(game.economy.burger_sales.sold >= 1 and game.economy.coins > 20 and game.economy.coins + game.economy.burger_sales.uncollected_cash == 20 + game.economy.burger_sales.revenue, "Real timed production → physical stocker → customer sale → proximity cash loop earns exact wallet proceeds")
	scene.queue_free()
	await process_frame
	print("OPERATIONS RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
