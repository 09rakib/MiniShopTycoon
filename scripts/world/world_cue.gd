class_name WorldCue
extends Node2D
## Four instances reused by the world; no particles or temporary node spawning.
var progress: float = 0
var caption: String = ""
var tint: Color = Color("5b9873")
var duration: float = 0.7

func _ready() -> void:
	z_index = 40
	clear()

func show_cue(kind: String, point: Vector2, amount: int) -> void:
	position = point
	progress = 0
	duration = 0.6 if kind == "produce" else 0.8
	caption = "+1 READY" if kind == "produce" else "+%d PICKED" % amount if kind.ends_with("pickup") else "%d SERVED" % amount if kind.ends_with("serve") else "+%d CASH" % amount if kind == "sale" else "UPGRADED" if kind == "upgrade" else "HIRED" if kind == "hire" else "UNLOCKED" if kind == "unlock" else ""
	tint = Color("c99547") if kind in ["cash", "sale", "upgrade", "unlock", "hire"] else Color("4b8b69")
	show()
	set_process(true)
	queue_redraw()

func clear() -> void:
	hide()
	set_process(false)
	caption = ""
	progress = 0

func _process(delta: float) -> void:
	progress += delta / duration
	if progress >= 1:
		clear()
	else:
		queue_redraw()

func _draw() -> void:
	var color: Color = tint
	color.a = (1 - progress) * 0.7
	draw_arc(Vector2(0, -2), 17 + progress * 25, 0, TAU, 32, color, 2, true)
	for index: int in 6:
		var point: Vector2 = Vector2.from_angle(index * TAU / 6) * (18 + progress * 28)
		draw_circle(point + Vector2(0, -2), 2 * (1 - progress), color)
	if not caption.is_empty():
		var text_color: Color = Color("285b42")
		text_color.a = 1 - progress
		var font: Font = ThemeDB.fallback_font
		var point: Vector2 = Vector2(-font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x / 2, -83 - progress * 20)
		draw_string_outline(font, point, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 4, Color(1, 0.96, 0.85, 1 - progress))
		draw_string(font, point, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, text_color)
