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
	var folder: String = "user://operations-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	root.size = Vector2i(480, 900)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	scene.open_menu()
	scene._open_operations()
	await capture("res://docs/workshop-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/workshop-compact-preview.png")
	root.size = Vector2i(480, 900)
	game.economy.coins = 1200
	game.purchase_operation("speed")
	game.purchase_operation("capacity")
	game.purchase_operation("price")
	game.purchase_operation("stocker")
	game.economy.production.stock = 8
	game.production_changed.emit()
	scene.close_menu()
	scene.world.player.position = Vector2(270, 560)
	scene.world.camera.update_follow(0, true)
	await create_timer(1.2).timeout
	scene.stocker_controller.set_paused(true)
	await capture("res://docs/stocker-carry-preview.png")
	scene.open_menu()
	scene._open_operations()
	await capture("res://docs/workshop-hired-preview.png")
	scene.queue_free()
	await process_frame
	print("Operations captures saved")
	quit()
