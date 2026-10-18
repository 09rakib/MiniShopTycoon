class_name WorkerCharacter
extends CharacterBody2D
var move_vector: Vector2 = Vector2.ZERO
var controls_blocked: bool = false
var speed: float = 205.0
var radius: float = 15.0
var facing: Vector2 = Vector2.DOWN
var walk_phase: float = 0.0
var was_walking: bool = false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	add_child(shape)

func set_move_vector(value: Vector2) -> void:
	move_vector = value.limit_length(1.0)

func stop() -> void:
	move_vector = Vector2.ZERO
	velocity = Vector2.ZERO
	was_walking = false
	queue_redraw()

func input_direction() -> Vector2:
	if controls_blocked:
		return Vector2.ZERO
	var result: Vector2 = move_vector
	if not OS.has_feature("android") and result.is_zero_approx():
		result = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	return result.limit_length(1.0)

func _physics_process(delta: float) -> void:
	velocity = input_direction() * speed
	move_and_slide()
	var walking: bool = velocity.length_squared() > 1.0
	if walking:
		facing = velocity.normalized()
		walk_phase += delta * 12
		queue_redraw()
	elif was_walking:
		walk_phase = 0
		queue_redraw()
	was_walking = walking

func _draw() -> void:
	var step: float = sin(walk_phase) * 4.5 if was_walking else 0.0
	var bounce: float = absf(sin(walk_phase)) * 2 if was_walking else 0.0
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.38))
	draw_circle(Vector2(0, 4), 21, Color(0.12, 0.22, 0.17, 0.20))
	draw_set_transform(Vector2.ZERO)
	draw_style_box(_style(Color("244e43"), 5), Rect2(-13, -11 + step, 11, 16))
	draw_style_box(_style(Color("244e43"), 5), Rect2(2, -11 - step, 11, 16))
	draw_style_box(_style(Color("f0b66a"), 10), Rect2(-18, -42 - bounce, 36, 34))
	draw_style_box(_style(Color("f9ead0"), 5), Rect2(-10, -33 - bounce, 20, 25))
	draw_line(Vector2(-15, -32 - bounce), Vector2(-21, -15 - bounce - step), Color("f2c597"), 10, true)
	draw_line(Vector2(15, -32 - bounce), Vector2(21, -15 - bounce + step), Color("f2c597"), 10, true)
	draw_circle(Vector2(0, -51 - bounce), 16, Color("f2c597"))
	if facing.y < -0.25:
		draw_arc(Vector2(0, -53 - bounce), 13, 0, PI, 20, Color("665342"), 9, true)
	else:
		var eye_offset: float = facing.x * 4
		draw_circle(Vector2(-5 + eye_offset, -49 - bounce), 1.8, Color("385045"))
		draw_circle(Vector2(5 + eye_offset, -49 - bounce), 1.8, Color("385045"))
	draw_style_box(_style(Color("fffaf0"), 8), Rect2(-19, -70 - bounce, 38, 17))
	draw_style_box(_style(Color("fffaf0"), 9), Rect2(-12, -79 - bounce, 24, 17))
	draw_line(Vector2(-17, -55 - bounce), Vector2(17, -55 - bounce), Color("e9d8b9"), 3)

func _style(color: Color, radius: int) -> StyleBoxFlat:
	var value: StyleBoxFlat = StyleBoxFlat.new()
	value.bg_color = color
	value.set_corner_radius_all(radius)
	return value
