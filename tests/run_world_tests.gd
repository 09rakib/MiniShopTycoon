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

func frames(count: int) -> void:
	for index: int in count:
		await physics_frame

func _run() -> void:
	root.size = Vector2i(480, 900)
	var game: Node = root.get_node("Game")
	var folder: String = "user://world-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	game.economy = ShopEconomy.new()
	game.buy("bread", 5)
	var saved_coins: int = game.economy.coins
	var scene: Node2D = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	await frames(3)
	var player: CharacterBody2D = scene.world.player
	check(is_instance_valid(player) and scene.world.fixtures.size() == 4, "Playable entry creates worker, bounded room and four fixtures")
	check(game.economy.coins == saved_coins and game.economy.stock["bread"] == 5 and not game.running, "Entering new world preserves existing stock and money; old sales remain off")
	var joystick: Control = scene.joystick
	var press: InputEventScreenTouch = InputEventScreenTouch.new()
	press.index = 1
	press.pressed = true
	press.position = joystick.size / 2 + Vector2(54, 0)
	joystick._gui_input(press)
	check(joystick.finger == 1 and joystick.direction.is_equal_approx(Vector2.RIGHT), "Joystick captures touch beginning inside its control")
	var second: InputEventScreenTouch = InputEventScreenTouch.new()
	second.index = 2
	second.pressed = true
	second.position = Vector2.ZERO
	joystick._input(second)
	check(joystick.finger == 1 and joystick.direction == Vector2.RIGHT, "Unrelated UI touch does not steal joystick")
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 1
	drag.position = joystick.get_global_transform_with_canvas() * (joystick.size / 2 + Vector2(200, 200))
	joystick._input(drag)
	check(is_equal_approx(joystick.direction.length(), 1.0) and joystick.direction.x > 0 and joystick.direction.y > 0, "Diagonal drag clamps to unit magnitude")
	var release: InputEventScreenTouch = InputEventScreenTouch.new()
	release.index = 2
	release.pressed = false
	joystick._input(release)
	check(not joystick.direction.is_zero_approx(), "Releasing a second finger preserves captured movement")
	release.index = 1
	joystick._input(release)
	await frames(2)
	check(joystick.direction == Vector2.ZERO and player.velocity.is_zero_approx(), "Release outside joystick stops worker")
	joystick._gui_input(press)
	release.pressed = true
	release.canceled = true
	joystick._input(release)
	check(joystick.finger == -1 and joystick.direction == Vector2.ZERO, "Touch cancellation releases captured input")
	joystick._gui_input(press)
	joystick._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	check(joystick.direction == Vector2.ZERO, "Joystick releases on application pause")
	# Exercise actual viewport dispatch, not only direct method calls.
	var routed_press: InputEventScreenTouch = InputEventScreenTouch.new()
	routed_press.index = 3
	routed_press.pressed = true
	routed_press.position = joystick.get_global_transform_with_canvas() * (joystick.size / 2)
	Input.parse_input_event(routed_press)
	await process_frame
	await process_frame
	check(joystick.finger == 3 and joystick.direction.is_zero_approx(), "Viewport routes centered joystick press without unintended motion")
	var routed_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	routed_drag.index = 3
	routed_drag.position = routed_press.position + Vector2(0, -54)
	Input.parse_input_event(routed_drag)
	await process_frame
	check(joystick.direction.is_equal_approx(Vector2.UP), "Viewport-routed upward drag maps to upward movement")
	routed_press.pressed = false
	Input.parse_input_event(routed_press)
	await process_frame
	check(joystick.direction.is_zero_approx(), "Viewport-routed release stops joystick")
	player.position = Vector2(340, 730)
	player.set_move_vector(Vector2.RIGHT)
	await frames(4)
	var straight_speed: float = player.velocity.length()
	player.set_move_vector(Vector2(1, 1))
	await frames(4)
	check(is_equal_approx(player.velocity.length(), straight_speed), "Diagonal movement is not faster than straight movement")
	player.set_move_vector(Vector2.ZERO)
	await frames(2)
	check(player.velocity == Vector2.ZERO, "Worker stops predictably without drift")
	player.position = Vector2(170, 450)
	player.set_move_vector(Vector2.UP)
	await frames(55)
	check(player.position.y >= 384.5 and player.position.y < 400, "Burger machine solid footprint blocks worker")
	player.stop()
	player.position = Vector2(550, 650)
	player.set_move_vector(Vector2.UP)
	await frames(55)
	check(player.position.y >= 574.5 and player.position.y < 590, "Serving counter blocks worker")
	player.stop()
	player.position = Vector2(100, 730)
	player.set_move_vector(Vector2.LEFT)
	await frames(45)
	check(player.position.x >= 60.5 and player.position.x < 70, "Left wall cannot be crossed")
	player.stop()
	player.position = Vector2(730, 730)
	player.set_move_vector(Vector2.RIGHT)
	await frames(45)
	check(player.position.x <= 759.5 and player.position.x > 750, "Right wall cannot be crossed")
	player.stop()
	player.position = Vector2(340, 230)
	player.set_move_vector(Vector2.UP)
	await frames(30)
	check(player.position.y >= 206.5 and player.position.y < 220, "Back wall cannot be crossed")
	player.stop()
	player.position = Vector2(340, 930)
	player.set_move_vector(Vector2.DOWN)
	await frames(30)
	check(player.position.y <= 963.5 and player.position.y > 950, "Entrance boundary cannot be crossed")
	player.stop()
	player.position = Vector2(320, 430)
	player.set_move_vector(Vector2.DOWN)
	await frames(40)
	check(player.position.y > 550, "Clear route between machine and counter is walkable")
	player.stop()
	var camera: Camera2D = scene.world.camera
	for target_position: Vector2 in [Vector2(61, 207), Vector2(759, 963), Vector2(400, 600)]:
		player.position = target_position
		camera.update_follow(0.0, true)
		var half: Vector2 = root.get_visible_rect().size / camera.zoom / 2
		check(camera.position.x - half.x >= -0.1 and camera.position.y - half.y >= -0.1 and camera.position.x + half.x <= 820.1 and camera.position.y + half.y <= 1200.1, "Camera view stays within decorated room at " + str(target_position))
	player.position = Vector2(200, 500)
	camera.update_follow(0, true)
	var previous_camera: Vector2 = camera.position
	player.position = Vector2(600, 600)
	camera.update_follow(1.0 / 60.0)
	check(camera.position.x > previous_camera.x and camera.position.x < camera.desired_position().x, "Camera follows smoothly without snapping")
	joystick._gui_input(press)
	scene.open_menu()
	check(player.controls_blocked and joystick.direction == Vector2.ZERO and scene.menu.visible, "Menu immediately releases and blocks movement")
	var stationary: Vector2 = player.position
	await frames(3)
	check(player.position.is_equal_approx(stationary), "Player remains still under management overlay")
	scene.close_menu()
	check(not player.controls_blocked and not scene.menu.visible, "Closing menu resumes existing world")
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(player.controls_blocked and player.move_vector == Vector2.ZERO, "Focus loss safely clears movement")
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(not player.controls_blocked and player.move_vector == Vector2.ZERO, "Resume waits for fresh input")
	var saved_position: Vector2 = player.position
	scene.open_menu()
	scene._open_legacy("inventory")
	check(scene.legacy.embedded and scene.legacy.on_inventory and player.controls_blocked, "Existing inventory opens inside management without losing world")
	check(game.economy.coins == saved_coins and game.economy.stock["bread"] == 5, "Opening inventory does not alter existing economy")
	scene._close_legacy()
	scene.close_menu()
	check(player.position.is_equal_approx(saved_position) and not game.running, "Return from grocery panels preserves player position and disables old automatic sales")
	var restored: ShopEconomy = ShopEconomy.new()
	game.storage.load_into(restored)
	check(restored.coins == saved_coins and restored.stock["bread"] == 5, "Existing schema-3 progress remains save/load compatible")
	scene.queue_free()
	await process_frame
	print("WORLD RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
