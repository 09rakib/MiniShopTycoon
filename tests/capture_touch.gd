extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func capture(path: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func _capture() -> void:
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	var folder: String = "user://touch-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	root.size = Vector2i(480, 900)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	await capture("res://docs/touch-idle-preview.png")
	var press: InputEventScreenTouch = InputEventScreenTouch.new()
	press.index = 3
	press.position = Vector2(340, 690)
	press.pressed = true
	Input.parse_input_event(press)
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 3
	drag.position = Vector2(375, 650)
	Input.parse_input_event(drag)
	await capture("res://docs/touch-floating-preview.png")
	press.pressed = false
	Input.parse_input_event(press)
	for index: int in 5:
		game.economy.production.produce_one()
	scene.world.player.position = game.economy.handling.station_point("pickup")
	scene.world.camera.update_follow(0, true)
	scene._check_nearby()
	await capture("res://docs/touch-auto-pickup-preview.png")
	scene.world.player.position = game.economy.handling.station_point("deliver")
	scene.world.camera.update_follow(0, true)
	scene._check_nearby()
	await capture("res://docs/touch-auto-serve-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/touch-compact-preview.png")
	scene.queue_free()
	await process_frame
	print("Touch captures saved")
	quit()
