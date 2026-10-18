extends SceneTree
## Optional rendered smoke test; uses isolated progress, never the player's save.
func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var test_path: String = "user://capture-tests"
	DirAccess.make_dir_recursive_absolute(test_path)
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	game.storage = LocalSave.new(test_path)
	root.size = Vector2i(480, 900)
	var main: Control = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/menu-preview.png")
	main._show_shop()
	game.buy("bread")
	game.buy("milk")
	game.buy("apples")
	for tick: int in 70:
		main.customers._tick()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/shop-preview.png")
	root.size = Vector2i(360, 640)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/compact-preview.png")
	root.size = Vector2i(480, 900)
	main._show_inventory()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/inventory-preview.png")
	main.inventory_screen.list_scroll.scroll_vertical = 10000
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/inventory-bottom-preview.png")
	root.size = Vector2i(360, 640)
	main.inventory_screen.list_scroll.scroll_vertical = 0
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/inventory-compact-preview.png")
	root.size = Vector2i(480, 900)
	main._show_upgrades()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/upgrades-preview.png")
	game.buy_upgrade("pantry")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/upgrades-purchased-preview.png")
	main.page_scroll.scroll_vertical = 10000
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/goals-preview.png")
	root.size = Vector2i(360, 640)
	main.page_scroll.scroll_vertical = 0
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/upgrades-compact-preview.png")
	root.size = Vector2i(480, 900)
	game.economy.reset()
	main.customers.clear()
	main._show_shop()
	game.buy("bread", 10)
	for index: int in 10:
		game.sell("bread")
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/level-up-preview.png")
	print("UI captures saved in docs/")
	quit()
