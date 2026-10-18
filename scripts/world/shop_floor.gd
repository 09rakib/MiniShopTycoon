class_name ShopFloor
extends Node2D
var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world_layout.json"))
## Static original artwork. Repaint only when its geometry changes.
func _draw() -> void:
	draw_rect(Rect2(0, 0, 820, 1200), Color("e5d7b8"))
	draw_rect(Rect2(24, 80, 772, 920), Color("a6c1ac"))
	draw_rect(Rect2(46, 192, 728, 786), Color("efd9b0"))
	for row: int in range(192, 980, 48):
		draw_line(Vector2(46, row), Vector2(774, row), Color("dfc69c"), 2)
		var shift: int = 56 if (row / 48) % 2 else 0
		for x: int in range(46 + shift, 774, 112):
			draw_line(Vector2(x, row), Vector2(x, mini(row + 48, 978)), Color("e3cba3"), 1)
	# Raised back wall, windows and an original burger-shop wordmark.
	draw_rect(Rect2(46, 80, 728, 112), Color("f9f0d7"))
	for x: int in [80, 565]:
		draw_style_box(style(Color("8db9b7"), 10), Rect2(x, 104, 164, 65))
		draw_style_box(style(Color("c9e2d8"), 6), Rect2(x + 5, 109, 154, 55))
		draw_line(Vector2(x + 82, 109), Vector2(x + 82, 164), Color("fff7dc"), 5)
	draw_style_box(style(Color("2c6d55"), 12), Rect2(278, 105, 256, 65))
	text("LITTLE BUN", Vector2(307, 145), 29, Color("fff4d3"))
	draw_rect(Rect2(46, 178, 728, 14), Color("729d83"))
	# Empty expansion bay and a separate customer approach lane.
	draw_style_box(style(Color("e3cfaa"), 16), Rect2(92, 490, 154, 140))
	draw_rect(Rect2(108, 507, 122, 105), Color("d5c098"), false, 2)
	text("SPACE TO GROW", Vector2(112, 559), 13, Color("8c815e"))
	for y: int in [600, 664, 728, 792]:
		draw_arc(Vector2(700, y), 22, 0, TAU, 32, Color("c4ad82"), 2, true)
	text("QUEUE", Vector2(674, 830), 15, Color("a29170"))
	for station: Dictionary in layout["fixtures"]:
		if not station["id"] in ["burger_machine", "serving_counter"]:
			continue
		var point: Vector2 = Vector2(station["hint_point"][0], station["hint_point"][1])
		draw_arc(point, 29, 0, TAU, 36, Color("8ca67e"), 2, true)
		text("COLLECT" if station["id"] == "burger_machine" else "DELIVER", point + Vector2(-26, 46), 12, Color("698361"))
	draw_style_box(style(Color("4d8b70"), 14), Rect2(302, 872, 216, 75))
	text("WELCOME", Vector2(342, 917), 24, Color("ecedcf"))
	draw_style_box(style(Color("9bbcad"), 8), Rect2(325, 990, 170, 50))
	draw_line(Vector2(46, 1000), Vector2(774, 1000), Color("b0a68a"), 5)
	for x: int in range(40, 790, 70):
		draw_rect(Rect2(x, 1080, 38, 100), Color("ded1b2"))

func style(color: Color, radius: int) -> StyleBoxFlat:
	var value: StyleBoxFlat = StyleBoxFlat.new()
	value.bg_color = color
	value.set_corner_radius_all(radius)
	return value

func text(value: String, point: Vector2, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
