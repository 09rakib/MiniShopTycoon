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
	var folder: String = "user://handling-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	game.economy = ShopEconomy.new()
	root.size = Vector2i(480, 900)
	var scene: Node2D = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	for index: int in 5:
		game.economy.production.produce_one()
	scene.world.player.position = game.economy.handling.station_point("pickup")
	scene.world.camera.update_follow(0, true)
	scene._update_location()
	await capture("res://docs/pickup-preview.png")
	scene._check_nearby()
	await capture("res://docs/carry-preview.png")
	scene.world.player.position = game.economy.handling.station_point("deliver")
	scene.world.camera.update_follow(0, true)
	scene._update_location()
	await capture("res://docs/delivery-preview.png")
	scene._check_nearby()
	await capture("res://docs/counter-stock-preview.png")
	game.economy.handling.counter = 7
	game.economy.handling.carried = 2
	game.handling_changed.emit()
	scene._update_location()
	scene._check_nearby()
	await capture("res://docs/counter-full-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/handling-compact-preview.png")
	print("Handling captures saved")
	quit()
