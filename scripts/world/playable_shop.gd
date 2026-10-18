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
var production_controller: ProductionController
var customer_controller: BurgerCustomers
var cash_label: Label
var carry_label: Label
var action_button: Button
var action: String = ""
var feedback_label: Label
var cash_retry_at: int = 0
var feedback_timer: Timer

func _ready() -> void:
	Game.running = false
	world = ShopWorld.new()
	add_child(world)
	production_controller = ProductionController.new()
	add_child(production_controller)
	customer_controller = BurgerCustomers.new()
	customer_controller.actors = world.actors
	add_child(customer_controller)
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

func _panel() -> PanelContainer:
	var value: PanelContainer = PanelContainer.new()
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color("fff4da")
	box.set_corner_radius_all(16)
	for side: String in ["left", "right", "top", "bottom"]:
		box.set("content_margin_" + side, 14.0)
	value.add_theme_stylebox_override("panel", box)
	return value

func _build_hud() -> void:
	var top: MarginContainer = MarginContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 20
	top.offset_top = 18
	top.offset_right = -20
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(top)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	top.add_child(row)
	var wallet: PanelContainer = _panel()
	wallet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wallet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var stats: VBoxContainer = VBoxContainer.new()
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wallet_label = _label("", 24)
	level_label = _label("", 14)
	stats.add_child(wallet_label)
	stats.add_child(level_label)
	carry_label = _label("", 14)
	stats.add_child(carry_label)
	cash_label = _label("", 14)
	stats.add_child(cash_label)
	wallet.add_child(stats)
	row.add_child(wallet)
	row.add_child(_button("Menu", open_menu))
	joystick = ShopJoystick.new()
	joystick.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.offset_left = 16
	joystick.offset_right = 180
	joystick.offset_top = -208
	joystick.offset_bottom = -44
	joystick.direction_changed.connect(world.player.set_move_vector)
	hud.add_child(joystick)
	var instruction: Label = _label("DRAG TO MOVE", 12)
	instruction.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	instruction.offset_left = 43
	instruction.offset_right = 190
	instruction.offset_top = -40
	instruction.offset_bottom = -18
	hud.add_child(instruction)
	location_label = _label("Explore your shop", 16)
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	location_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	location_label.offset_left = -270
	location_label.offset_right = -22
	location_label.offset_top = -116
	location_label.offset_bottom = -58
	hud.add_child(location_label)
	action_button = _button("Collect", _interact)
	action_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	action_button.offset_left = -214
	action_button.offset_right = -22
	action_button.offset_top = -192
	action_button.offset_bottom = -124
	hud.add_child(action_button)
	action_button.hide()
	feedback_label = _label("", 17)
	feedback_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	feedback_label.offset_left = 24
	feedback_label.offset_right = -24
	feedback_label.offset_top = -280
	feedback_label.offset_bottom = -224
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
	buttons.add_child(_label("Serve burgers, then walk to collect cash.", 17))
	buttons.add_child(_button("Back to the shop", close_menu))
	buttons.add_child(_button("Inventory • grocery", _open_legacy.bind("inventory")))
	buttons.add_child(_button("Shelf upgrades & goals", _open_legacy.bind("upgrades")))
	buttons.add_child(_button("Previous grocery shop", _open_legacy.bind("shop")))
	var note: Label = _label("Your saved grocery business stays available here.\nv0.8.0 • Fully offline", 14)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	buttons.add_child(note)
	menu.hide()
	legacy_layer = Control.new()
	legacy_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(legacy_layer)
	legacy_layer.hide()

func _refresh() -> void:
	wallet_label.text = "%d coins" % Game.economy.coins
	level_label.text = "Level %d • %s" % [Game.economy.shop_level(), Game.economy.progression.xp_text(Game.economy.customers)]
	carry_label.text = "Carry %d/%d • Counter %d/%d" % [Game.economy.handling.carried, Game.economy.handling.carry_capacity(), Game.economy.handling.counter, Game.economy.handling.counter_capacity()]
	cash_label.text = "Cash waiting: %d" % Game.economy.burger_sales.uncollected_cash
	_update_location()

func _check_nearby() -> void:
	_update_location()
	_try_collect_cash()

func _try_collect_cash() -> void:
	if suspended or get_tree().paused or world.player.controls_blocked or menu.visible or legacy_layer.visible or Time.get_ticks_msec() < cash_retry_at:
		return
	if Game.economy.burger_sales.uncollected_cash <= 0 or not Game.economy.cash_pickup.is_near(world.player.position):
		return
	if Game.collect_cash(world.player.position) == 0:
		cash_retry_at = Time.get_ticks_msec() + int(float(Game.economy.cash_pickup.config["retry_seconds"]) * 1000)

func _update_location() -> void:
	if not is_instance_valid(action_button) or menu.visible or legacy_layer.visible or suspended:
		if is_instance_valid(action_button):
			action_button.hide()
		return
	var handling: BurgerHandling = Game.economy.handling
	action = handling.nearby_action(world.player.position)
	action_button.visible = not action.is_empty()
	if action.is_empty():
		if Game.economy.cash_pickup.is_near(world.player.position):
			location_label.text = "Cash collects automatically" if Game.economy.burger_sales.uncollected_cash > 0 else "Cash collected • keep serving"
		else:
			location_label.text = "Deliver to the counter" if handling.carried > 0 else "Walk to CASH to collect" if Game.economy.burger_sales.uncollected_cash > 0 else "Collect from the press"
		return
	var amount: int = handling.available_amount(action, Game.economy.production)
	action_button.disabled = amount <= 0
	if action == "pickup":
		location_label.text = "Machine %d/%d" % [Game.economy.production.stock, Game.economy.production.capacity()]
		action_button.text = "Collect %d" % amount if amount > 0 else "Hands full" if handling.carried >= handling.carry_capacity() else "Cooking…"
	else:
		location_label.text = "Counter %d/%d" % [handling.counter, handling.counter_capacity()]
		action_button.text = "Deliver %d" % amount if amount > 0 else "Counter full" if handling.counter >= handling.counter_capacity() else "Hands empty"

func _feedback(message: String) -> void:
	feedback_label.text = message
	feedback_label.show()
	feedback_timer.start()

func _interact() -> void:
	if suspended or world.player.controls_blocked or menu.visible or legacy_layer.visible:
		return
	# Re-evaluate distance and action at press time; never trust a stale HUD prompt.
	var current: String = Game.economy.handling.nearby_action(world.player.position)
	if not current.is_empty():
		Game.interact_burgers(current, world.player.position)
	_update_location()

func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.has_feature("android") and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		_interact()
		get_viewport().set_input_as_handled()

func _block_controls(value: bool) -> void:
	world.player.controls_blocked = value
	world.player.stop()
	joystick.set_enabled(not value)

func open_menu() -> void:
	menu.show()
	_block_controls(true)
	_update_location()

func close_menu() -> void:
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
		customer_controller.set_paused(true)
	elif what in [NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN]:
		suspended = false
		_block_controls(menu.visible or legacy_layer.visible)
		production_controller.set_paused(false)
		customer_controller.set_paused(false)
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if legacy_layer.visible:
			_close_legacy()
		elif menu.visible:
			close_menu()
		else:
			open_menu()
