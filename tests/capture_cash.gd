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
	var folder: String = "user://cash-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	root.size = Vector2i(480, 900)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	scene.world.player.position = Vector2(350, 740)
	scene.world.camera.update_follow(0, true)
	for index: int in 4:
		game.economy.handling.counter = 1
		var ticket: int = game.economy.burger_sales.register_customer()
		game.sell_burger(ticket)
		game.economy.burger_sales.retire(ticket)
	await capture("res://docs/cash-waiting-preview.png")
	scene.world.player.position = game.economy.cash_pickup.point
	scene.world.camera.update_follow(0, true)
	scene._try_collect_cash()
	await capture("res://docs/cash-collected-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/cash-compact-preview.png")
	scene.queue_free()
	await process_frame
	print("Cash captures saved")
	quit()
