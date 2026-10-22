class_name ShopJoystick
extends Control
signal direction_changed(value: Vector2)

var direction: Vector2 = Vector2.ZERO
var center: Vector2 = Vector2.ZERO
var finger: int = -1
var mouse_held: bool = false
var enabled: bool = true
var blocked_regions: Array[Control] = []
const RADIUS: float = 54.0
const DEAD_ZONE: float = 0.12
const BASE_ALPHA: float = 0.14
const THUMB_ALPHA: float = 0.32

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func active() -> bool:
	return finger >= 0 or mouse_held

func _local(point: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * point

func _blocked(point: Vector2) -> bool:
	for control: Control in blocked_regions:
		if is_instance_valid(control) and control.is_visible_in_tree():
			var local: Vector2 = control.get_global_transform_with_canvas().affine_inverse() * point
			if Rect2(Vector2.ZERO, control.size).has_point(local):
				return true
	return false

func _unhandled_input(event: InputEvent) -> void:
	if not enabled or active():
		return
	if event is InputEventScreenTouch and event.pressed and not event.canceled and not _blocked(event.position):
		finger = event.index
		center = _local(event.position)
		_set_offset(Vector2.ZERO)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not _blocked(event.position):
		mouse_held = true
		center = _local(event.position)
		_set_offset(Vector2.ZERO)
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.index == finger and (not event.pressed or event.canceled):
		release()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == finger:
		_set_offset(_local(event.position) - center)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and mouse_held:
		release()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and mouse_held:
		_set_offset(_local(event.position) - center)
		get_viewport().set_input_as_handled()

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
	if not active():
		return
	draw_circle(center, 66, Color(0.98, 0.97, 0.9, BASE_ALPHA))
	draw_arc(center, 65, 0, TAU, 48, Color(0.18, 0.4, 0.29, 0.22), 2, true)
	var thumb: Vector2 = center + direction * RADIUS
	draw_circle(thumb, 24, Color(0.16, 0.43, 0.31, THUMB_ALPHA))
	draw_arc(thumb, 23, 0, TAU, 32, Color(0.98, 0.97, 0.9, 0.25), 1.5, true)
