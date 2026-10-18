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
	var folder: String = "user://customer-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	root.size = Vector2i(480, 900)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	var controller: Node = scene.customer_controller
	controller.spawn_timer.stop()
	for index: int in 4:
		controller.spawn_customer()
	for visitor: BurgerCustomer in controller.visitors:
		visitor.speed = 1400
	for frame: int in 55:
		await physics_frame
	controller.set_paused(true)
	scene.world.player.position = Vector2(470, 740)
	scene.world.camera.update_follow(0, true)
	scene._refresh()
	await capture("res://docs/customer-queue-preview.png")
	game.economy.handling.counter = 2
	game.handling_changed.emit()
	controller.set_paused(false)
	for frame: int in 100:
		await physics_frame
	controller.set_paused(true)
	await capture("res://docs/customer-sale-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/customer-compact-preview.png")
	scene.queue_free()
	await process_frame
	print("Customer captures saved")
	quit()
