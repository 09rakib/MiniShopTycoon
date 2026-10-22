class_name ShopWorld
extends Node2D
var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_layout.json"))
var player: WorkerCharacter
var camera: ShopCamera
var actors: Node2D
var fixtures: Array[ShopFixture] = []
var cash_reward: Label
var floor_art: ShopFloor
var reward_tween: Tween

func _ready() -> void:
	floor_art = ShopFloor.new()
	add_child(floor_art)
	for wall: Array in layout["walls"]:
		var body: StaticBody2D = StaticBody2D.new()
		var shape: CollisionShape2D = CollisionShape2D.new()
		var rectangle: RectangleShape2D = RectangleShape2D.new()
		rectangle.size = Vector2(wall[2], wall[3])
		shape.shape = rectangle
		body.position = Vector2(float(wall[0]) + float(wall[2]) / 2, float(wall[1]) + float(wall[3]) / 2)
		body.add_child(shape)
		add_child(body)
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	for definition: Dictionary in layout["fixtures"]:
		var fixture: ShopFixture = ShopFixture.new()
		fixture.definition = definition
		actors.add_child(fixture)
		fixtures.append(fixture)
	Game.production_changed.connect(_refresh_machine)
	Game.handling_changed.connect(_refresh_handling)
	Game.changed.connect(_refresh_cash)
	Game.changed.connect(_sync_expansion)
	Game.cash_collected.connect(_show_cash_reward)
	player = WorkerCharacter.new()
	player.speed = float(layout["player_speed"])
	player.radius = float(layout["player_radius"])
	player.position = Vector2(layout["player_spawn"][0], layout["player_spawn"][1])
	actors.add_child(player)
	camera = ShopCamera.new()
	camera.target = player
	camera.room_size = Vector2(layout["room_size"][0], layout["room_size"][1])
	camera.base_zoom = float(layout["camera_zoom"])
	camera.follow_speed = float(layout["camera_follow_speed"])
	add_child(camera)
	_sync_expansion()
	_refresh_machine()
	_refresh_handling()
	_refresh_cash()
	cash_reward = Label.new()
	cash_reward.z_index = 50
	cash_reward.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cash_reward.add_theme_font_size_override("font_size", 27)
	cash_reward.add_theme_color_override("font_color", Color("265d42"))
	cash_reward.add_theme_color_override("font_outline_color", Color("fff4da"))
	cash_reward.add_theme_constant_override("outline_size", 7)
	cash_reward.hide()
	add_child(cash_reward)

func _refresh_machine() -> void:
	for fixture: ShopFixture in fixtures:
		if fixture.definition["id"] == "burger_machine":
			fixture.production = Game.economy.production
			fixture.queue_redraw()
		elif fixture.definition["id"] == "fries_machine":
			fixture.production = Game.economy.expansion.production
			fixture.queue_redraw()

func location_hint() -> String:
	for definition: Dictionary in layout["fixtures"]:
		if not definition["id"] in ["burger_machine", "serving_counter", "cash_point"]:
			continue
		var point: Vector2 = Vector2(definition["hint_point"][0], definition["hint_point"][1])
		if player.position.distance_to(point) < 100:
			return definition["name"]
	return "Explore your shop"

func _refresh_handling() -> void:
	player.set_carried_count(Game.economy.handling.carried)
	player.fries_count = Game.economy.expansion.handling.carried
	player.queue_redraw()
	for fixture: ShopFixture in fixtures:
		if fixture.definition["id"] == "serving_counter":
			fixture.handling = Game.economy.handling
			fixture.fries_handling = Game.economy.expansion.handling if Game.economy.expansion.unlocked else null
			fixture.queue_redraw()
	_refresh_cash()

func _refresh_cash() -> void:
	for fixture: ShopFixture in fixtures:
		if fixture.definition["id"] == "cash_point":
			fixture.sales = Game.economy.burger_sales
			fixture.queue_redraw()

func _show_cash_reward(amount: int) -> void:
	if reward_tween != null:
		reward_tween.kill()
	cash_reward.text = "+%d" % amount
	cash_reward.position = player.position + Vector2(-40, -100)
	cash_reward.modulate.a = 1
	cash_reward.show()
	reward_tween = create_tween().set_parallel(true)
	reward_tween.tween_property(cash_reward, "position:y", cash_reward.position.y - 42, 1.1)
	reward_tween.tween_property(cash_reward, "modulate:a", 0.0, 0.5).set_delay(0.6)
	reward_tween.chain().tween_callback(cash_reward.hide)

func _sync_expansion() -> void:
	var expansion: ShopExpansion = Game.economy.expansion
	for definition: Dictionary in expansion.config["fixtures"]:
		var owned: bool = expansion.unlocked if definition["id"] == "fries_machine" else expansion.furniture
		var existing: ShopFixture = null
		for fixture: ShopFixture in fixtures:
			if fixture.definition["id"] == definition["id"]:
				existing = fixture
		if owned and existing == null:
			var fixture: ShopFixture = ShopFixture.new()
			fixture.definition = definition
			actors.add_child(fixture)
			fixtures.append(fixture)
		elif not owned and existing != null:
			fixtures.erase(existing)
			existing.queue_free()
	floor_art.fries_unlocked = expansion.unlocked
	floor_art.fries_point = expansion.handling.station_point("pickup")
	floor_art.queue_redraw()
	_refresh_machine()
	_refresh_handling()
