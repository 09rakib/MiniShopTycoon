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
	var sales: BurgerSales = economy.burger_sales
	var first: int = sales.register_customer()
	check(sales.purchase(first, economy.handling, economy.production) == 0 and sales.revenue == 0, "Empty counter produces no transaction or money")
	economy.production.stock = 10
	economy.handling.carried = 2
	check(sales.purchase(first, economy.handling, economy.production) == 0, "Customers cannot buy machine or carried stock")
	economy.handling.counter = 1
	check(sales.purchase(-1, economy.handling, economy.production) == 0, "Unregistered customer cannot buy")
	check(sales.purchase(first, economy.handling, economy.production) == 20 and economy.handling.counter == 0 and sales.uncollected_cash == 20 and sales.sold == 1, "One successful purchase consumes one burger for exact configured payment")
	check(economy.coins == 500 and economy.revenue == 0 and economy.customers == 0, "Pending burger proceeds stay separate from wallet and grocery statistics")
	economy.handling.counter = 8
	var safe: bool = true
	for index: int in 10000:
		safe = safe and sales.purchase(first, economy.handling, economy.production) == 0
	check(safe and economy.handling.counter == 8 and sales.uncollected_cash == 20, "Ten thousand repeated purchase attempts cannot charge twice")
	var second: int = sales.register_customer()
	var third: int = sales.register_customer()
	var fourth: int = sales.register_customer()
	check(sales.register_customer() == 0, "Active customer tickets bounded to four including leaving customers")
	economy.handling.counter = 1
	check(sales.purchase(second, economy.handling, economy.production) == 20 and sales.purchase(third, economy.handling, economy.production) == 0 and sales.sold == 2, "Two customers competing for last burger produce exactly one sale")
	sales.retire(fourth)
	var replacement: int = sales.register_customer()
	check(replacement > fourth and sales.purchase(fourth, economy.handling, economy.production) == 0, "Retired tickets never become valid again")
	var snapshot: Dictionary = economy.snapshot()
	var loaded: ShopEconomy = ShopEconomy.new()
	check(loaded.restore(JSON.parse_string(JSON.stringify(snapshot))) and loaded.burger_sales.uncollected_cash == 40 and loaded.burger_sales.sold == 2 and loaded.coins == 500, "Schema 6 saves counter cash and sales independently from wallet")
	check(loaded.burger_sales.tickets.is_empty(), "Restart recreates visitors without replaying committed transactions")
	for field: String in ["uncollected_cash", "sold", "revenue"]:
		for bad: Variant in [-1, 0.5, "20", 1000000000001]:
			var invalid: Dictionary = snapshot.duplicate(true)
			invalid["burger_sales"][field] = bad
			invalid["coins"] = 1
			check(not loaded.restore(invalid) and loaded.coins == 500 and loaded.burger_sales.uncollected_cash == 40, "Invalid %s=%s cannot partially overwrite save" % [field, str(bad)])
	var invalid: Dictionary = snapshot.duplicate(true)
	invalid["burger_sales"]["uncollected_cash"] = 100
	check(not loaded.restore(invalid), "Pending cash cannot exceed all-time burger revenue")
	var legacy: Dictionary = snapshot.duplicate(true)
	legacy["schema_version"] = 5
	legacy.erase("burger_sales")
	check(loaded.restore(legacy) and loaded.production.stock == 10 and loaded.handling.carried == 2 and loaded.burger_sales.sold == 0, "Phase D migration retains previous inventory and initializes sales safely")
	sales.uncollected_cash = BurgerSales.LIMIT
	economy.handling.counter = 1
	check(sales.purchase(third, economy.handling, economy.production) == 0 and economy.handling.counter == 1 and not sales.tickets[third], "Cash overflow blocks transaction without consuming stock or ticket")
	var stress: ShopEconomy = ShopEconomy.new()
	var conserved: bool = true
	for index: int in 10000:
		stress.production.produce_one()
		stress.handling.transfer("pickup", stress.handling.station_point("pickup"), stress.production)
		stress.handling.transfer("deliver", stress.handling.station_point("deliver"), stress.production)
		var ticket: int = stress.burger_sales.register_customer()
		conserved = conserved and stress.burger_sales.purchase(ticket, stress.handling, stress.production) == 20
		stress.burger_sales.retire(ticket)
	check(conserved and stress.burger_sales.sold == 10000 and stress.burger_sales.uncollected_cash == 200000 and stress.coins == 500 and stress.production.stock + stress.handling.carried + stress.handling.counter == 0 and stress.burger_sales.tickets.is_empty(), "Ten thousand complete production-to-sale cycles conserve food and cash with bounded ticket memory")
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	var folder: String = "user://customer-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	var scene: Node2D = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	var controller: Node = scene.customer_controller
	controller.spawn_timer.stop()
	for index: int in 6:
		controller.spawn_customer()
	check(controller.visitors.size() == 4 and controller.queue.size() == 4, "Real world spawn limit enforced")
	# Move the real physics bodies quickly along the configured lane, maintaining spacing.
	for visitor: BurgerCustomer in controller.visitors:
		visitor.speed = 1400
	for frame: int in 55:
		await physics_frame
	check(controller.visitors[0].state == BurgerCustomer.State.WAITING_FOR_STOCK and game.economy.burger_sales.sold == 0, "Real customers arrive and wait without phantom sales")
	var separated: bool = true
	for index: int in range(1, controller.queue.size()):
		separated = separated and controller.queue[index].position.distance_to(controller.queue[index - 1].position) > 40
	check(separated, "Settled queue maintains personal space")
	controller.set_paused(true)
	var waiting_time: float = controller.visitors[0].elapsed
	for frame: int in 5:
		await physics_frame
	check(controller.visitors[0].elapsed == waiting_time and controller.spawn_timer.paused, "Suspension freezes visitor movement, patience and spawning")
	controller.set_paused(false)
	game.economy.handling.counter = 1
	game.handling_changed.emit()
	for frame: int in 100:
		await physics_frame
	check(game.economy.burger_sales.sold == 1 and game.economy.burger_sales.uncollected_cash == 20 and game.economy.handling.counter == 0 and game.economy.coins == 500, "Real queue head walks to checkout, buys exactly once and leaves money uncollected")
	game.storage.load_into(loaded)
	check(loaded.burger_sales.uncollected_cash == 20 and loaded.burger_sales.sold == 1 and loaded.handling.counter == 0, "Successful real checkout immediately persists stock deduction and cash together")
	check(scene.cash_label.text.contains("20") and scene.carry_label.text.contains("Counter 0/8"), "Sale refreshes counter art and cash HUD")
	for frame: int in 30:
		await physics_frame
	check(controller.visitors.size() == 3 and controller.queue.size() == 3, "Paid customer exits and releases active slot")
	var impatient: BurgerCustomer = controller.queue.back()
	impatient.elapsed = 40
	await physics_frame
	await physics_frame
	check(impatient.state == BurgerCustomer.State.LEAVING and not impatient.paid and game.economy.burger_sales.sold == 1, "Patient timeout leaves without creating cash")
	var blocked: BurgerCustomer = controller.queue.back()
	blocked.target = Vector2(900, 600)
	blocked.route_elapsed = 100
	controller._physics_process(0)
	await process_frame
	check(not is_instance_valid(blocked), "Stuck route is retired without leaking actors or money")
	var walker: BurgerCustomer = controller.queue.front()
	walker.position = Vector2(700, 520)
	walker.target = Vector2(500, 520)
	walker.state = BurgerCustomer.State.QUEUING
	controller.set_process(false)
	controller.set_physics_process(false)
	for frame: int in 20:
		await physics_frame
	check(walker.position.x > 660, "Customer physics cannot pass through solid serving counter")
	controller.set_physics_process(true)
	game.restart()
	check(controller.visitors.is_empty() and game.economy.burger_sales.uncollected_cash == 0, "Explicit fresh start clears customer actors and sales state")
	scene.queue_free()
	await process_frame
	print("CUSTOMER RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
