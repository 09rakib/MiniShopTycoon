class_name ShopJoystick
extends Control
signal direction_changed(value: Vector2)

var direction: Vector2 = Vector2.ZERO
var finger: int = -1
var mouse_held: bool = false
var enabled: bool = true
const RADIUS: float = 54.0
const DEAD_ZONE: float = 0.12

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(164, 164)

func _gui_input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch and event.pressed and finger < 0 and not mouse_held:
		finger = event.index
		_set_offset(event.position - size * 0.5)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and finger < 0:
		mouse_held = true
		_set_offset(event.position - size * 0.5)
		accept_event()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.index == finger and (not event.pressed or event.canceled):
		release()
	elif event is InputEventScreenDrag and event.index == finger:
		_set_offset(get_global_transform_with_canvas().affine_inverse() * event.position - size * 0.5)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and mouse_held:
		release()
	elif event is InputEventMouseMotion and mouse_held:
		_set_offset(get_global_transform_with_canvas().affine_inverse() * event.position - size * 0.5)

func _set_offset(offset: Vector2) -> void:
	var value: Vector2 = (offset / RADIUS).limit_length(1.0)
	if value.length() < DEAD_ZONE:
		value = Vector2.ZERO
	direction = value
	direction_changed.emit(direction)
	queue_redraw()

func release() -> void:
	finger = -1
	mouse_held = false
	direction = Vector2.ZERO
	direction_changed.emit(direction)
	queue_redraw()

func set_enabled(value: bool) -> void:
	enabled = value
	if not value:
		release()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		release()

func _draw() -> void:
	var center: Vector2 = size * 0.5
	draw_circle(center + Vector2(0, 5), 74, Color(0.12, 0.25, 0.20, 0.10))
	draw_circle(center, 72, Color(0.98, 0.97, 0.9, 0.88))
	draw_arc(center, 71, 0, TAU, 64, Color("d5d9c4"), 2, true)
	for axis: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		draw_circle(center + axis * 51, 3, Color("99ac96"))
	var thumb: Vector2 = center + direction * RADIUS
	draw_circle(thumb + Vector2(0, 4), 27, Color(0.15, 0.27, 0.2, 0.2))
	draw_circle(thumb, 27, Color("2e795c"))
	draw_circle(thumb - Vector2(0, 3), 20, Color("3d8b6d"))
