extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var game: Node = root.get_node("Game")
	var folder: String = "user://world-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.economy = ShopEconomy.new()
	game.storage = LocalSave.new(folder)
	root.size = Vector2i(480, 900)
	var scene: Node2D = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/world-preview.png")
	scene.world.player.position = Vector2(170, 425)
	scene.world.camera.update_follow(0.0, true)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/world-machine-preview.png")
	scene.open_menu()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/world-menu-preview.png")
	scene.close_menu()
	root.size = Vector2i(360, 640)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/world-compact-preview.png")
	root.size = Vector2i(480, 1040)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/world-tall-preview.png")
	print("World captures saved")
	quit()
