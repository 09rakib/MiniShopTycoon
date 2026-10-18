extends Control
var embedded: bool = false

const INK: Color = Color("234f42")
const GREEN: Color = Color("2c7259")
var content: VBoxContainer
var customers: ShopCustomers
var balance_label: Label
var revenue_label: Label
var customer_label: Label
var hint_label: Label
var stock_labels: Dictionary = {}
var buy_buttons: Dictionary = {}
var restart_dialog: ConfirmationDialog
var on_shop: bool = false
var on_inventory: bool = false
var on_upgrades: bool = false
var inventory_screen: InventoryScreen
var upgrades_screen: UpgradesScreen
var level_label: Label
var objective_label: Label
var level_dialog: AcceptDialog
var page_scroll: ScrollContainer

func _ready() -> void:
	_build_theme()
	customers = ShopCustomers.new()
	add_child(customers)
	customers.purchase.connect(_purchase_feedback)
	Game.changed.connect(_refresh)
	Game.feedback.connect(_feedback)
	Game.level_up.connect(_show_level_up)
	var background: ColorRect = ColorRect.new()
	background.color = Color("faf3e3")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var scroll: ScrollContainer = ScrollContainer.new()
	page_scroll = scroll
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var margin: MarginContainer = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	scroll.add_child(margin)
	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	margin.add_child(content)
	restart_dialog = ConfirmationDialog.new()
	restart_dialog.theme = theme
	restart_dialog.title = "Restart shop?"
	restart_dialog.dialog_text = "Reset coins, stock and sales to a fresh shop?\nThis replaces your current progress."
	restart_dialog.ok_button_text = "Restart progress"
	restart_dialog.confirmed.connect(_restart)
	restart_dialog.get_ok_button().custom_minimum_size = Vector2(180, 52)
	restart_dialog.get_cancel_button().custom_minimum_size = Vector2(120, 52)
	add_child(restart_dialog)
	level_dialog = AcceptDialog.new()
	level_dialog.theme = theme
	level_dialog.title = "Your shop leveled up!"
	level_dialog.ok_button_text = "Keep growing"
	level_dialog.get_ok_button().custom_minimum_size = Vector2(220, 52)
	level_dialog.confirmed.connect(_resume)
	level_dialog.canceled.connect(_resume)
	add_child(level_dialog)
	_show_menu()

func _build_theme() -> void:
	var skin: Theme = Theme.new()
	skin.default_font_size = 17
	skin.set_color("font_color", "Label", INK)
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("b5c5b3") if state == "disabled" else GREEN
		if state == "pressed":
			style.bg_color = Color("214d3c")
		if state == "hover":
			style.bg_color = Color("398267")
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.set_border_width_all(3)
			style.border_color = Color("e6ac64")
		style.set_corner_radius_all(13)
		style.content_margin_left = 14
		style.content_margin_right = 14
		skin.set_stylebox(state, "Button", style)
		skin.set_color("font_" + state + "_color", "Button", Color("ffffff"))
	skin.set_color("font_color", "Button", Color.WHITE)
	skin.set_color("font_disabled_color", "Button", INK)
	skin.set_constant("buttons_min_height", "AcceptDialog", 52)
	skin.set_constant("buttons_min_width", "AcceptDialog", 150)
	var dialog_panel: StyleBoxFlat = StyleBoxFlat.new()
	dialog_panel.bg_color = Color("faf3e3")
	dialog_panel.set_corner_radius_all(12)
	dialog_panel.content_margin_left = 16
	dialog_panel.content_margin_right = 16
	dialog_panel.content_margin_top = 16
	dialog_panel.content_margin_bottom = 16
	skin.set_stylebox("panel", "AcceptDialog", dialog_panel)
	var window_border: StyleBoxFlat = dialog_panel.duplicate()
	window_border.set_border_width_all(3)
	window_border.border_color = Color("faf3e3")
	window_border.expand_margin_top = 32
	skin.set_stylebox("embedded_border", "Window", window_border)
	skin.set_color("title_color", "Window", INK)
	theme = skin

func _clear() -> void:
	for child: Node in content.get_children():
		content.remove_child(child)
		child.queue_free()
	stock_labels.clear()
	buy_buttons.clear()
	balance_label = null
	hint_label = null
	inventory_screen = null
	upgrades_screen = null
	level_label = null
	objective_label = null
	page_scroll.scroll_vertical = 0

func label(text: String, font_size: int = 17) -> Label:
	var result: Label = Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	return result

func button(text: String, callback: Callable) -> Button:
	var result: Button = Button.new()
	result.text = text
	result.custom_minimum_size.y = 52
	result.pressed.connect(callback)
	return result

func _show_menu() -> void:
	Game.running = false
	on_shop = false
	on_inventory = false
	on_upgrades = false
	_clear()
	content.add_child(label("YOUR OWN LITTLE SUCCESS STORY", 13))
	content.add_child(label("Mini Shop\nTycoon", 48))
	var intro: Label = label("Small shelves. Big dreams.", 22)
	content.add_child(intro)
	_add_shop_view()
	var description: Label = label("Stock your shelves and watch your corner shop come alive. Every sale is a fresh start.")
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(description)
	content.add_child(button("Open my shop  →", _show_shop))
	content.add_child(button("Restart progress", _confirm_restart))
	var footer: Label = label("OFFLINE  •  NO ADS  •  v0.3.0 / Phase 3", 13)
	content.add_child(footer)
	if not Game.storage.message.is_empty():
		var warning: Label = label(Game.storage.message, 15)
		warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(warning)

func _add_shop_view() -> void:
	var view: ShopView = ShopView.new()
	view.custom_minimum_size.y = 285
	view.customers = customers
	view.clip_contents = true
	customers.movement_changed.connect(view.queue_redraw)
	content.add_child(view)

func _show_shop() -> void:
	on_shop = true
	on_inventory = false
	on_upgrades = false
	_clear()
	var heading: HBoxContainer = HBoxContainer.new()
	var title: Label = label("My corner shop", 25)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	heading.add_child(button("Menu", _show_menu))
	content.add_child(heading)
	var stats: HBoxContainer = HBoxContainer.new()
	balance_label = label("", 27)
	balance_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_child(balance_label)
	customer_label = label("", 16)
	stats.add_child(customer_label)
	content.add_child(stats)
	revenue_label = label("", 15)
	content.add_child(revenue_label)
	level_label = label("", 16)
	content.add_child(level_label)
	objective_label = label("", 15)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(objective_label)
	_add_shop_view()
	var navigation: HBoxContainer = HBoxContainer.new()
	var inventory_button: Button = button("Stockroom", _show_inventory)
	var upgrades_button: Button = button("Grow shop", _show_upgrades)
	inventory_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrades_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation.add_child(inventory_button)
	navigation.add_child(upgrades_button)
	content.add_child(navigation)
	content.add_child(label("KEEP THE SHELVES HAPPY", 14))
	for product: Dictionary in Game.economy.products.slice(0, 3):
		_add_product_card(product)
	hint_label = label("", 16)
	hint_label.custom_minimum_size.y = 48
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(hint_label)
	var save_note: Label = label("Automatic checkout • Progress saved on this device", 13)
	if Game.storage.blocked:
		save_note.text = "Saving paused: unreadable files preserved. Use Restart progress to start fresh."
		save_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(save_note)
	Game.running = true
	_refresh()
	if Game.storage.blocked:
		_feedback(Game.storage.message)

func _show_inventory() -> void:
	Game.running = false
	on_shop = false
	on_inventory = true
	on_upgrades = false
	_clear()
	inventory_screen = preload("res://scenes/inventory.tscn").instantiate()
	inventory_screen.back_requested.connect(_show_shop)
	content.add_child(inventory_screen)

func _show_upgrades() -> void:
	Game.running = false
	on_shop = false
	on_inventory = false
	on_upgrades = true
	_clear()
	upgrades_screen = preload("res://scenes/upgrades.tscn").instantiate()
	upgrades_screen.back_requested.connect(_show_shop)
	content.add_child(upgrades_screen)

func _show_level_up(level: int) -> void:
	Game.running = false
	var unlocked: Array[String] = []
	for product: Dictionary in Game.economy.products:
		if int(product["unlock_level"]) == level and not product["id"] in Game.economy.retained_unlocks:
			unlocked.append(product["name"])
	level_dialog.dialog_text = "Level %d • %s\n%s\nCheck Grow shop for your next milestone." % [level, Game.economy.progression.level_name(level), "New products: " + ", ".join(unlocked) if not unlocked.is_empty() else "More room to grow your business!"]
	level_dialog.popup_centered(Vector2i(420, 200))

func _add_product_card(product: Dictionary) -> void:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("ffffff")
	style.set_corner_radius_all(15)
	style.content_margin_left = 14
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	var marker: TextureRect = TextureRect.new()
	marker.texture = ProductIcons.texture(product["id"])
	marker.custom_minimum_size = Vector2(32, 40)
	marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marker.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(marker)
	var details: VBoxContainer = VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var stock_label: Label = label("", 19)
	details.add_child(stock_label)
	details.add_child(label("Cost %d • Sells %d" % [int(product["wholesale"]), int(product["price"])], 14))
	row.add_child(details)
	var buy: Button = button("", Game.buy.bind(String(product["id"])))
	buy.custom_minimum_size.x = 133
	row.add_child(buy)
	stock_labels[product["id"]] = stock_label
	buy_buttons[product["id"]] = buy
	content.add_child(panel)

func _refresh() -> void:
	if not on_shop or balance_label == null:
		return
	var economy: ShopEconomy = Game.economy
	balance_label.text = "%d coins" % economy.coins
	customer_label.text = "%d served" % economy.customers
	revenue_label.text = "Sales %d  •  Gross profit %d" % [economy.revenue, economy.revenue - economy.cost_of_goods]
	level_label.text = "Level %d • %s" % [economy.shop_level(), economy.progression.xp_text(economy.customers)]
	objective_label.text = economy.next_objective()
	var total_stock: int = 0
	for product: Dictionary in economy.products:
		var id: String = product["id"]
		var amount: int = int(economy.stock[id])
		total_stock += amount
		if not stock_labels.has(id):
			continue
		stock_labels[id].text = "%s  %d/%d" % [product["name"], amount, economy.capacity(id)]
		var batch: int = int(economy.catalog["stock_batch"])
		var cost: int = batch * int(product["wholesale"])
		buy_buttons[id].text = "+%d / %d coins" % [batch, cost]
		buy_buttons[id].disabled = amount + batch > economy.capacity(id)
		if buy_buttons[id].disabled:
			buy_buttons[id].text = "Shelf full" if amount == economy.capacity(id) else "Need %d spaces" % batch
	if hint_label != null:
		if total_stock == 0:
			hint_label.text = "Start here: buy 5 Bread. Stocked shelves attract customers!"
		elif economy.customers == 0:
			hint_label.text = "Your first customer is on the way. Checkout happens automatically."
		else:
			hint_label.text = "Looking good! Keep stock available to keep the sales coming."

func _feedback(message: String) -> void:
	if hint_label != null:
		hint_label.text = message

func _purchase_feedback(product_name: String, amount: int) -> void:
	if not Game.storage.message.is_empty():
		_feedback(Game.storage.message)
	else:
		_feedback("Sold %s! +%d coins" % [product_name, amount])

func _confirm_restart() -> void:
	Game.running = false
	restart_dialog.popup_centered(Vector2i(390, 190))
	if not restart_dialog.canceled.is_connected(_resume):
		restart_dialog.canceled.connect(_resume)

func _resume() -> void:
	Game.running = on_shop

func _restart() -> void:
	customers.clear()
	Game.restart()
	Game.running = on_shop
	if not on_shop:
		_show_menu()

func _notification(what: int) -> void:
	if embedded:
		return
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if level_dialog != null and level_dialog.visible:
			level_dialog.hide()
			_resume()
		elif restart_dialog != null and restart_dialog.visible:
			restart_dialog.hide()
			_resume()
		elif on_inventory or on_upgrades:
			_show_shop()
		elif on_shop:
			_show_menu()
		else:
			Game.persist()
			get_tree().quit()
