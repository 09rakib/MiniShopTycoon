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
	var folder: String = "user://current-menu-preview"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	root.size = Vector2i(480, 900)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	scene.open_menu()
	await create_timer(0.2).timeout
	await capture("res://docs/current-menu-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/current-menu-compact-preview.png")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
