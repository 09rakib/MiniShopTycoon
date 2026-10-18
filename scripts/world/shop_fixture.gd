class_name ShopFixture
extends StaticBody2D
var definition: Dictionary
var footprint: Vector2

func _ready() -> void:
	var values: Array = definition["rect"]
	footprint = Vector2(values[2], values[3])
	position = Vector2(float(values[0]) + footprint.x / 2, float(values[1]) + footprint.y)
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = footprint
	shape.position = Vector2(0, -footprint.y / 2)
	shape.shape = rectangle
	add_child(shape)

func _draw() -> void:
	var type: String = definition["type"]
	var w: float = footprint.x
	var h: float = footprint.y
	if type == "plant":
		panel(Rect2(-22, -24, 44, 26), Color("bc8660"), 7)
		for point: Vector2 in [Vector2(-16, -43), Vector2(15, -49), Vector2(-2, -64), Vector2(0, -39)]:
			draw_circle(point, 19, Color("578b63"))
		return
	var lift: float = 55 if type == "machine" else 38
	panel(Rect2(-w / 2 + 5, -h + 8, w, h), Color(0.2, 0.26, 0.16, 0.12), 10)
	panel(Rect2(-w / 2, -h, w, h), Color("30614e") if type == "machine" else Color("c57858"), 10)
	panel(Rect2(-w / 2, -h - lift, w, h), Color("83ad91") if type == "machine" else Color("fff0cf"), 10)
	if type == "machine":
		panel(Rect2(-w / 2 + 12, -h - lift + 12, w - 24, h - 26), Color("42675b"), 8)
		for x: int in [-43, -13, 17, 47]:
			draw_line(Vector2(x, -h - lift + 23), Vector2(x, -lift - 27), Color("91aaa0"), 6)
		panel(Rect2(-w / 2 + 12, -43, w - 24, 25), Color("244c40"), 5)
		text("BURGER PRESS", Vector2(-64, -25), 16, Color("f8e7bf"))
		# A sign, not produced stock. Production belongs to Phase C.
		draw_circle(Vector2(0, -h - lift - 19), 29, Color("faf0cd"))
		draw_arc(Vector2(0, -h - lift - 17), 17, PI, TAU, 20, Color("d7a057"), 11, true)
		draw_line(Vector2(-19, -h - lift - 13), Vector2(19, -h - lift - 13), Color("71a065"), 6)
		draw_line(Vector2(-17, -h - lift - 6), Vector2(17, -h - lift - 6), Color("ad6c43"), 7)
	elif type == "counter":
		panel(Rect2(-12, -h - lift + 8, 62, 44), Color("345b4c"), 6)
		panel(Rect2(-6, -h - lift + 14, 50, 27), Color("a7c9aa"), 3)
		text("SERVE", Vector2(-30, -16), 21, Color("fff1cf"))
	else:
		panel(Rect2(-w / 2 + 8, -h - lift + 6, w - 16, h - 12), Color("d6b470"), 5)
		text("CASH", Vector2(-24, -12), 14, Color("fff1cf"))

func panel(rect: Rect2, color: Color, radius: int) -> void:
	var value: StyleBoxFlat = StyleBoxFlat.new()
	value.bg_color = color
	value.set_corner_radius_all(radius)
	draw_style_box(value, rect)

func text(value: String, point: Vector2, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
