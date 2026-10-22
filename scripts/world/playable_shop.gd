extends Node2D
## Playable burger shop. Previous grocery gameplay remains intact in a sheet.
var world: ShopWorld
var joystick: ShopJoystick
var hud: Control
var wallet_label: Label
var level_label: Label
var location_label: Label
var menu: Control
var legacy_layer: Control
var legacy: Control
var suspended: bool = false
var fries_controller: ProductionController
var expansion_panel: ShopExpansionPanel
var production_controller: ProductionController
var stocker_controller: StockerController
var operations_layer: Control
var operations_panel: BurgerOperationsPanel
var customer_controller: BurgerCustomers
var cash_label: Label
var carry_label: Label
var menu_button: Button
var top_hud: MarginContainer
var action: String = ""
var feedback_label: Label
var cash_retry_at: int = 0
var feedback_timer: Timer
var audio: ShopAudio
var sound_button: Button
var menu_tween: Tween
var sheet_tween: Tween

func _ready() -> void:
	Game.running = false
	world = ShopWorld.new()
	add_child(world)
	audio = ShopAudio.new()
	add_child(audio)
	production_controller = ProductionController.new()
	add_child(production_controller)
	fries_controller = ProductionController.new()
	fries_controller.state = Game.economy.expansion.production
	add_child(fries_controller)
	customer_controller = BurgerCustomers.new()
	customer_controller.actors = world.actors
	add_child(customer_controller)
	stocker_controller = StockerController.new()
	stocker_controller.actors = world.actors
	add_child(stocker_controller)
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.theme = _make_theme()
	layer.add_child(hud)
	_build_hud()
	_build_menu()
	feedback_timer = Timer.new()
	feedback_timer.one_shot = true
	feedback_timer.wait_time = 2.7
	feedback_timer.timeout.connect(func() -> void: feedback_label.hide())
	add_child(feedback_timer)
	Game.changed.connect(_refresh)
	Game.handling_changed.connect(_refresh)
	Game.production_changed.connect(_update_location)
	Game.feedback.connect(_feedback)
	var hint_timer: Timer = Timer.new()
	hint_timer.wait_time = float(Game.economy.cash_pickup.config["poll_seconds"])
	hint_timer.timeout.connect(_check_nearby)
	add_child(hint_timer)
	hint_timer.start()
	_refresh()
	_update_location()
	if not Game.storage.message.is_empty():
		_feedback(Game.storage.message)

func _make_theme() -> Theme:
	var value: Theme = Theme.new()
	value.default_font_size = 17
	value.set_color("font_color", "Label", Color("254e40"))
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = Color("2e765a") if state != "pressed" else Color("245840")
		if state == "disabled":
			box.bg_color = Color("b5c5b3")
		box.set_corner_radius_all(15)
		box.content_margin_left = 16
		box.content_margin_right = 16
		if state == "focus":
			box.bg_color = Color.TRANSPARENT
			box.border_color = Color("e6ae60")
			box.set_border_width_all(3)
		value.set_stylebox(state, "Button", box)
	value.set_color("font_color", "Button", Color("fff8df"))
	value.set_color("font_disabled_color", "Button", Color("254e40"))
	return value

func _label(text: String, font_size: int) -> Label:
	var value: Label = Label.new()
	value.text = text
	value.add_theme_font_size_override("font_size", font_size)
	value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return value

func _button(text: String, callback: Callable) -> Button:
	var value: Button = Button.new()
	value.text = text
	value.custom_minimum_size.y = 52
	value.pressed.connect(callback)
	return value

func _panel(compact: bool = false) -> PanelContainer:
	var value: PanelContainer = PanelContainer.new()
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color("fff4da")
	box.set_corner_radius_all(16)
	for side: String in ["left", "right", "top", "bottom"]:
		box.set("content_margin_" + side, 8.0 if compact else 14.0)
	value.add_theme_stylebox_override("panel", box)
	return value

func _build_hud() -> void:
	top_hud = MarginContainer.new()
	top_hud.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top_hud.offset_left = 12
	top_hud.offset_top = 12
	top_hud.offset_right = -12
	top_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(top_hud)
	var lines: VBoxContainer = VBoxContainer.new()
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.add_theme_constant_override("separation", 5)
	top_hud.add_child(lines)
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	lines.add_child(row)
	var wallet: PanelContainer = _panel(true)
	wallet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wallet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var stats: HBoxContainer = HBoxContainer.new()
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats.add_theme_constant_override("separation", 12)
	wallet_label = _label("", 22)
	wallet_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_label = _label("", 13)
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats.add_child(wallet_label)
	stats.add_child(level_label)
	wallet.add_child(stats)
	row.add_child(wallet)
	menu_button = _button("Menu", open_menu)
	menu_button.custom_minimum_size = Vector2(72, 44)
	row.add_child(menu_button)
	var status: HBoxContainer = HBoxContainer.new()
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.add_child(status)
	carry_label = _label("", 13)
	carry_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cash_label = _label("", 13)
	status.add_child(carry_label)
	status.add_child(cash_label)
	for value: Label in [carry_label, cash_label]:
		value.add_theme_color_override("font_outline_color", Color("fff4da"))
		value.add_theme_constant_override("outline_size", 4)
	joystick = ShopJoystick.new()
	joystick.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	joystick.blocked_regions.append(menu_button)
	joystick.direction_changed.connect(world.player.set_move_vector)
	hud.add_child(joystick)
	location_label = _label("Touch & drag anywhere", 14)
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	location_label.offset_left = 16
	location_label.offset_right = -16
	location_label.offset_top = -56
	location_label.offset_bottom = -24
	location_label.add_theme_color_override("font_outline_color", Color("fff4da"))
	location_label.add_theme_constant_override("outline_size", 4)
	hud.add_child(location_label)
	feedback_label = _label("", 16)
	feedback_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	feedback_label.offset_left = 24
	feedback_label.offset_right = -24
	feedback_label.offset_top = -124
	feedback_label.offset_bottom = -78
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_color_override("font_outline_color", Color("fff4da"))
	feedback_label.add_theme_constant_override("outline_size", 6)
	hud.add_child(feedback_label)
	feedback_label.hide()

func _build_menu() -> void:
	menu = Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(menu)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.1, 0.2, 0.15, 0.58)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(center)
	var panel: PanelContainer = _panel()
	panel.custom_minimum_size.x = 408
	center.add_child(panel)
	var buttons: VBoxContainer = VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	panel.add_child(buttons)
	buttons.add_child(_label("LITTLE BUN", 30))
	buttons.add_child(_label("Build a bigger little food shop.", 17))
	buttons.add_child(_button("Back to the shop", close_menu))
	sound_button = _button("Sound: On" if audio.settings.enabled else "Sound: Off", _toggle_sound)
	buttons.add_child(sound_button)
	buttons.add_child(_button("Burger machine & stocker", _open_operations))
	buttons.add_child(_button("New machines & furniture", _open_expansion))
	buttons.add_child(_button("Inventory • grocery", _open_legacy.bind("inventory")))
	buttons.add_child(_button("Shelf upgrades & goals", _open_legacy.bind("upgrades")))
	buttons.add_child(_button("Previous grocery shop", _open_legacy.bind("shop")))
	var note: Label = _label("Your saved grocery business stays available here.\nv0.13.0 • Fully offline", 14)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	buttons.add_child(note)
	menu.hide()
	operations_layer = Control.new()
	operations_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(operations_layer)
	var workshop_shade: ColorRect = ColorRect.new()
	workshop_shade.color = Color(0.1, 0.2, 0.15, 0.88)
	workshop_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	operations_layer.add_child(workshop_shade)
	var workshop_center: CenterContainer = CenterContainer.new()
	workshop_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	operations_layer.add_child(workshop_center)
	operations_panel = BurgerOperationsPanel.new()
	operations_panel.custom_minimum_size.x = 408
	var workshop_style: StyleBoxFlat = StyleBoxFlat.new()
	workshop_style.bg_color = Color("fff4da")
	workshop_style.set_corner_radius_all(16)
	for side: String in ["left", "right", "top", "bottom"]:
		workshop_style.set("content_margin_" + side, 16.0)
	operations_panel.add_theme_stylebox_override("panel", workshop_style)
	operations_panel.closed.connect(operations_layer.hide)
	operations_panel.return_to_shop.connect(close_menu)
	workshop_center.add_child(operations_panel)
	expansion_panel = ShopExpansionPanel.new()
	expansion_panel.custom_minimum_size.x = 408
	expansion_panel.add_theme_stylebox_override("panel", workshop_style)
	expansion_panel.return_to_shop.connect(close_menu)
	workshop_center.add_child(expansion_panel)
	expansion_panel.hide()
	operations_layer.hide()
	legacy_layer = Control.new()
	legacy_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(legacy_layer)
	legacy_layer.hide()

func _refresh() -> void:
	wallet_label.text = "%d coins" % Game.economy.coins
	level_label.text = "Lv %d" % Game.economy.shop_level()
	level_label.tooltip_text = Game.economy.progression.xp_text(Game.economy.customers)
	carry_label.text = "Carry %d/%d • Counter %d/%d" % [Game.economy.handling.carried, Game.economy.handling.carry_capacity(), Game.economy.handling.counter, Game.economy.handling.counter_capacity()]
	if Game.economy.expansion.unlocked:
		carry_label.text = "Carry %d/2 • B %d/8 • F %d/4" % [Game.economy.handling.carried + Game.economy.expansion.handling.carried, Game.economy.handling.counter, Game.economy.expansion.handling.counter]
	cash_label.text = "Cash waiting: %d" % Game.economy.burger_sales.uncollected_cash
	_update_location()

func _check_nearby() -> void:
	_auto_transfer_food()
	_try_collect_cash()
	_update_location()

func _try_collect_cash() -> void:
	if suspended or get_tree().paused or world.player.controls_blocked or menu.visible or legacy_layer.visible or Time.get_ticks_msec() < cash_retry_at:
		return
	if Game.economy.burger_sales.uncollected_cash <= 0 or not Game.economy.cash_pickup.is_near(world.player.position):
		return
	if Game.collect_cash(world.player.position) == 0:
		cash_retry_at = Time.get_ticks_msec() + int(float(Game.economy.cash_pickup.config["retry_seconds"]) * 1000)

func _update_location() -> void:
	if menu.visible or legacy_layer.visible or suspended:
		location_label.text = ""
		return
	var economy: ShopEconomy = Game.economy
	var held: int = economy.handling.carried + economy.expansion.handling.carried
	action = economy.food_action(world.player.position)
	if action in ["pickup", "fries"]:
		var machine: ProductionState = economy.expansion.production if action == "fries" else economy.production
		var food: String = "Fries" if action == "fries" else "Burgers"
		location_label.text = "%s %d/%d • Auto collect" % [food, machine.stock, machine.capacity()]
		if economy.food_amount(action) == 0 and held > 0:
			location_label.text = "Hands full • Walk to the counter"
	elif action == "deliver":
		location_label.text = "Counter full • Keep carrying" if held > 0 and economy.food_amount(action) == 0 else "Auto serve • Counter %d/8" % economy.handling.counter
		if economy.expansion.unlocked:
			location_label.text += " • Fries %d/4" % economy.expansion.handling.counter
	elif economy.cash_pickup.is_near(world.player.position):
		location_label.text = "Cash collects automatically" if economy.burger_sales.uncollected_cash > 0 else "Keep serving • No cash waiting"
	else:
		location_label.text = "Walk to the counter to serve" if held > 0 else "Walk to CASH to collect" if economy.burger_sales.uncollected_cash > 0 else "Touch & drag anywhere"

func _auto_transfer_food() -> void:
	if suspended or get_tree().paused or world.player.controls_blocked or menu.visible or legacy_layer.visible:
		return
	# Re-read position on every poll; a previous hint never authorizes a transfer.
	var current: String = Game.economy.food_action(world.player.position)
	if not current.is_empty() and Game.economy.food_amount(current) > 0:
		Game.interact_burgers(current, world.player.position)

func _feedback(message: String) -> void:
	feedback_label.text = message
	feedback_label.show()
	feedback_timer.start()

func _block_controls(value: bool) -> void:
	world.player.controls_blocked = value
	world.player.stop()
	joystick.set_enabled(not value)

func _open_expansion() -> void:
	operations_panel.hide()
	expansion_panel.show()
	expansion_panel.refresh()
	_reveal_sheet()

func _open_operations() -> void:
	expansion_panel.hide()
	operations_panel.show()
	operations_panel.refresh()
	_reveal_sheet()

func _toggle_sound() -> void:
	if not audio.set_sound_enabled(not audio.settings.enabled):
		_feedback("Could not save sound setting. Try again.")
	sound_button.text = "Sound: On" if audio.settings.enabled else "Sound: Off"
	audio.play("menu")

func _reveal_sheet() -> void:
	if is_instance_valid(sheet_tween):
		sheet_tween.kill()
	operations_layer.modulate.a = 0
	operations_layer.show()
	sheet_tween = create_tween()
	sheet_tween.tween_property(operations_layer, "modulate:a", 1.0, 0.16)
	audio.play("menu")

func open_menu() -> void:
	operations_layer.hide()
	if is_instance_valid(menu_tween):
		menu_tween.kill()
	menu.modulate.a = 0
	menu.show()
	menu_tween = create_tween()
	menu_tween.tween_property(menu, "modulate:a", 1.0, 0.16)
	audio.play("menu")
	_block_controls(true)
	_update_location()

func close_menu() -> void:
	if is_instance_valid(menu_tween):
		menu_tween.kill()
	if is_instance_valid(sheet_tween):
		sheet_tween.kill()
	menu.modulate.a = 1
	operations_layer.modulate.a = 1
	operations_layer.hide()
	menu.hide()
	Game.running = false
	_block_controls(suspended)
	_update_location()

func _open_legacy(screen: String) -> void:
	menu.hide()
	legacy_layer.show()
	_block_controls(true)
	legacy = preload("res://scenes/main.tscn").instantiate()
	legacy.embedded = true
	legacy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	legacy.offset_top = 66
	legacy_layer.add_child(legacy)
	if screen == "inventory":
		legacy._show_inventory()
	elif screen == "upgrades":
		legacy._show_upgrades()
	else:
		legacy._show_shop()
	var close: Button = _button("← Back to Little Bun", _close_legacy)
	close.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	close.offset_left = 20
	close.offset_right = -20
	close.offset_top = 8
	close.offset_bottom = 60
	legacy_layer.add_child(close)

func _close_legacy() -> void:
	for child: Node in legacy_layer.get_children():
		legacy_layer.remove_child(child)
		child.queue_free()
	legacy = null
	legacy_layer.hide()
	Game.running = false
	menu.show()
	_refresh()

func _notification(what: int) -> void:
	if not is_instance_valid(joystick):
		return
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		suspended = true
		_block_controls(true)
		production_controller.set_paused(true)
		fries_controller.set_paused(true)
		customer_controller.set_paused(true)
		stocker_controller.set_paused(true)
		audio.set_suspended(true)
		world.set_presentation_paused(true)
	elif what in [NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN]:
		suspended = false
		_block_controls(menu.visible or legacy_layer.visible)
		production_controller.set_paused(false)
		fries_controller.set_paused(false)
		customer_controller.set_paused(false)
		stocker_controller.set_paused(false)
		audio.set_suspended(false)
		world.set_presentation_paused(false)
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if legacy_layer.visible:
			_close_legacy()
		elif operations_layer.visible:
			operations_layer.hide()
		elif menu.visible:
			close_menu()
		else:
			open_menu()
