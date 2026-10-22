class_name ShopExpansionPanel
extends PanelContainer
signal closed
signal return_to_shop
var wallet: Label
var summary: Label
var machine_button: Button
var furniture_button: Button

func _ready() -> void:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	add_child(box)
	var title: Label = Label.new()
	title.text = "GROW YOUR SHOP"
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)
	wallet = Label.new()
	box.add_child(wallet)
	summary = Label.new()
	summary.add_theme_font_size_override("font_size", 14)
	box.add_child(summary)
	machine_button = Button.new()
	machine_button.custom_minimum_size.y = 88
	machine_button.add_theme_font_size_override("font_size", 16)
	machine_button.pressed.connect(_purchase.bind("fries"))
	box.add_child(machine_button)
	furniture_button = Button.new()
	furniture_button.custom_minimum_size.y = 88
	furniture_button.add_theme_font_size_override("font_size", 16)
	furniture_button.pressed.connect(_purchase.bind("furniture"))
	box.add_child(furniture_button)
	var note: Label = Label.new()
	note.text = "Stocker handles burgers; you deliver fries.\nDining is prepared for a future update."
	note.add_theme_font_size_override("font_size", 14)
	box.add_child(note)
	var back: Button = Button.new()
	back.text = "Back to shop"
	back.custom_minimum_size.y = 52
	back.pressed.connect(return_to_shop.emit)
	box.add_child(back)
	Game.changed.connect(refresh)
	Game.production_changed.connect(refresh)
	Game.handling_changed.connect(refresh)
	refresh()

func _purchase(kind: String) -> void:
	Game.purchase_expansion(kind)
	refresh()

func refresh() -> void:
	var expansion: ShopExpansion = Game.economy.expansion
	wallet.text = "Wallet: %d coins" % Game.economy.coins
	summary.text = "Fries: 3s each • storage 8 • price 16\nCounter fries %d/4 • Seating %d" % [expansion.handling.counter, expansion.seats()]
	machine_button.text = "Fries machine owned\nCollect at FRIES, deliver to counter" if expansion.unlocked else "Unlock fries machine • %d coins\nIncludes 4 fries trays at the counter" % int(expansion.config["machine_cost"])
	machine_button.disabled = expansion.unlocked or Game.economy.coins < int(expansion.config["machine_cost"])
	furniture_button.text = "Table + 2 chairs owned • Seating 2\nFixed placement; paths stay clear" if expansion.furniture else "Table + 2 chairs • %d coins\nSeating capacity +2" % int(expansion.config["furniture_cost"])
	furniture_button.disabled = expansion.furniture or Game.economy.coins < int(expansion.config["furniture_cost"])
