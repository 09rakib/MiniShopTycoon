class_name ShopWorld
extends Node2D
var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_layout.json"))
var player: WorkerCharacter
var camera: ShopCamera
var actors: Node2D
var fixtures: Array[ShopFixture] = []

func _ready() -> void:
	add_child(ShopFloor.new())
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
	_refresh_machine()
	_refresh_handling()

func _refresh_machine() -> void:
	for fixture: ShopFixture in fixtures:
		if fixture.definition["id"] == "burger_machine":
			fixture.production = Game.economy.production
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
	for fixture: ShopFixture in fixtures:
		if fixture.definition["id"] == "serving_counter":
			fixture.handling = Game.economy.handling
			fixture.queue_redraw()
