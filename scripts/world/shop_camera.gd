class_name ShopCamera
extends Camera2D
var target: Node2D
var room_size: Vector2 = Vector2(820, 1200)
var follow_speed: float = 8.0
var base_zoom: float = 1.0

func _ready() -> void:
	position_smoothing_enabled = false
	make_current()
	update_follow(0.0, true)

func desired_position() -> Vector2:
	var view: Vector2 = get_viewport_rect().size
	var factor: float = maxf(base_zoom, maxf(view.x / room_size.x, view.y / room_size.y))
	zoom = Vector2.ONE * factor
	var half: Vector2 = view / zoom / 2.0
	var wanted: Vector2 = target.position + Vector2(0, -65)
	return Vector2(clampf(wanted.x, half.x, room_size.x - half.x), clampf(wanted.y, half.y, room_size.y - half.y))

func update_follow(delta: float, snap: bool = false) -> void:
	if not is_instance_valid(target):
		return
	var desired: Vector2 = desired_position()
	position = desired if snap else position.lerp(desired, 1.0 - exp(-follow_speed * delta))
	# Resizing can change bounds immediately, even while the camera is easing.
	var half: Vector2 = get_viewport_rect().size / zoom / 2.0
	position = Vector2(clampf(position.x, half.x, room_size.x - half.x), clampf(position.y, half.y, room_size.y - half.y))

func _process(delta: float) -> void:
	update_follow(delta)
