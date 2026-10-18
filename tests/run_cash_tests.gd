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

func sell(economy: ShopEconomy, count: int) -> void:
	for index: int in count:
		economy.handling.counter = 1
		var ticket: int = economy.burger_sales.register_customer()
		economy.burger_sales.purchase(ticket, economy.handling, economy.production)
		economy.burger_sales.retire(ticket)

func _run() -> void:
	var economy: ShopEconomy = ShopEconomy.new()
	var point: Vector2 = economy.cash_pickup.point
	check(point == Vector2(415, 655), "Pickup uses actual cash fixture approach point")
	check(not economy.cash_pickup.is_near(Vector2(390, 610)) and not economy.cash_pickup.is_near(economy.handling.station_point("deliver")), "Spawn and delivery point do not automatically collect cash")
	check(economy.collect_cash(point) == 0 and economy.coins == 500, "Empty pickup grants nothing")
	sell(economy, 3)
	check(economy.burger_sales.uncollected_cash == 60 and economy.coins == 500, "Three sales aggregate in one pending balance before collection")
	check(economy.collect_cash(Vector2.ZERO) == 0 and economy.burger_sales.uncollected_cash == 60, "Distant pickup cannot collect pending revenue")
	for position: Vector2 in [Vector2.INF, Vector2(NAN, 0), point + Vector2(47, 0)]:
		check(economy.collect_cash(position) == 0 and economy.coins == 500, "Reject non-finite or outside pickup position %s" % str(position))
	check(economy.collect_cash(point + Vector2(46, 0)) == 60 and economy.coins == 560 and economy.burger_sales.uncollected_cash == 0, "Inclusive radius boundary transfers exact aggregate amount once")
	check(economy.burger_sales.sold == 3 and economy.burger_sales.revenue == 60 and economy.burger_sales.gross_profit() == 60 and economy.burger_sales.collected_cash() == 60 and economy.revenue == 0 and economy.customers == 0, "Collecting cash preserves revenue/profit/sales and tracks collection separately from grocery progression")
	var repeated_safe: bool = true
	for index: int in 10000:
		repeated_safe = repeated_safe and economy.collect_cash(point) == 0
	check(repeated_safe and economy.coins == 560, "Ten thousand repeat collections cannot double-pay")
	sell(economy, 1)
	economy.coins = ShopEconomy.MAX_TOTAL - 10
	check(economy.collect_cash(point) == 0 and economy.burger_sales.uncollected_cash == 20 and economy.coins == ShopEconomy.MAX_TOTAL - 10, "Insufficient wallet headroom preserves all pending money")
	economy.coins = ShopEconomy.MAX_TOTAL - 20
	check(economy.collect_cash(point) == 20 and economy.coins == ShopEconomy.MAX_TOTAL, "Exact wallet ceiling collection is permitted without overflow")
	var loaded: ShopEconomy = ShopEconomy.new()
	check(loaded.restore(JSON.parse_string(JSON.stringify(economy.snapshot()))) and loaded.coins == ShopEconomy.MAX_TOTAL and loaded.burger_sales.uncollected_cash == 0 and loaded.burger_sales.revenue == 80, "Existing schema 6 retains collected wallet and historical revenue separately")
	var stress: ShopEconomy = ShopEconomy.new()
	var correct: bool = true
	for index: int in 10000:
		sell(stress, 1)
		correct = correct and stress.collect_cash(point) == 20 and stress.collect_cash(point) == 0
	check(correct and stress.coins == 200500 and stress.burger_sales.uncollected_cash == 0 and stress.burger_sales.revenue == 200000 and stress.burger_sales.sold == 10000, "Ten thousand sale/collection cycles conserve exact total cash")
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	var folder: String = "user://cash-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder.path_join("missing-subdirectory"))
	sell(game.economy, 1)
	check(game.collect_cash(point) == 0 and game.economy.coins == 500 and game.economy.burger_sales.uncollected_cash == 20, "Actual file-open failure cannot consume cash or credit wallet")
	game.economy.reset()
	game.storage = LocalSave.new(folder)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	sell(game.economy, 3)
	game.handling_changed.emit()
	game.persist()
	var cash_fixture: ShopFixture
	for fixture: ShopFixture in scene.world.fixtures:
		if fixture.definition["id"] == "cash_point":
			cash_fixture = fixture
	check(cash_fixture.sales.uncollected_cash == 60 and scene.cash_label.text.contains("60"), "World cash display and HUD show actual pending aggregate")
	scene._try_collect_cash()
	check(game.economy.coins == 500 and game.economy.burger_sales.uncollected_cash == 60, "Polling while worker is away leaves wallet unchanged")
	scene.world.player.position = point
	scene.open_menu()
	scene._try_collect_cash()
	check(game.economy.coins == 500, "Open management menu blocks automatic pickup")
	scene.close_menu()
	scene.suspended = true
	scene._try_collect_cash()
	check(game.economy.coins == 500, "Suspended app cannot collect cash")
	scene.suspended = false
	scene.world.player.controls_blocked = true
	scene._try_collect_cash()
	check(game.economy.coins == 500, "Blocked worker cannot collect cash")
	scene.world.player.controls_blocked = false
	var observed: Array[int] = []
	var observer: Callable = func(amount: int) -> void:
		observed.append(amount)
		var durable: ShopEconomy = ShopEconomy.new()
		game.storage.load_into(durable)
		check(durable.coins == game.economy.coins and durable.burger_sales.uncollected_cash == 0, "Reward observers see already saved atomic wallet/cash state")
	game.cash_collected.connect(observer)
	# Exercise the real 150 ms nearby timer, not just a direct transaction call.
	await create_timer(0.22).timeout
	check(game.economy.coins == 560 and game.economy.burger_sales.uncollected_cash == 0 and observed == [60], "Standing at pickup automatically collects once via real timer")
	check(scene.wallet_label.text == "560 coins" and scene.cash_label.text.contains("Cash waiting: 0") and cash_fixture.sales.uncollected_cash == 0, "Collection refreshes wallet HUD, pending indicator and cash stack")
	check(scene.world.cash_reward.visible and scene.world.cash_reward.text == "+60" and scene.world.reward_tween.is_running(), "Collection shows a single floating reward with animation")
	await create_timer(0.25).timeout
	check(observed == [60] and game.economy.coins == 560, "Remaining at empty pickup cannot grant another reward")
	game.storage.load_into(loaded)
	check(loaded.coins == 560 and loaded.burger_sales.uncollected_cash == 0 and loaded.burger_sales.sold == 3, "Restart restores collected coins without restoring collected cash")
	sell(game.economy, 1)
	scene._try_collect_cash()
	check(game.economy.coins == 580 and observed == [60, 20] and scene.world.cash_reward.text == "+20", "New sale while near cash permits only the newly earned amount")
	game.cash_collected.disconnect(observer)
	sell(game.economy, 2)
	game.handling_changed.emit()
	game.persist()
	game.storage.blocked = true
	game.storage.message = "Test storage unavailable."
	scene._try_collect_cash()
	check(game.economy.coins == 580 and game.economy.burger_sales.uncollected_cash == 40 and scene.feedback_label.text == "Test storage unavailable.", "Save failure rolls back both wallet and pending cash before showing error")
	check(scene.cash_retry_at > Time.get_ticks_msec(), "Unavailable storage starts cooldown instead of repeated writes every poll")
	game.storage.blocked = false
	scene._try_collect_cash()
	check(game.economy.coins == 580, "Failure cooldown prevents immediate retry")
	scene.cash_retry_at = 0
	scene._try_collect_cash()
	check(game.economy.coins == 620 and game.economy.burger_sales.uncollected_cash == 0, "Retry after storage recovery transfers held cash exactly once")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	game.storage.load_into(loaded)
	check(loaded.coins == 620 and loaded.burger_sales.uncollected_cash == 0 and loaded.burger_sales.revenue == 120, "Pause/resume saves collected wallet and historical revenue")
	scene.queue_free()
	await process_frame
	print("CASH RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
