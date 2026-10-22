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
	var folder: String = "user://expansion-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	root.size = Vector2i(480, 900)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	game.economy.coins = 1000
	scene.open_menu()
	scene._open_expansion()
	await capture("res://docs/expansion-menu-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/expansion-menu-compact-preview.png")
	root.size = Vector2i(480, 900)
	game.purchase_expansion("fries")
	game.purchase_expansion("furniture")
	for index: int in 8:
		game.economy.expansion.production.produce_one()
	scene.close_menu()
	scene.world.player.position = game.economy.expansion.handling.station_point("pickup")
	scene.world.camera.update_follow(0, true)
	scene._update_location()
	scene.action_button.pressed.emit()
	await capture("res://docs/fries-carry-preview.png")
	scene.world.player.position = game.economy.handling.station_point("deliver")
	scene.world.camera.update_follow(0, true)
	scene._update_location()
	scene.action_button.pressed.emit()
	scene.world.player.position = Vector2(300, 720)
	scene._update_location()
	scene.world.camera.update_follow(0, true)
	await capture("res://docs/expanded-shop-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/expanded-shop-compact-preview.png")
	scene.queue_free()
	await process_frame
	print("Expansion captures saved")
	quit()
