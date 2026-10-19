class_name ShopFixture
extends StaticBody2D
var definition: Dictionary
var footprint: Vector2
var production: ProductionState
var handling: BurgerHandling
var sales: BurgerSales

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
		if production != null:
			for unit: int in mini(production.stock, 10):
				burger(Vector2(-w / 2 + 25 + (unit % 5) * 25, -h - lift + 29 + (unit / 5) * 28))
			panel(Rect2(-w / 2 + 10, -49, w - 20, 41), Color("244c40"), 5)
			text("%d / %d" % [production.stock, production.capacity()], Vector2(-33, -29), 19, Color("fff1c8"))
			var status: String = "FULL" if production.stock >= production.capacity() else "COOKING" if production.active else "OFF"
			status += " +UP" if production.upgrade_cost("speed") >= 0 or production.upgrade_cost("capacity") >= 0 or production.upgrade_cost("price") >= 0 else " MAX"
			text(status, Vector2(-27, -h - lift + 86), 11, Color("edc16b"))
		# A sign, not produced stock. Production belongs to Phase C.
		draw_circle(Vector2(0, -h - lift - 19), 29, Color("faf0cd"))
		draw_arc(Vector2(0, -h - lift - 17), 17, PI, TAU, 20, Color("d7a057"), 11, true)
		draw_line(Vector2(-19, -h - lift - 13), Vector2(19, -h - lift - 13), Color("71a065"), 6)
		draw_line(Vector2(-17, -h - lift - 6), Vector2(17, -h - lift - 6), Color("ad6c43"), 7)
	elif type == "counter":
		if handling != null:
			for unit: int in mini(handling.counter, 9):
				burger(Vector2(-w / 2 + 23 + (unit % 3) * 23, -h - lift + 25 + (unit / 3) * 22))
		panel(Rect2(-12, -h - lift + 8, 62, 44), Color("345b4c"), 6)
		panel(Rect2(-6, -h - lift + 14, 50, 27), Color("a7c9aa"), 3)
		var stock_label: String = "SERVE %d / %d" % [handling.counter, handling.counter_capacity()] if handling != null else "SERVE"
		text(stock_label, Vector2(-65, -16), 18, Color("fff1cf"))
	else:
		panel(Rect2(-w / 2 + 8, -h - lift + 6, w - 16, h - 12), Color("d6b470"), 5)
		var cash: int = sales.uncollected_cash if sales != null else 0
		if cash > 0:
			for stack: int in mini(3, 1 + cash / 60):
				var origin: Vector2 = Vector2(-22 + stack * 12, -h - lift + 14 - stack * 6)
				panel(Rect2(origin, Vector2(34, 18)), Color("458b64"), 3)
				draw_line(origin + Vector2(17, 2), origin + Vector2(17, 16), Color("f4dfa4"), 6)
		text("CASH" if cash > 0 else "EMPTY", Vector2(-24, -12), 14, Color("fff1cf"))
		if cash > 0:
			var amount_text: String = str(cash)
			var font_size: int = 16 if amount_text.length() <= 6 else 11
			text(amount_text, Vector2(-w / 2, -h - lift - 12), font_size, Color("255d42"))

func panel(rect: Rect2, color: Color, radius: int) -> void:
	var value: StyleBoxFlat = StyleBoxFlat.new()
	value.bg_color = color
	value.set_corner_radius_all(radius)
	draw_style_box(value, rect)

func text(value: String, point: Vector2, font_size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func burger(point: Vector2) -> void:
	draw_line(point + Vector2(-9, 6), point + Vector2(9, 6), Color("d7a057"), 5, true)
	draw_line(point + Vector2(-10, 1), point + Vector2(10, 1), Color("945c36"), 5, true)
	draw_line(point + Vector2(-11, -2), point + Vector2(11, -2), Color("91b762"), 3, true)
	draw_arc(point + Vector2(0, -2), 9, PI, TAU, 12, Color("e7b364"), 7, true)
