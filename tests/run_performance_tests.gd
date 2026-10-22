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
	var worker: WorkerCharacter = WorkerCharacter.new()
	var style: StyleBoxFlat = worker._style(Color("fffaf0"), 8)
	var stable: bool = true
	for index: int in 10000:
		stable = worker._style(Color("fffaf0"), 8) == style and stable
	check(stable and worker.style_cache.size() == 1, "Ten thousand worker style lookups reuse a single resource")
	check(style.bg_color == Color("fffaf0") and style.corner_radius_top_left == 8, "Cached style preserves original palette and geometry")
	check(worker._style(Color("fffaf0"), 9) != style and worker._style(Color("c36c52"), 8) != style, "Different color/radius combinations cannot alias")
	worker.free()
	var fixture: ShopFixture = ShopFixture.new()
	style = fixture.panel_style(Color("c36c52"), 3)
	stable = true
	for index: int in 10000:
		stable = fixture.panel_style(Color("c36c52"), 3) == style and stable
	check(stable and fixture.style_cache.size() == 1, "Ten thousand fixture style lookups reuse a single resource")
	check(style.bg_color == Color("c36c52") and style.corner_radius_top_left == 3, "Cached fixture art retains color/radius")
	fixture.free()
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	var folder: String = "user://performance-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	game.economy.coins = 2000
	game.economy.purchase_operation("stocker")
	game.economy.purchase_expansion("fries")
	game.economy.purchase_expansion("furniture")
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	scene.stocker_controller.set_paused(true)
	for index: int in 1000:
		scene.customer_controller.spawn_customer()
	check(scene.customer_controller.visitors.size() == 0, "Paused spawner ignores repeated wakeups")
	scene.customer_controller.set_paused(false)
	for index: int in 1000:
		scene.customer_controller.spawn_customer()
	scene.customer_controller.set_paused(true)
	check(scene.customer_controller.visitors.size() == 4 and game.economy.burger_sales.tickets.size() == 4, "Customer and ticket pools remain bounded at four under spawn spam")
	await process_frame
	var nodes: int = get_node_count()
	for index: int in 5:
		scene.open_menu()
		scene._open_legacy("inventory")
		await process_frame
		scene._close_legacy()
		scene.close_menu()
		await process_frame
	check(get_node_count() == nodes, "Repeated grocery overlay open/close releases all overlay nodes")
	var audio: Node = scene.audio
	for index: int in 5000:
		audio.play("unknown_" + str(index))
	check(audio.last_play.size() <= 8 and audio.voices.size() == 4, "Unknown audio events cannot grow cooldown map or voice pool")
	check(scene.world.cues.size() == 4 and get_node_count() < 180, "Expanded shop remains within measured structural node budget")
	scene.queue_free()
	await process_frame
	await process_frame
	print("PERFORMANCE BOUNDS RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
