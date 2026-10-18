extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var game: Node = root.get_node("Game")
	var folder: String = "user://production-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	game.economy = ShopEconomy.new()
	root.size = Vector2i(480, 900)
	var scene: Node2D = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.world.player.position = Vector2(170, 425)
	scene.world.camera.update_follow(0, true)
	for index: int in 6:
		game.economy.production.produce_one()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/production-preview.png")
	for index: int in 4:
		game.economy.production.produce_one()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/production-full-preview.png")
	quit()
