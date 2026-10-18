class_name ShopView
extends Control
## Original vector artwork drawn by Godot. No textures or physics bodies.
var customers: ShopCustomers
var font: Font = ThemeDB.fallback_font

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	Game.changed.connect(queue_redraw)

func _draw() -> void:
	var scale_factor: Vector2 = size / Vector2(440, 300)
	draw_set_transform(Vector2.ZERO, 0, scale_factor)
	box(Rect2(0, 0, 440, 300), Color("d9e8d8"), 22)
	box(Rect2(12, 62, 416, 226), Color("f1dfbd"), 12)
	for x: int in range(14, 430, 52):
		draw_line(Vector2(x, 64), Vector2(x, 285), Color("e3cea8"), 1)
	for y: int in range(72, 290, 44):
		draw_line(Vector2(14, y), Vector2(426, y), Color("e3cea8"), 1)
	box(Rect2(18, 12, 404, 45), Color("27634e"), 12)
	text_at("THE LITTLE CORNER SHOP", Vector2(80, 41), 19, Color("fff5dc"))
	for index: int in 3:
		var x: float = 28 + index * 136
		box(Rect2(x, 83, 112, 82), Color("ad7752"), 8)
		box(Rect2(x + 4, 87, 104, 65), Color("fff1d1"), 5)
		var displayed: Array[String] = shelf_items(index)
		for unit: int in displayed.size():
			var point: Vector2 = Vector2(x + 12 + (unit % 3) * 30, 90 + (unit / 3) * 27)
			draw_texture_rect(ProductIcons.texture(displayed[unit]), Rect2(point, Vector2(24, 24)), false)
		var names: Array[String] = ["Pantry", "Chilled", "Daily picks"]
		text_at(names[index], Vector2(x + 22, 181), 15, Color("345448"))
	box(Rect2(265, 223, 139, 50), Color("ae7953"), 8)
	box(Rect2(258, 214, 151, 24), Color("35735e"), 7)
	box(Rect2(333, 197, 35, 25), Color("294d46"), 4)
	box(Rect2(338, 201, 25, 14), Color("a7d2bc"), 2)
	text_at("CHECKOUT", Vector2(280, 257), 14, Color("fff0cf"))
	box(Rect2(30, 263, 100, 37), Color("8cb9a6"), 5)
	text_at("WELCOME", Vector2(40, 286), 14, Color("234f42"))
	if customers != null:
		for slot: Dictionary in customers.slots:
			if slot["active"]:
				person(customer_position(slot), int(slot["color"]))

func customer_position(slot: Dictionary) -> Vector2:
	var progress: float = float(slot["progress"])
	var product: Dictionary = Game.economy.products[int(slot["product"])]
	var shelf: Vector2 = Vector2(82 + int(product["shelf"]) * 136, 198)
	var checkout: Vector2 = Vector2(234, 247)
	if progress < 0.35:
		return Vector2(76, 306).lerp(shelf, progress / 0.35)
	if progress < 0.48:
		return shelf
	if progress < 0.7:
		return shelf.lerp(checkout, (progress - 0.48) / 0.22)
	if progress < 0.8:
		return checkout
	return checkout.lerp(Vector2(76, 320), (progress - 0.8) / 0.2)

func person(point: Vector2, index: int) -> void:
	var colors: Array[Color] = [Color("df806a"), Color("7c91be"), Color("e5b95d"), Color("78a88e")]
	paint_ellipse(point + Vector2(0, 11), Vector2(15, 5), Color(0.2, 0.25, 0.18, 0.15))
	box(Rect2(point + Vector2(-10, -6), Vector2(20, 22)), colors[index % 4], 7)
	draw_circle(point + Vector2(0, -13), 10, Color("f0c99e"))
	draw_arc(point + Vector2(0, -15), 9, PI, TAU, 12, Color("65503d"), 5)
	draw_circle(point + Vector2(4, -13), 1.3, Color("3d4c40"))

func paint_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points: PackedVector2Array = []
	for index: int in 20:
		var angle: float = index * TAU / 20
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)

func shelf_items(shelf: int) -> Array[String]:
	var available: Array[String] = []
	for product: Dictionary in Game.economy.products:
		if int(product["shelf"]) == shelf and int(Game.economy.stock[product["id"]]) > 0:
			available.append(product["id"])
	var items: Array[String] = []
	if available.is_empty():
		return items
	for unit: int in 6:
		var id: String = available[unit % available.size()]
		if items.count(id) < int(Game.economy.stock[id]):
			items.append(id)
	return items

func box(rect: Rect2, color: Color, radius: int) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	draw_style_box(style, rect)

func text_at(value: String, point: Vector2, font_size: int, color: Color) -> void:
	draw_string(font, point, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

