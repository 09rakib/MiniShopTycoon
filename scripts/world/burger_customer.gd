class_name BurgerCustomer
extends CharacterBody2D
enum State { ENTERING, QUEUING, WAITING_FOR_STOCK, BUYING, LEAVING }
var state: State = State.ENTERING
var ticket: int
var target: Vector2
var elapsed: float = 0
var route_elapsed: float = 0
var phase: float = 0
var paused: bool = false
var paid: bool = false
var speed: float = 115
var exit_stage: int = 0
var patience_seconds: float = 35
var hint_clock: float = 0
var shirt_style: StyleBoxFlat = StyleBoxFlat.new()

func _ready() -> void:
	shirt_style.set_corner_radius_all(9)
	collision_layer = 0
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 12
	shape.shape = circle
	add_child(shape)

func at_target() -> bool:
	return position.distance_to(target) < 3

func _physics_process(delta: float) -> void:
	if paused:
		return
	elapsed += delta
	if state == State.WAITING_FOR_STOCK:
		hint_clock += delta
		if hint_clock >= 0.25:
			hint_clock = 0
			queue_redraw()
	if not at_target():
		route_elapsed += delta
		velocity = (target - position).limit_length(speed * delta) / delta
		move_and_slide()
		phase += delta * 10
		queue_redraw()
	else:
		velocity = Vector2.ZERO
		route_elapsed = 0

func _draw() -> void:
	var colors: Array[Color] = [Color("748db5"), Color("b97867"), Color("8a9c65"), Color("9a80a7")]
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 19, Color(0.1, 0.2, 0.15, 0.18))
	draw_set_transform(Vector2.ZERO)
	var step: float = sin(phase) * 3 if velocity.length() > 1 else 0.0
	draw_line(Vector2(-7, -14), Vector2(-7, step), Color("354d50"), 9, true)
	draw_line(Vector2(7, -14), Vector2(7, -step), Color("354d50"), 9, true)
	shirt_style.bg_color = colors[ticket % 4]
	draw_style_box(shirt_style, Rect2(-16, -39, 32, 29))
	draw_circle(Vector2(0, -50), 14, Color("eac19c"))
	draw_arc(Vector2(0, -53), 13, PI, TAU, 16, Color("604d40"), 7, true)
	draw_circle(Vector2(-5, -49), 1.5, Color("384e45"))
	draw_circle(Vector2(5, -49), 1.5, Color("384e45"))
	if paid:
		shirt_style.bg_color = Color("b88450")
		draw_style_box(shirt_style, Rect2(13, -28, 18, 23))
		draw_arc(Vector2(22, -28), 6, PI, TAU, 12, Color("d9af73"), 3, true)
		draw_line(Vector2(17, -16), Vector2(27, -16), Color("f4dda8"), 3)
	var label: String = "THANKS" if paid else "WAIT" if state == State.WAITING_FOR_STOCK else "BUY" if state == State.BUYING else ""
	if not label.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(22, -43), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("315e4a"))

	if state == State.WAITING_FOR_STOCK:
		var remaining: float = clampf(1 - elapsed / patience_seconds, 0, 1)
		draw_rect(Rect2(22, -36, 28, 4), Color("d1bfa0"))
		draw_rect(Rect2(22, -36, 28 * remaining, 4), Color("b78051") if remaining < 0.25 else Color("739d72"))
