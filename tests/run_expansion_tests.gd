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
	var fries: ShopExpansion = economy.expansion
	check(not fries.unlocked and not fries.production.active and not fries.production.produce_one() and fries.seats() == 0, "Unowned machine cannot produce; no free seating")
	check(fries.production is ProductionState and fries.production.capacity() == 8 and is_equal_approx(fries.production.interval(), 3.0) and fries.production.selling_price() == 16, "Additional machine shares production primitive with own product/config")
	economy.coins = 0
	economy.burger_sales.uncollected_cash = 400
	economy.burger_sales.revenue = 400
	economy.burger_sales.sold = 20
	check(not economy.purchase_expansion("fries").is_empty() and not fries.unlocked, "Pending cash cannot unlock machine without wallet funds")
	economy.coins = 1000
	check(economy.purchase_expansion("fries").is_empty() and fries.production.active and fries.unlocked and economy.coins == 600 and fries.spending == 400, "Machine unlock spends wallet exactly once and activates production")
	check(not economy.purchase_expansion("fries").is_empty() and economy.coins == 600, "Duplicate machine purchase cannot charge again")
	check(economy.purchase_expansion("furniture").is_empty() and fries.seats() == 2 and economy.coins == 420 and fries.spending == 580, "Furniture bundle costs 180 and adds exactly two seats")
	check(not economy.purchase_expansion("furniture").is_empty() and not economy.purchase_expansion("unknown").is_empty() and economy.coins == 420, "Duplicate furniture and unknown item rejected")
	for index: int in 20:
		fries.production.produce_one()
	check(fries.production.stock == 8 and not fries.production.can_produce(), "Fries production bounded to eight")
	var pickup: Vector2 = fries.handling.station_point("pickup")
	var delivery: Vector2 = economy.handling.station_point("deliver")
	check(economy.transfer_food("fries", Vector2.ZERO)["amount"] == 0 and fries.production.stock == 8, "Fries cannot be collected remotely")
	check(economy.transfer_food("fries", pickup)["amount"] == 2 and fries.production.stock == 6 and fries.handling.carried == 2, "Collect two fries through same bounded transfer code")
	economy.production.stock = 5
	check(economy.transfer_food("pickup", economy.handling.station_point("pickup"))["amount"] == 0 and economy.handling.carried == 0 and fries.handling.carried == 2, "Shared player hands cannot carry two of each product")
	check(economy.transfer_food("deliver", delivery)["amount"] == 2 and fries.handling.counter == 2 and fries.handling.carried == 0, "Fries delivered into separate four-slot counter stock")
	economy.handling.carried = 1
	check(economy.transfer_food("fries", pickup)["amount"] == 0 and fries.handling.carried == 0, "Single carried burger requires delivery before another product type")
	economy.transfer_food("deliver", delivery)
	for trip: int in 2:
		economy.transfer_food("fries", pickup)
		economy.transfer_food("deliver", delivery)
	check(fries.handling.counter == 4 and fries.handling.carried == 2 and fries.production.stock == 2, "Fries counter fills at four; next held pair stays in hand")
	var safe: bool = true
	for index: int in 10000:
		economy.transfer_food("deliver", delivery)
		economy.transfer_food("fries", pickup)
		safe = safe and fries.production.stock + fries.handling.carried + fries.handling.counter == 8
	check(safe and fries.handling.carried == 2, "Ten thousand full-counter attempts conserve all fries")
	fries.handling.counter = 3
	check(economy.transfer_food("deliver", delivery)["amount"] == 1 and fries.handling.carried == 1 and fries.handling.counter == 4, "Partial fries delivery retains leftover")
	var ledger: BurgerSales = BurgerSales.new()
	economy.handling.counter = 2
	fries.handling.counter = 2
	var first: int = ledger.register_customer()
	var second: int = ledger.register_customer()
	check(ledger.purchase(first, economy.handling, economy.production, fries.handling, fries.production) == 20 and economy.handling.counter == 1, "Burger shelf pays its actual price")
	check(ledger.purchase(second, economy.handling, economy.production, fries.handling, fries.production) == 16 and fries.handling.counter == 1 and ledger.uncollected_cash == 36 and ledger.sold == 2, "Next customer alternates to fries at correct price without adding wallet")
	check(ledger.purchase(second, economy.handling, economy.production, fries.handling, fries.production) == 0 and ledger.uncollected_cash == 36, "Customer cannot repeat purchase by changing product")
	ledger.retire(first)
	ledger.retire(second)
	economy.handling.counter = 0
	fries.handling.counter = 1
	first = ledger.register_customer()
	second = ledger.register_customer()
	check(ledger.purchase(first, economy.handling, economy.production, fries.handling, fries.production) == 16 and ledger.purchase(second, economy.handling, economy.production, fries.handling, fries.production) == 0 and fries.handling.counter == 0, "Last fries portion can only be claimed once")
	var loaded: ShopEconomy = ShopEconomy.new()
	var snapshot: Dictionary = economy.snapshot()
	check(loaded.restore(JSON.parse_string(JSON.stringify(snapshot))) and loaded.expansion.unlocked and loaded.expansion.furniture and loaded.expansion.handling.carried == 1 and loaded.expansion.production.stock == 2 and loaded.expansion.spending == 580, "Schema 8 retains machine, furniture and separate in-transit fries")
	var legacy: Dictionary = snapshot.duplicate(true)
	legacy["schema_version"] = 7
	legacy.erase("expansion")
	check(loaded.restore(legacy) and loaded.coins == economy.coins and loaded.production.stock == 5 and not loaded.expansion.unlocked and loaded.burger_sales.uncollected_cash == 400, "Schema 7 migration preserves old wallet, burgers and cash; no free expansion")
	for field: String in ["unlocked", "furniture", "spending", "production", "handling"]:
		var bad: Dictionary = snapshot.duplicate(true)
		bad["expansion"][field] = "invalid"
		bad["coins"] = 1
		check(not loaded.restore(bad) and loaded.coins == economy.coins and not loaded.expansion.unlocked, "Malformed expansion %s rejects entire save atomically" % field)
	var bad: Dictionary = snapshot.duplicate(true)
	bad["burger_handling"]["carried"] = 1
	check(not loaded.restore(bad), "Saved mixed product carrying cannot exceed one product per trip")
	bad = snapshot.duplicate(true)
	bad["expansion"]["unlocked"] = false
	check(not loaded.restore(bad), "Locked machine cannot restore active production or owned stock")
	bad = snapshot.duplicate(true)
	bad["expansion"]["handling"]["counter"] = 5
	check(not loaded.restore(bad), "Overflow fries counter rejected on load")
	var stress: ShopEconomy = ShopEconomy.new()
	stress.purchase_expansion("fries")
	var conserved: bool = true
	for index: int in 10000:
		stress.expansion.production.produce_one()
		stress.transfer_food("fries", pickup)
		stress.transfer_food("deliver", delivery)
		var id: int = stress.burger_sales.register_customer()
		conserved = conserved and stress.burger_sales.purchase(id, stress.handling, stress.production, stress.expansion.handling, stress.expansion.production) == 16
		stress.burger_sales.retire(id)
	check(conserved and stress.burger_sales.uncollected_cash == 160000 and stress.burger_sales.sold == 10000 and stress.coins == 100 and stress.expansion.production.stock + stress.expansion.handling.carried + stress.expansion.handling.counter == 0, "Ten thousand complete fries production/carry/delivery/sale cycles conserve food and exact pending payment")
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	var folder: String = "user://expansion-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	check(scene.fries_controller.state == game.economy.expansion.production and scene.fries_controller.cycle_timer.is_stopped() and scene.world.fixtures.size() == 4, "Second controller reuses existing class, no unbought machine/furniture actor")
	game.economy.coins = 1000
	game.storage.blocked = true
	game.storage.message = "Test storage failure."
	check(not game.purchase_expansion("fries") and not game.economy.expansion.unlocked and game.economy.coins == 1000 and scene.world.fixtures.size() == 4, "Failed machine save rolls back wallet/unlock before world creation")
	check(not game.purchase_expansion("furniture") and not game.economy.expansion.furniture and game.economy.coins == 1000, "Failed furniture save cannot create unpaid placement")
	game.storage.blocked = false
	scene.open_menu()
	scene._open_expansion()
	check(scene.expansion_panel.visible and not scene.operations_panel.visible and scene.world.player.controls_blocked, "Expansion panel opens with world controls blocked")
	scene.expansion_panel.machine_button.pressed.emit()
	scene.expansion_panel.furniture_button.pressed.emit()
	check(game.economy.expansion.unlocked and game.economy.expansion.seats() == 2 and scene.world.fixtures.size() == 6 and scene.expansion_panel.machine_button.disabled and scene.expansion_panel.furniture_button.disabled, "Actual purchase buttons create one machine and one furniture bundle")
	game.storage.load_into(loaded)
	check(loaded.coins == 420 and loaded.expansion.furniture and loaded.expansion.production.active and loaded.expansion.spending == 580, "Expansion purchase immediately persists wallet and all owned objects")
	check(not scene.fries_controller.cycle_timer.is_stopped() and is_equal_approx(scene.fries_controller.cycle_timer.wait_time, 3.0), "Buying machine starts real three-second production cycle")
	scene.close_menu()
	await create_timer(3.15).timeout
	check(game.economy.expansion.production.stock == 1, "Second machine really produces on its own configured timer")
	scene.fries_controller.set_paused(true)
	game.economy.expansion.production.produce_one()
	scene.world.player.position = pickup
	scene._update_location()
	check(scene.action_button.text == "Collect fries 2" and not scene.action_button.disabled, "Fries source offers actual contextual collection")
	scene.action_button.pressed.emit()
	check(game.economy.expansion.handling.carried == 2 and scene.world.player.fries_count == 2 and scene.world.player.carried_count == 0, "Real action updates separate carried fries art")
	scene.world.player.position = delivery
	scene._update_location()
	scene.action_button.pressed.emit()
	check(game.economy.expansion.handling.counter == 2 and scene.world.player.fries_count == 0 and scene.carry_label.text.contains("F 2/4") and scene.location_label.text.contains("F 2/4"), "Delivery updates fries shelf and HUD")
	# Real queue buys fries even when no burger is present.
	scene.customer_controller.set_paused(false)
	scene.customer_controller.spawn_timer.stop()
	scene.customer_controller.spawn_customer()
	scene.customer_controller.visitors[0].speed = 1400
	await create_timer(2.0).timeout
	check(game.economy.burger_sales.sold == 1 and game.economy.burger_sales.uncollected_cash == 16 and game.economy.expansion.handling.counter == 1 and game.economy.coins == 420, "Real customer buys available fries with exact pending payment")
	scene.customer_controller.set_paused(true)
	scene.world.player.position = game.economy.cash_pickup.point
	scene._try_collect_cash()
	check(game.economy.coins == 436 and game.economy.burger_sales.uncollected_cash == 0, "Fries proceeds collect through same exact cash-to-wallet transaction")
	# Validate furniture/machine against all reserved paths and solid geometry.
	var placement_clear: bool = true
	for definition: Dictionary in game.economy.expansion.config["fixtures"]:
		var r: Array = definition["rect"]
		var rect: Rect2 = Rect2(r[0], r[1], r[2], r[3]).grow(17)
		for v: Variant in game.economy.operations.config["route"]:
			placement_clear = placement_clear and not rect.has_point(Vector2(v[0], v[1]))
		placement_clear = placement_clear and not rect.intersects(Rect2(280, 390, 150, 190)) and not rect.intersects(Rect2(665, 500, 100, 450)) and not rect.intersects(Rect2(280, 855, 260, 100))
	check(placement_clear, "Fixed placements preserve worker aisle, customer lane and entrance with character margin")
	scene.world.player.position = Vector2(170, 885)
	scene.world.player.set_move_vector(Vector2.UP)
	for frame: int in 35:
		await physics_frame
	scene.world.player.stop()
	check(scene.world.player.position.y > 855, "Purchased furniture is a solid obstacle, not just painted art")
	game.persist()
	game.storage.load_into(loaded)
	check(loaded.expansion.furniture and loaded.expansion.handling.counter == 1 and loaded.coins == 436, "Restart retains purchased furniture, remaining fries and collected wallet")
	scene.queue_free()
	await process_frame
	game.economy = loaded
	scene = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	check(scene.world.fixtures.size() == 6 and game.economy.expansion.seats() == 2, "Relaunch recreates deterministic purchased objects exactly once")
	game.changed.emit()
	check(scene.world.fixtures.size() == 6, "Repeated refresh cannot duplicate purchased objects")
	game.restart()
	await process_frame
	check(scene.world.fixtures.size() == 4 and game.economy.expansion.seats() == 0 and scene.fries_controller.cycle_timer.is_stopped(), "Explicit reset removes expansion objects and stops locked machine")
	scene.queue_free()
	await process_frame
	print("EXPANSION RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
