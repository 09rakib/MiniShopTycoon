class_name InventoryScreen
extends VBoxContainer
signal back_requested

var wallet: Label
var ledger: Label
var feedback_label: Label
var stocks: Dictionary = {}
var singles: Dictionary = {}
var batches: Dictionary = {}
var list_scroll: ScrollContainer

func _ready() -> void:
	var heading: HBoxContainer = HBoxContainer.new()
	var title: Label = _label("Stockroom", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	heading.add_child(_button("Shop →", func() -> void: back_requested.emit()))
	add_child(heading)
	wallet = _label("", 26)
	add_child(wallet)
	ledger = _label("", 15)
	ledger.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(ledger)
	feedback_label = _label("Buy stock here. Customers wait while you plan.", 16)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.custom_minimum_size.y = 46
	add_child(feedback_label)
	list_scroll = ScrollContainer.new()
	list_scroll.custom_minimum_size.y = 500
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(list_scroll)
	var cards: VBoxContainer = VBoxContainer.new()
	cards.add_theme_constant_override("separation", 12)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.add_child(cards)
	for product: Dictionary in Game.economy.products:
		_add_card(cards, product)
	var note: Label = _label("Sales earn %d XP each. Level up to unlock products.\nGross profit = sales − wholesale cost of sold units." % int(Game.economy.progression.config["xp_per_customer"]), 13)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(note)
	Game.changed.connect(refresh)
	Game.feedback.connect(_feedback)
	refresh()
	if Game.storage.blocked:
		_feedback(Game.storage.message)

func _label(text: String, font_size: int) -> Label:
	var result: Label = Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	return result

func _button(text: String, callback: Callable) -> Button:
	var result: Button = Button.new()
	result.text = text
	result.custom_minimum_size.y = 52
	result.pressed.connect(callback)
	return result

func _add_card(parent: VBoxContainer, product: Dictionary) -> void:
	var id: String = product["id"]
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.set_corner_radius_all(15)
	for side: String in ["left", "right", "top", "bottom"]:
		style.set("content_margin_" + side, 12.0)
	panel.add_theme_stylebox_override("panel", style)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 7)
	panel.add_child(body)
	var top: HBoxContainer = HBoxContainer.new()
	var icon: TextureRect = TextureRect.new()
	icon.texture = ProductIcons.texture(id)
	icon.custom_minimum_size = Vector2(42, 42)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top.add_child(icon)
	var name_label: Label = _label(product["name"], 20)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_label)
	var amount: Label = _label("", 17)
	stocks[id] = amount
	top.add_child(amount)
	body.add_child(top)
	body.add_child(_label("%s • Cost %d • Sell %d • Margin +%d" % [product["category"], int(product["wholesale"]), int(product["price"]), int(product["price"]) - int(product["wholesale"])], 14))
	var actions: HBoxContainer = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	var single: Button = _button("", Game.buy.bind(id, 1))
	var batch: Button = _button("", Game.buy.bind(id, int(Game.economy.catalog["stock_batch"])))
	single.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	batch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	singles[id] = single
	batches[id] = batch
	actions.add_child(single)
	actions.add_child(batch)
	body.add_child(actions)
	parent.add_child(panel)

func refresh() -> void:
	var economy: ShopEconomy = Game.economy
	wallet.text = "%d coins" % economy.coins
	ledger.text = "Level %d • %d/10 products • Upgrades spent %d\nStock bought %d • Sales %d\nGross profit %d • Unsold stock cost %d" % [economy.shop_level(), economy.unlocked_count(), economy.upgrade_spending, economy.stock_spending, economy.revenue, economy.revenue - economy.cost_of_goods, economy.inventory_value()]
	for product: Dictionary in economy.products:
		var id: String = product["id"]
		var amount: int = int(economy.stock[id])
		var room: int = economy.capacity(id) - amount
		var batch: int = int(economy.catalog["stock_batch"])
		stocks[id].text = "%d / %d" % [amount, economy.capacity(id)]
		if not economy.is_unlocked(id):
			stocks[id].text = "Level %d" % int(product["unlock_level"])
			singles[id].text = "Locked"
			batches[id].text = "Level %d required" % int(product["unlock_level"])
			singles[id].disabled = true
			batches[id].disabled = true
			continue
		singles[id].text = "+1 / %d coins" % int(product["wholesale"]) if room > 0 else "Shelf full"
		batches[id].text = "+%d / %d coins" % [batch, batch * int(product["wholesale"])] if room >= batch else "Need %d spaces" % batch
		singles[id].disabled = room < 1
		batches[id].disabled = room < batch

func _feedback(message: String) -> void:
	feedback_label.text = message.replace("Customers check out automatically!", "Return to the shop for customers.")
