class_name BurgerOperationsPanel
extends PanelContainer
signal closed
signal return_to_shop
var wallet: Label
var summary: Label
var buttons: Dictionary = {}

func _ready() -> void:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	add_child(box)
	var title: Label = Label.new()
	title.text = "BURGER WORKSHOP"
	title.add_theme_font_size_override("font_size", 23)
	box.add_child(title)
	wallet = Label.new()
	box.add_child(wallet)
	summary = Label.new()
	summary.add_theme_font_size_override("font_size", 14)
	box.add_child(summary)
	for kind: String in ["speed", "capacity", "price", "stocker"]:
		var button: Button = Button.new()
		button.custom_minimum_size.y = 72
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(_purchase.bind(kind))
		box.add_child(button)
		buttons[kind] = button
	var back: HBoxContainer = HBoxContainer.new()
	box.add_child(back)
	for label: String in ["Menu", "Back to shop"]:
		var button: Button = Button.new()
		button.text = label
		button.custom_minimum_size.y = 52
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void:
			if label == "Menu":
				closed.emit()
			else:
				return_to_shop.emit())
		back.add_child(button)
	Game.changed.connect(refresh)
	Game.handling_changed.connect(refresh)
	Game.production_changed.connect(refresh)
	refresh()

func _purchase(kind: String) -> void:
	Game.purchase_operation(kind)
	refresh()

func refresh() -> void:
	var machine: ProductionState = Game.economy.production
	var operations: ShopOperations = Game.economy.operations
	wallet.text = "Wallet: %d coins" % Game.economy.coins
	summary.text = "Press %d/%d • Staff carrying %d/2\nCash waiting: %d • Collect it to spend" % [machine.stock, machine.capacity(), operations.carried, Game.economy.burger_sales.uncollected_cash]
	for kind: String in ["speed", "capacity", "price"]:
		var cost: int = machine.upgrade_cost(kind)
		var current: int = machine.upgrade_level(kind)
		var description: String
		if kind == "speed":
			description = "Speed %d • %.1fs" % [current, machine.interval()]
			if cost >= 0:
				description += " → %.1fs" % float(machine.definition()["levels"][current]["interval"])
		elif kind == "capacity":
			description = "Capacity %d • %d burgers" % [current, machine.capacity()]
			if cost >= 0:
				description += " → %d" % int(machine.definition()["levels"][current]["capacity"])
		else:
			description = "Price %d • %d coins" % [current, machine.selling_price()]
			if cost >= 0:
				description += " → %d" % int(machine.definition()["price_levels"][current]["price"])
		buttons[kind].text = description + ("\nMAX" if cost < 0 else "\nUpgrade • %d coins" % cost)
		buttons[kind].disabled = cost < 0 or Game.economy.coins < cost
	buttons["stocker"].text = "Stocker hired • Carry %d/2\nAutomatically restocks your counter" % operations.carried if operations.hired else "Hire stocker • %d coins\nWalks and carries up to 2 per trip" % int(operations.config["hire_cost"])
	buttons["stocker"].disabled = operations.hired or Game.economy.coins < int(operations.config["hire_cost"])
