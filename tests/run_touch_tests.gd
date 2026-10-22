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

func touch(index: int, point: Vector2, pressed: bool = true) -> InputEventScreenTouch:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	return event

func _run() -> void:
	root.size = Vector2i(480, 900)
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	var folder: String = "user://touch-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	await process_frame
	await process_frame
	var joystick: Control = scene.joystick
	check(not joystick.active() and joystick.direction.is_zero_approx(), "Joystick initially draws nothing and does not move worker")
	check(scene.top_hud.size.y <= 80 and scene.menu_button.size.y >= 44, "Compact two-line HUD preserves touch-friendly menu with under-80px content height")
	check(joystick.BASE_ALPHA <= 0.2 and joystick.THUMB_ALPHA <= 0.35, "Floating joystick uses low-opacity base and thumb")
	Input.parse_input_event(touch(4, Vector2(390, 700)))
	await process_frame
	check(joystick.finger == 4 and joystick.center.is_equal_approx(Vector2(390, 700)) and joystick.direction.is_zero_approx(), "Actual right-side touch spawns joystick at touched location without jump")
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 4
	drag.position = Vector2(390, 646)
	Input.parse_input_event(drag)
	await physics_frame
	await physics_frame
	check(joystick.direction.is_equal_approx(Vector2.UP) and scene.world.player.velocity.y < 0, "Floating right-side joystick drives actual worker upward")
	Input.parse_input_event(touch(4, Vector2(0, 0), false))
	await physics_frame
	await physics_frame
	check(not joystick.active() and scene.world.player.velocity == Vector2.ZERO, "Release anywhere hides joystick and stops worker")
	joystick._unhandled_input(touch(5, Vector2(80, 300)))
	check(joystick.center == Vector2(80, 300) and joystick.finger == 5, "Next gesture relocates joystick to another screen area")
	joystick._unhandled_input(touch(6, Vector2(300, 400)))
	joystick._input(touch(6, Vector2.ZERO, false))
	check(joystick.finger == 5 and joystick.center == Vector2(80, 300), "Other finger cannot recenter or release captured gesture")
	joystick._set_offset(Vector2(3, 2))
	check(joystick.direction.is_zero_approx(), "Small initial finger jitter stays in dead zone")
	joystick._set_offset(Vector2(300, 300))
	check(is_equal_approx(joystick.direction.length(), 1.0), "Large diagonal drag cannot increase movement speed")
	var canceled: InputEventScreenTouch = touch(5, Vector2.ZERO)
	canceled.canceled = true
	joystick._input(canceled)
	check(not joystick.active() and joystick.direction.is_zero_approx(), "Touch cancellation hides floating joystick")
	var menu_point: Vector2 = scene.menu_button.get_global_transform_with_canvas() * (scene.menu_button.size * 0.5)
	Input.parse_input_event(touch(7, menu_point))
	await process_frame
	check(not joystick.active(), "Actual Menu touch cannot start movement or floating joystick")
	Input.parse_input_event(touch(7, menu_point, false))
	await process_frame
	await process_frame
	if scene.menu.visible:
		scene.close_menu()
	scene.open_menu()
	joystick._unhandled_input(touch(8, Vector2(200, 500)))
	check(not joystick.active() and not joystick.enabled, "Management overlay disables world touch capture")
	scene.close_menu()
	joystick._unhandled_input(touch(9, Vector2(200, 600)))
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not joystick.active() and scene.world.player.move_vector == Vector2.ZERO and not joystick.enabled, "Focus loss cancels captured touch and clears movement immediately")
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(joystick.enabled and not joystick.active(), "Resume requires fresh touch instead of restoring old gesture")
	scene.production_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	for index: int in 5:
		game.economy.production.produce_one()
	scene.world.player.position = game.economy.handling.station_point("pickup")
	await create_timer(0.22).timeout
	check(game.economy.handling.carried == 2 and game.economy.production.stock == 3 and scene.world.player.carried_count == 2, "Real proximity timer automatically collects two burgers with no tap")
	await create_timer(0.22).timeout
	check(game.economy.production.stock == 3 and game.economy.handling.carried == 2, "Standing at machine with full hands cannot duplicate pickup")
	var loaded: ShopEconomy = ShopEconomy.new()
	game.storage.load_into(loaded)
	check(loaded.handling.carried == 2 and loaded.production.stock == 3, "Automatic pickup saves both sides immediately")
	scene.world.player.position = game.economy.handling.station_point("deliver")
	await create_timer(0.22).timeout
	check(game.economy.handling.carried == 0 and game.economy.handling.counter == 2 and scene.world.player.carried_count == 0, "Counter proximity automatically serves held burgers with no tap")
	game.economy.handling.carried = 2
	game.economy.handling.counter = 7
	await create_timer(0.22).timeout
	check(game.economy.handling.carried == 1 and game.economy.handling.counter == 8, "Automatic partial delivery preserves remaining burger")
	await create_timer(0.22).timeout
	check(game.economy.handling.carried == 1 and game.economy.handling.counter == 8, "Full counter never discards held remainder during repeated polls")
	scene.world.player.position = game.economy.handling.station_point("pickup")
	scene.open_menu()
	await create_timer(0.22).timeout
	check(game.economy.handling.carried == 1 and game.economy.production.stock == 3, "Menu blocks automatic item pickup even while nearby")
	scene.close_menu()
	scene.suspended = true
	scene._check_nearby()
	check(game.economy.handling.carried == 1 and game.economy.production.stock == 3, "Suspended app cannot auto-transfer food")
	scene.suspended = false
	scene.world.player.position = Vector2(350, 800)
	scene._check_nearby()
	check(game.economy.handling.carried == 1 and game.economy.production.stock == 3, "Current worker position controls automatic pickup; no stale hint authority")
	game.economy.handling.carried = 0
	game.economy.coins = 1000
	game.purchase_expansion("fries")
	scene.fries_controller.set_paused(true)
	game.economy.expansion.production.produce_one()
	game.economy.expansion.production.produce_one()
	scene.world.player.position = game.economy.expansion.handling.station_point("pickup")
	await create_timer(0.22).timeout
	check(game.economy.expansion.handling.carried == 2 and game.economy.expansion.production.stock == 0 and scene.world.player.fries_count == 2, "Fries also collects automatically with correct visible product")
	scene.world.player.position = game.economy.handling.station_point("deliver")
	await create_timer(0.22).timeout
	check(game.economy.expansion.handling.carried == 0 and game.economy.expansion.handling.counter == 2, "Fries auto-serves into its own shelf even when burger shelf is full")
	var ticket: int = game.economy.burger_sales.register_customer()
	game.sell_burger(ticket)
	game.economy.burger_sales.retire(ticket)
	var pending: int = game.economy.burger_sales.uncollected_cash
	var before: int = game.economy.coins
	scene.world.player.position = game.economy.cash_pickup.point
	await create_timer(0.22).timeout
	check(game.economy.coins == before + pending and game.economy.burger_sales.uncollected_cash == 0, "Existing automatic cash collection credits exact proceeds without tapping")
	game.storage.load_into(loaded)
	check(loaded.coins == game.economy.coins and loaded.burger_sales.uncollected_cash == 0, "Automatic service/cash changes survive restart")
	root.size = Vector2i(360, 640)
	await process_frame
	await process_frame
	check(scene.top_hud.get_global_rect().end.x <= root.get_visible_rect().size.x + 1 and scene.top_hud.size.y <= 80, "Compact HUD fits smaller portrait viewport without growing into world")
	scene.queue_free()
	await process_frame
	print("TOUCH RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
