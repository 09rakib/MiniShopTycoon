extends SceneTree
var checks: int = 0
var failures: int = 0
var folder: String

func _initialize() -> void:
	call_deferred("_run")

func check(value: bool, description: String) -> void:
	checks += 1
	if value:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func record(path: String, value: Variant) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value if value is String else JSON.stringify(value))
	file.close()

func same(left: Dictionary, right: Dictionary) -> bool:
	left = left.duplicate(true)
	right = right.duplicate(true)
	left.erase("saved_at")
	right.erase("saved_at")
	return left == right

func _run() -> void:
	folder = "user://lifecycle-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	var initial: ShopEconomy = ShopEconomy.new()
	initial.buy("bread", 4)
	initial.production.stock = 3
	initial.handling.carried = 1
	initial.handling.counter = 2
	initial.operations.hired = true
	initial.operations.carried = 2
	initial.expansion.unlocked = true
	initial.expansion.production.active = true
	initial.expansion.production.stock = 3
	initial.expansion.handling.counter = 2
	initial.expansion.furniture = true
	initial.burger_sales.sold = 2
	initial.burger_sales.revenue = 40
	initial.burger_sales.uncollected_cash = 20
	for version: int in range(1, 9):
		var data: Dictionary = initial.snapshot()
		data.schema_version = version
		if version == 1:
			data.stock = {"bread": 4, "milk": 0, "apples": 0}
		var loaded: ShopEconomy = ShopEconomy.new()
		check(loaded.restore(data) and loaded.coins == initial.coins and loaded.stock.bread == 4, "Schema %d migration preserves grocery wallet/stock" % version)
		check(loaded.production.stock == (3 if version >= 4 else 0) and loaded.handling.carried == (1 if version >= 5 else 0), "Schema %d initializes only unavailable machine/handling fields" % version)
		check(loaded.burger_sales.uncollected_cash == (20 if version >= 6 else 0) and loaded.operations.carried == (2 if version >= 7 else 0) and loaded.expansion.furniture == (version >= 8), "Schema %d preserves supported cash/staff/expansion" % version)
		var save_folder: String = folder.path_join(str(version))
		DirAccess.make_dir_recursive_absolute(save_folder)
		record(save_folder.path_join("progress.json"), data)
		var storage: LocalSave = LocalSave.new(save_folder)
		storage.load_into(loaded)
		var upgraded: Dictionary = loaded.snapshot()
		check(not storage.blocked and storage.write(loaded), "Schema %d disk load upgrades successfully" % version)
		storage.load_into(loaded)
		check(same(upgraded, loaded.snapshot()), "Schema %d upgraded disk roundtrip is exact" % version)
	var storage: LocalSave = LocalSave.new(folder)
	check(storage.write(initial), "Write rich current checkpoint")
	var loaded: ShopEconomy = ShopEconomy.new()
	var production_ref: ProductionState = loaded.production
	var fries_ref: ProductionState = loaded.expansion.production
	storage.load_into(loaded)
	check(same(initial.snapshot(), loaded.snapshot()) and production_ref == loaded.production and fries_ref == loaded.expansion.production, "Full current save preserves every durable field and controller references")
	var unchanged: Dictionary = loaded.snapshot()
	for key: String in ["production", "burger_handling", "burger_sales", "operations", "expansion"]:
		var broken: Dictionary = initial.snapshot()
		broken[key] = {"bad": true}
		check(not loaded.restore(broken) and same(unchanged, loaded.snapshot()), "Invalid nested %s cannot partially change live state" % key)
	storage.write(initial)
	record(folder.path_join("progress.json"), "{truncated")
	storage.load_into(loaded)
	check(not storage.blocked and not storage.message.is_empty() and same(initial.snapshot(), loaded.snapshot()), "Corrupt primary recovers validated backup")
	record(folder.path_join("progress.json"), "bad")
	record(folder.path_join("progress.backup.json"), "bad")
	record(folder.path_join("progress.tmp.json"), initial.snapshot())
	storage.load_into(loaded)
	check(not storage.blocked and same(initial.snapshot(), loaded.snapshot()), "Interrupted write recovers valid temporary when primary/backup invalid")
	var future: Dictionary = initial.snapshot()
	future.schema_version = 99
	record(folder.path_join("progress.json"), future)
	record(folder.path_join("progress.backup.json"), initial.snapshot())
	storage.load_into(loaded)
	check(storage.blocked and not storage.write(loaded) and JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("progress.json"))).schema_version == 99, "Future primary blocks downgrade despite valid old backup")
	record(folder.path_join("progress.json"), initial.snapshot())
	storage.load_into(loaded)
	check(not storage.blocked and storage.message.is_empty() and storage.write(loaded), "Successful reload clears prior blocked state and stale message")
	var missing: LocalSave = LocalSave.new(folder.path_join("missing"))
	check(not missing.reset_with(loaded) and same(unchanged, loaded.snapshot()), "Unavailable reset destination preserves live progress")
	DirAccess.make_dir_absolute(folder.path_join("progress.json.before-reset"))
	check(not storage.reset_with(loaded) and same(unchanged, loaded.snapshot()), "Archive conflict aborts reset without changing live economy")
	storage.load_into(loaded)
	check(same(unchanged, loaded.snapshot()), "Failed reset leaves the primary disk checkpoint intact")
	DirAccess.remove_absolute(folder.path_join("progress.json.before-reset"))
	var settings: ShopSettings = ShopSettings.new(folder)
	settings.save_enabled(false)
	check(storage.reset_with(loaded) and loaded.coins == 500 and loaded.operations.carried == 0 and not loaded.expansion.unlocked, "Explicit reset commits fresh economy after preparing disk replacement")
	check(FileAccess.file_exists(folder.path_join("progress.json.before-reset")), "Explicit reset archives original primary")
	storage.load_into(loaded)
	check(loaded.production.stock == 0 and loaded.handling.carried == 0 and loaded.burger_sales.uncollected_cash == 0 and settings.load_settings() and not settings.enabled, "Reset roundtrip clears food/cash but preserves sound preference")
	var game: Node = root.get_node("Game")
	game.economy = initial
	game.storage = LocalSave.new(folder.path_join("transactions"))
	DirAccess.make_dir_recursive_absolute(game.storage.directory)
	game.storage.write(initial)
	game.storage.blocked = true
	unchanged = initial.snapshot()
	check(not game.interact_burgers("pickup", initial.handling.station_point("pickup")) and same(unchanged, initial.snapshot()), "Failed player pickup rolls back both ends")
	check(not game.interact_burgers("deliver", initial.handling.station_point("deliver")) and same(unchanged, initial.snapshot()), "Failed player delivery retains held food and counter")
	check(game.stocker_transfer("deliver", initial.handling.station_point("deliver")) == 0 and same(unchanged, initial.snapshot()), "Failed staff delivery retains staff-held food")
	initial.handling.carried = 0
	initial.expansion.handling.carried = 1
	unchanged = initial.snapshot()
	check(not game.interact_burgers("deliver", initial.handling.station_point("deliver")) and same(unchanged, initial.snapshot()), "Failed fries delivery preserves distinct food ledger")
	var ticket: int = initial.burger_sales.register_customer()
	var tickets: Dictionary = initial.burger_sales.tickets.duplicate()
	check(not game.sell_burger(ticket) and same(unchanged, initial.snapshot()) and tickets == initial.burger_sales.tickets, "Failed customer sale preserves stock/cash and reusable unpaid ticket")
	game.storage.blocked = false
	check(game.sell_burger(ticket) and not game.sell_burger(ticket), "Recovered storage retries unpaid sale exactly once")
	var old: Dictionary = initial.snapshot()
	old.saved_at = 0
	var past: ShopEconomy = ShopEconomy.new()
	check(past.restore(old) and same(old, past.snapshot()), "Elapsed wall time never grants offline production or income")
	initial.customers = 100
	initial.shelf_upgrades.pantry = 1
	initial.upgrade_spending = 120
	game.storage.write(initial)
	game.storage.load_into(past)
	check(past.shop_level() == initial.shop_level() and past.next_objective() == initial.next_objective() and past.capacity("bread") == initial.capacity("bread"), "Progression level, objectives and upgraded capacity survive restart")
	var retained_storage: RefCounted = game.storage
	game.economy = ShopEconomy.new()
	var journey: String = folder.path_join("journey")
	DirAccess.make_dir_recursive_absolute(journey)
	game.storage = LocalSave.new(journey)
	var conserved: bool = true
	for index: int in 20:
		game.economy.production.produce_one()
		conserved = game.interact_burgers("pickup", game.economy.handling.station_point("pickup")) and conserved
		var resumed: ShopEconomy = ShopEconomy.new()
		game.storage.load_into(resumed)
		conserved = resumed.handling.carried == 1 and resumed.production.stock == 0 and conserved
		game.economy = resumed
		conserved = game.interact_burgers("deliver", resumed.handling.station_point("deliver")) and conserved
		var visit: int = resumed.burger_sales.register_customer()
		conserved = game.sell_burger(visit) and conserved
		conserved = game.collect_cash(resumed.cash_pickup.point) == 20 and conserved
		resumed.burger_sales.retire(visit)
		var reloaded: ShopEconomy = ShopEconomy.new()
		game.storage.load_into(reloaded)
		game.economy = reloaded
	check(conserved, "Twenty disk-backed journeys restart while carrying then complete real service/sale/cash")
	check(game.economy.coins == 900 and game.economy.burger_sales.revenue == 400 and game.economy.burger_sales.sold == 20 and game.economy.burger_sales.uncollected_cash == 0, "Repeated restart journeys conserve exact wallet and lifetime proceeds")
	check(game.economy.handling.carried + game.economy.handling.counter + game.economy.production.stock == 0 and game.economy.burger_sales.tickets.is_empty(), "Repeated restart journeys retain no consumed food or replayable customer ticket")
	game.economy = initial
	game.storage = retained_storage
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.open_menu()
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	var saved: Dictionary = initial.snapshot()
	scene.production_controller._produce()
	scene.fries_controller._produce()
	scene._check_nearby()
	check(paused and same(saved, initial.snapshot()) and not scene.joystick.enabled, "Paused simulation cannot produce or auto-transfer")
	var fresh: ShopEconomy = ShopEconomy.new()
	game.storage.load_into(fresh)
	check(same(saved, fresh.snapshot()) and fresh.burger_sales.tickets.is_empty(), "Pause flush reloads exact state without replaying transient customers")
	game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	scene._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	check(not paused and scene.menu.visible and not scene.joystick.enabled, "Resume preserves open menu and blocks stale movement")
	scene.close_menu()
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(scene.suspended and scene.production_controller.cycle_timer.is_stopped() and scene.fries_controller.cycle_timer.is_stopped(), "Focus loss stops both production timers")
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(not scene.suspended and scene.joystick.enabled and not scene.joystick.active(), "Focus return requires fresh touch")
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	scene.stocker_controller.set_paused(true)
	scene.queue_free()
	await process_frame
	await process_frame
	print("LIFECYCLE RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
