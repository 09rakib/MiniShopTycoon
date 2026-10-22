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
	var folder: String = "user://polish-capture"
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	root.size = Vector2i(480, 900)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	game.economy.production.produce_one()
	scene.world.player.position = game.economy.handling.station_point("pickup")
	scene.world.camera.update_follow(0, true)
	scene._check_nearby()
	await capture("res://docs/polish-pickup-preview.png")
	scene.world.player.position = game.economy.handling.station_point("deliver")
	scene.world.camera.update_follow(0, true)
	scene._check_nearby()
	var customer: BurgerCustomer = BurgerCustomer.new()
	customer.ticket = game.economy.burger_sales.register_customer()
	customer.position = Vector2(520, 620)
	customer.target = customer.position
	customer.paused = true
	customer.paid = game.sell_burger(customer.ticket)
	scene.world.actors.add_child(customer)
	await capture("res://docs/polish-sale-preview.png")
	customer.paid = false
	customer.state = BurgerCustomer.State.WAITING_FOR_STOCK
	customer.elapsed = 28
	customer.queue_redraw()
	await capture("res://docs/polish-patience-preview.png")
	scene.open_menu()
	await create_timer(0.2).timeout
	await capture("res://docs/polish-menu-preview.png")
	root.size = Vector2i(360, 640)
	await capture("res://docs/polish-menu-compact-preview.png")
	scene.queue_free()
	await process_frame
	await process_frame
	quit()
