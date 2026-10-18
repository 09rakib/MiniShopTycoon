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
	var economy: ShopEconomy = ShopEconomy.new()
	check(economy.coins == 500 and economy.stock["bread"] == 0, "Fresh shop defaults")
	check(economy.buy("bread", 5) == "" and economy.coins == 460 and economy.stock["bread"] == 5, "Buy stock at wholesale cost")
	check(economy.sell("bread") and economy.coins == 474 and economy.stock["bread"] == 4, "Sell exactly one product")
	check(economy.revenue == 14 and economy.cost_of_goods == 8 and economy.customers == 1, "Revenue and cost of sold goods tracked separately")
	var before: Dictionary = economy.snapshot()
	check(not economy.buy("bread", -1).is_empty() and not economy.buy("invalid", 5).is_empty(), "Reject invalid orders")
	check(economy.stock == before["stock"] and economy.coins == before["coins"], "Rejected orders do not mutate state")
	check(not economy.buy("bread", 17).is_empty(), "Capacity rejects overflow")
	economy.coins = 0
	check(not economy.buy("milk", 5).is_empty() and economy.stock["milk"] == 0, "Insufficient coins reject purchase")
	check(not economy.sell("milk") and not economy.sell("invalid"), "Cannot sell empty or unknown product")
	economy.reset()
	check(economy.buy("bread", 20).is_empty() and not economy.buy("bread", 1).is_empty(), "Exact capacity supported; repeated purchase blocked")
	for index: int in 20:
		economy.sell("bread")
	check(not economy.sell("bread") and economy.stock["bread"] == 0 and economy.customers == 20, "Repeated sales never create negative inventory")
	var saved: Dictionary = economy.snapshot()
	var restored: ShopEconomy = ShopEconomy.new()
	check(restored.restore(saved) and restored.coins == economy.coins, "Save restore round trip")
	var invalid: Dictionary = saved.duplicate(true)
	invalid["stock"]["bread"] = -1
	check(not restored.restore(invalid) and restored.stock["bread"] == 0, "Reject invalid inventory without mutation")
	invalid = saved.duplicate(true)
	invalid["coins"] = 0.5
	check(not restored.restore(invalid), "Reject fractional coins")
	invalid["coins"] = "500"
	check(not restored.restore(invalid), "Reject incorrectly typed coins")
	invalid = saved.duplicate(true)
	invalid["schema_version"] = 999
	check(not restored.restore(invalid), "Preserve unsupported future schema")
	var test_dir: String = "user://phase1-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(test_dir)
	var storage: LocalSave = LocalSave.new(test_dir)
	check(storage.write(economy), "Write local save")
	economy.buy("milk", 5)
	check(storage.write(economy), "Replace local save and retain backup")
	var loaded: ShopEconomy = ShopEconomy.new()
	storage.load_into(loaded)
	check(loaded.coins == economy.coins and loaded.stock == economy.stock, "Disk save/load round trip")
	var corrupt: FileAccess = FileAccess.open(test_dir.path_join("progress.json"), FileAccess.WRITE)
	corrupt.store_string("{ broken")
	corrupt.close()
	storage.load_into(loaded)
	check(not storage.blocked and loaded.stock["milk"] == 0, "Recover last valid backup from malformed primary")
	check(storage.write(loaded), "Repair primary after successful recovery")
	var broken_dir: String = test_dir.path_join("broken")
	DirAccess.make_dir_recursive_absolute(broken_dir)
	corrupt = FileAccess.open(broken_dir.path_join("progress.json"), FileAccess.WRITE)
	corrupt.store_string("unreadable")
	corrupt.close()
	var broken: LocalSave = LocalSave.new(broken_dir)
	broken.load_into(loaded)
	check(broken.blocked and not broken.write(loaded), "Unrecoverable save is preserved, not overwritten")
	check(broken.reset_with(loaded) and loaded.coins == 500 and loaded.stock["bread"] == 0, "Explicit reset creates valid fresh progress")
	# Exercise actual UI actions and the bounded customer simulation without real-time waits.
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	game.storage = LocalSave.new(test_dir)
	var main: Control = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	main._show_shop()
	main.buy_buttons["bread"].pressed.emit()
	check(game.economy.coins == 460 and game.economy.stock["bread"] == 5, "UI stock button calls validated transaction")
	for tick: int in 800:
		main.customers._tick()
	check(game.economy.customers == 5 and game.economy.coins == 530 and game.economy.stock["bread"] == 0, "Customers check out once each and stop selling when empty")
	check(main.customers.slots.size() == 4, "Customer object pool remains bounded")
	main._show_menu()
	var old_stock: Dictionary = game.economy.stock.duplicate()
	main.customers._tick()
	check(game.economy.stock == old_stock and not game.running, "Menu pauses customer simulation")
	main._show_shop()
	main._confirm_restart()
	main.restart_dialog.canceled.emit()
	main.restart_dialog.hide()
	check(game.economy.coins == 530 and game.running, "Cancel restart preserves progress and resumes shop")
	main._restart()
	check(game.economy.coins == 500 and game.economy.customers == 0, "Confirmed restart clears economy and customers")
	main._restart()
	check(game.economy.coins == 500 and not game.storage.blocked, "Repeated reset replaces bounded recovery archives")
	game.buy("milk")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	check(paused, "Application pause suspends scene tree")
	game._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	check(not paused, "Application resume restores simulation")
	var lifecycle_load: ShopEconomy = ShopEconomy.new()
	game.storage.load_into(lifecycle_load)
	check(lifecycle_load.stock["milk"] == 5 and lifecycle_load.coins == 440, "Pause persists latest completed transaction")
	_phase2_checks(game, main, test_dir)
	_phase3_checks(game, main, test_dir)
	main.queue_free()
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _phase2_checks(game: Node, main: Control, test_dir: String) -> void:
	var economy: ShopEconomy = ShopEconomy.new()
	check(economy.products.size() == 10 and ProductCatalog.validate(economy.catalog).is_empty(), "Ten valid configured products")
	for product: Dictionary in economy.products:
		economy.reset()
		_grant_phase2_access(economy)
		var id: String = product["id"]
		var cost: int = int(product["wholesale"])
		var price: int = int(product["price"])
		check(economy.buy(id, 5).is_empty() and economy.stock_spending == 5 * cost and economy.inventory_value() == 5 * cost, "Purchase accounting: " + id)
		check(economy.sell(id) and economy.coins == 500 - 5 * cost + price and economy.revenue - economy.cost_of_goods == price - cost and economy.inventory_value() == 4 * cost, "Sale/profit accounting: " + id)
		check(ProductIcons.texture(id) != null, "Original product icon loads: " + id)
	economy.reset()
	var untouched: Dictionary = economy.snapshot()
	check(not economy.buy("bread", 9223372036854775807).is_empty() and economy.coins == untouched["coins"] and economy.stock_spending == 0, "Huge quantity rejected before integer overflow")
	check(not economy.buy("bread", 0).is_empty() and not economy.buy("bread", -5).is_empty(), "Zero and negative quantities rejected")
	economy.buy("bread", 20)
	economy.sell("bread")
	check(not economy.buy("bread", 5).is_empty() and economy.buy("bread", 1).is_empty() and economy.stock["bread"] == 20, "Single-unit order fills remaining capacity exactly")
	var bad_catalog: Dictionary = economy.catalog.duplicate(true)
	bad_catalog["products"][0]["wholesale"] = -1
	check(not ProductCatalog.validate(bad_catalog).is_empty(), "Reject negative configured wholesale price")
	bad_catalog = economy.catalog.duplicate(true)
	bad_catalog["products"][0]["price"] = 0
	check(not ProductCatalog.validate(bad_catalog).is_empty(), "Reject zero configured selling price")
	bad_catalog = economy.catalog.duplicate(true)
	bad_catalog["products"][0]["price"] = 2.5
	check(not ProductCatalog.validate(bad_catalog).is_empty(), "Reject fractional configured price")
	bad_catalog = economy.catalog.duplicate(true)
	bad_catalog["products"][1]["id"] = "bread"
	check(not ProductCatalog.validate(bad_catalog).is_empty(), "Reject duplicate product IDs")
	bad_catalog = economy.catalog.duplicate(true)
	bad_catalog["products"][0]["shelf"] = 8
	check(not ProductCatalog.validate(bad_catalog).is_empty(), "Reject offscreen shelf configuration")
	bad_catalog = economy.catalog.duplicate(true)
	bad_catalog["customer_interval"] = -1
	check(not ProductCatalog.validate(bad_catalog).is_empty(), "Reject invalid customer timing")
	var legacy: Dictionary = {"schema_version": 1, "coins": 474, "revenue": 14, "cost_of_goods": 8, "customers": 1, "stock": {"bread": 4, "milk": 0, "apples": 0}, "saved_at": 1}
	var migrated: ShopEconomy = ShopEconomy.new()
	check(migrated.restore(JSON.parse_string(JSON.stringify(legacy))) and migrated.coins == 474 and migrated.stock["bread"] == 4 and migrated.stock["water"] == 0 and migrated.stock_spending == 40, "Phase 1 JSON migration preserves balances and initializes new products")
	var migration_dir: String = test_dir.path_join("migration")
	DirAccess.make_dir_recursive_absolute(migration_dir)
	var old_file: FileAccess = FileAccess.open(migration_dir.path_join("progress.json"), FileAccess.WRITE)
	old_file.store_string(JSON.stringify(legacy))
	old_file.close()
	var migration_save: LocalSave = LocalSave.new(migration_dir)
	migration_save.load_into(migrated)
	check(not migration_save.blocked and migration_save.write(migrated), "Legacy disk save upgrades through normal load/write path")
	var reloaded: ShopEconomy = ShopEconomy.new()
	migration_save.load_into(reloaded)
	check(reloaded.stock_spending == 40 and reloaded.stock == migrated.stock and reloaded.coins == 474, "Migrated save round trip retains all ten products")
	legacy["stock"].erase("bread")
	check(not reloaded.restore(legacy), "Missing legacy product is not silently erased")
	var broken_v2: Dictionary = migrated.snapshot()
	broken_v2["stock"].erase("water")
	check(not reloaded.restore(broken_v2), "Missing current-schema inventory rejected")
	broken_v2 = migrated.snapshot()
	broken_v2["stock_spending"] = -1
	check(not reloaded.restore(broken_v2), "Negative purchase ledger rejected")
	economy.reset()
	_grant_phase2_access(economy)
	economy.buy("water", 1)
	economy.coins = ShopEconomy.MAX_TOTAL
	check(not economy.sell("water") and economy.stock["water"] == 1, "Currency ceiling rejects sale without consuming inventory")
	game.economy = ShopEconomy.new()
	_grant_phase2_access(game.economy)
	main.customers.clear()
	main._show_inventory()
	check(main.inventory_screen.stocks.size() == 10 and not game.running, "Inventory shows all products and pauses customers")
	main.inventory_screen.singles["water"].pressed.emit()
	check(game.economy.stock["water"] == 1 and game.economy.coins == 496 and game.economy.stock_spending == 4, "Inventory single-unit button uses validated transaction")
	main.inventory_screen.batches["soap"].pressed.emit()
	check(game.economy.stock["soap"] == 5 and game.economy.coins == 441, "Inventory batch button stocks a new product")
	game.economy.coins = 0
	main.inventory_screen.singles["rice"].pressed.emit()
	check(game.economy.stock["rice"] == 0 and main.inventory_screen.feedback_label.text.contains("Not enough coins"), "Visible insufficient-funds feedback with no inventory mutation")
	game.economy.reset()
	game.buy("milk", 20)
	main.inventory_screen.refresh()
	check(main.inventory_screen.singles["milk"].disabled and main.inventory_screen.batches["milk"].disabled, "Both inventory actions disable at full capacity")
	main._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(main.on_shop and game.running, "Android Back from inventory returns to shop")
	game.economy.reset()
	_grant_phase2_access(game.economy)
	main.customers.clear()
	game.buy("soap", 1)
	for tick: int in 400:
		main.customers._tick()
	check(game.economy.customers == 1 and game.economy.stock["soap"] == 0 and game.economy.coins == 508, "Customers buy a new catalog product exactly once")
	# Load UI code after autoloads are registered by SceneTree startup.
	var view: Control = load("res://scripts/shop_view.gd").new()
	var point: Vector2 = view.customer_position({"progress": 0.4, "product": 8})
	check(point.x >= 0 and point.x <= 440 and point.y >= 0 and point.y <= 300, "New-product customer path stays inside shop")
	view.free()

func _grant_phase2_access(economy: ShopEconomy) -> void:
	# Prior-version regression cases exercise grandfathered Phase 2 access.
	for product: Dictionary in economy.products:
		economy.retained_unlocks.append(product["id"])

func _phase3_checks(game: Node, main: Control, test_dir: String) -> void:
	var economy: ShopEconomy = ShopEconomy.new()
	check(economy.shop_level() == 1 and economy.unlocked_count() == 3, "Fresh shop begins at level 1 with three products")
	check(not economy.buy("soap", 1).is_empty() and economy.coins == 500 and economy.stock["soap"] == 0, "Locked product cannot be purchased or charged")
	check(economy.capacity("bread") == 20 and economy.capacity("invalid") == 0, "Base capacity and unknown product lookup")
	check(economy.upgrade_rules.cost("pantry", 0) == 120 and economy.upgrade_rules.cost("pantry", 1) == 240 and economy.upgrade_rules.cost("pantry", 2) == 480, "Configured upgrade prices increase correctly")
	check(economy.buy_upgrade("pantry").is_empty() and economy.coins == 380 and economy.upgrade_spending == 120 and economy.capacity("bread") == 30 and economy.capacity("snacks") == 30 and economy.capacity("milk") == 20, "Shelf upgrade charges once and benefits only its group")
	var after_upgrade: Dictionary = economy.snapshot()
	check(not economy.buy_upgrade("pantry").is_empty() and economy.coins == after_upgrade["coins"] and economy.shelf_upgrades["pantry"] == 1, "Repeated upgrade blocked by level requirement without charge")
	check(not economy.buy_upgrade("missing").is_empty(), "Unknown shelf upgrade rejected")
	economy.coins = 0
	check(not economy.buy_upgrade("chilled").is_empty() and economy.shelf_upgrades["chilled"] == 0, "Unaffordable upgrade leaves state untouched")
	economy.reset()
	economy.coins = 120
	check(not economy.buy_upgrade("pantry").is_empty() and economy.coins == 120 and economy.shelf_upgrades["pantry"] == 0, "Upgrade cannot strand an empty shop without restocking money")
	economy.reset()
	economy.buy("bread", 10)
	for index: int in 9:
		economy.sell("bread")
	check(economy.shop_level() == 1 and not economy.is_unlocked("eggs"), "Unlock remains locked one customer before threshold")
	economy.sell("bread")
	check(economy.shop_level() == 2 and economy.progression.xp_for(economy.customers) == 100 and economy.is_unlocked("eggs") and economy.is_unlocked("water") and economy.unlocked_count() == 6, "Tenth sale levels up and unlocks level-2 products")
	economy.customers = 30
	check(economy.shop_level() == 3 and economy.is_unlocked("rice") and economy.is_unlocked("soft_drinks") and not economy.is_unlocked("snacks"), "Level 3 product boundaries")
	economy.customers = 65
	check(economy.shop_level() == 4 and economy.is_unlocked("snacks"), "Level 4 unlock")
	economy.customers = 110
	check(economy.shop_level() == 5 and economy.is_unlocked("soap") and economy.unlocked_count() == 10, "Level 5 unlocks entire catalog")
	economy.customers = 170
	check(economy.shop_level() == 6 and economy.progression.xp_text(170).contains("Max level"), "Final level handles no further XP target")
	economy.coins = 5000
	for index: int in 3:
		economy.buy_upgrade("pantry")
	check(economy.shelf_upgrades["pantry"] == 3 and economy.capacity("bread") == 50 and economy.upgrade_spending == 840, "Maximum shelf upgrade capacity and cumulative cost")
	var maximum_coins: int = economy.coins
	check(not economy.buy_upgrade("pantry").is_empty() and economy.coins == maximum_coins, "Maxed upgrade cannot charge again")
	economy.buy("bread", 50)
	check(economy.stock["bread"] == 50 and not economy.buy("bread", 1).is_empty(), "Upgraded shelf accepts new capacity and rejects overflow")
	var upgraded_save: Dictionary = economy.snapshot()
	var reloaded: ShopEconomy = ShopEconomy.new()
	check(reloaded.restore(JSON.parse_string(JSON.stringify(upgraded_save))) and reloaded.capacity("bread") == 50 and reloaded.stock["bread"] == 50 and reloaded.shop_level() == 6 and reloaded.upgrade_spending == 840, "Schema 3 preserves upgrades, high stock, level and spending")
	var folder: String = test_dir.path_join("phase3")
	DirAccess.make_dir_recursive_absolute(folder)
	var save: LocalSave = LocalSave.new(folder)
	check(save.write(economy), "Save upgraded shop to disk")
	save.load_into(reloaded)
	check(not save.blocked and reloaded.stock["bread"] == 50 and reloaded.capacity("bread") == 50, "Load upgraded inventory beyond original base capacity")
	var invalid: Dictionary = upgraded_save.duplicate(true)
	invalid["shelf_upgrades"]["pantry"] = 100
	check(not reloaded.restore(invalid) and reloaded.capacity("bread") == 50, "Reject invalid upgrade level without mutating live state")
	invalid = upgraded_save.duplicate(true)
	invalid["retained_unlocks"] = ["not_a_product"]
	check(not reloaded.restore(invalid), "Reject forged unknown retained product")
	var legacy: Dictionary = ShopEconomy.new().snapshot()
	legacy["schema_version"] = 2
	legacy.erase("shelf_upgrades")
	legacy.erase("retained_unlocks")
	legacy.erase("upgrade_spending")
	check(reloaded.restore(JSON.parse_string(JSON.stringify(legacy))) and reloaded.unlocked_count() == 10 and reloaded.shop_level() == 1 and reloaded.upgrade_count() == 0, "Migrated Phase 2 retains access to all products")
	var migrated: ShopEconomy = ShopEconomy.new()
	check(migrated.restore(JSON.parse_string(JSON.stringify(reloaded.snapshot()))) and migrated.unlocked_count() == 10, "Retained prior access survives subsequent schema 3 load")
	var bad_progression: Dictionary = economy.progression.config.duplicate(true)
	bad_progression["levels"][1]["xp"] = 0
	check(not ShopProgression.validate(bad_progression).is_empty(), "Reject non-increasing XP thresholds")
	var bad_upgrades: Array = economy.upgrade_rules.definitions.duplicate(true)
	bad_upgrades[0]["base_cost"] = -1
	check(not ShelfUpgrades.validate(bad_upgrades).is_empty(), "Reject invalid configured upgrade cost")
	economy.reset()
	check(economy.next_objective().contains("Buy your first stock"), "Fresh next objective guides stocking")
	economy.buy("bread", 1)
	check(economy.goals()[0]["complete"] and economy.next_objective().contains("10 customers"), "Goal progress moves to next meaningful objective")
	game.economy = ShopEconomy.new()
	main.customers.clear()
	main._show_upgrades()
	check(not game.running and main.upgrades_screen.upgrade_buttons.size() == 3 and main.upgrades_screen.goal_labels.size() == 6, "Growth screen pauses customers and shows upgrades and goals")
	main.upgrades_screen.upgrade_buttons["pantry"].pressed.emit()
	check(game.economy.coins == 380 and game.economy.capacity("bread") == 30 and main.upgrades_screen.upgrade_buttons["pantry"].disabled, "Upgrade button applies transaction and refreshes requirement state")
	var saved_upgrade: ShopEconomy = ShopEconomy.new()
	game.storage.load_into(saved_upgrade)
	check(saved_upgrade.shelf_upgrades["pantry"] == 1 and saved_upgrade.coins == 380, "Upgrade saves immediately after purchase")
	main._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(main.on_shop and game.running and main.stock_labels["bread"].text.contains("/30"), "Back from growth screen returns to updated shop")
	main._show_inventory()
	check(main.inventory_screen.singles["soap"].disabled and main.inventory_screen.batches["soap"].text.contains("Level 5") and main.inventory_screen.stocks["bread"].text.contains("30"), "Inventory shows locks and upgraded capacity")
	main._show_shop()
	game.economy.reset()
	game.buy("bread", 10)
	for index: int in 10:
		game.sell("bread")
	check(main.level_dialog.visible and not game.running and main.level_dialog.dialog_text.contains("Level 2"), "Level-up signal opens feedback and pauses simulation")
	main._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(not main.level_dialog.visible and game.running, "Dismiss level-up feedback safely resumes shop")
	main._restart()
	check(game.economy.shop_level() == 1 and game.economy.capacity("bread") == 20 and game.economy.upgrade_spending == 0 and game.economy.unlocked_count() == 3, "Reset clears progression, upgrades and retained unlocks")
	var playthrough: ShopEconomy = ShopEconomy.new()
	playthrough.buy_upgrade("pantry")
	var valid_run: bool = true
	for index: int in 170:
		if playthrough.stock["bread"] == 0:
			valid_run = valid_run and playthrough.buy("bread", 20).is_empty()
		valid_run = valid_run and playthrough.sell("bread")
	check(valid_run and playthrough.shop_level() == 6 and playthrough.unlocked_count() == 10, "Deterministic fresh-shop playthrough reaches maximum level without running out of funds")
	var all_complete: bool = true
	for goal: Dictionary in playthrough.goals():
		all_complete = all_complete and bool(goal["complete"])
	check(all_complete and playthrough.next_objective().contains("All milestones"), "All progression goals can be completed in normal transactions")
	check(playthrough.coins == 500 + playthrough.revenue - playthrough.stock_spending - playthrough.upgrade_spending, "Full playthrough reconciles cash, sales, stock orders and upgrades")
