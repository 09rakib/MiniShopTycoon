class_name UpgradesScreen
extends VBoxContainer
signal back_requested
var summary: Label
var objective: Label
var feedback_label: Label
var upgrade_details: Dictionary = {}
var upgrade_buttons: Dictionary = {}
var goal_labels: Array[Label] = []

func _ready() -> void:
	var heading: HBoxContainer = HBoxContainer.new()
	var title: Label = make_label("Grow your shop", 26)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	heading.add_child(make_button("Shop →", func() -> void: back_requested.emit()))
	add_child(heading)
	summary = make_label("", 19)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(summary)
	objective = make_label("", 16)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(objective)
	feedback_label = make_label("Each shelf upgrade adds space for every product in that group.", 15)
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.custom_minimum_size.y = 42
	add_child(feedback_label)
	for definition: Dictionary in Game.economy.upgrade_rules.definitions:
		var panel: PanelContainer = PanelContainer.new()
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color.WHITE
		style.set_corner_radius_all(15)
		for side: String in ["left", "right", "top", "bottom"]:
			style.set("content_margin_" + side, 12.0)
		panel.add_theme_stylebox_override("panel", style)
		var body: VBoxContainer = VBoxContainer.new()
		body.add_theme_constant_override("separation", 8)
		panel.add_child(body)
		var details: Label = make_label("", 17)
		details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_child(details)
		var buy: Button = make_button("", Game.buy_upgrade.bind(String(definition["id"])))
		body.add_child(buy)
		upgrade_details[definition["id"]] = details
		upgrade_buttons[definition["id"]] = buy
		add_child(panel)
	add_child(make_label("YOUR MILESTONES", 16))
	for goal: Dictionary in Game.economy.goals():
		var goal_label: Label = make_label(goal["title"], 16)
		goal_labels.append(goal_label)
		add_child(goal_label)
	var note: Label = make_label("Milestones track your shop's growth.\nGross profit excludes upgrade spending; upgrades are shown separately.", 13)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(note)
	Game.changed.connect(refresh)
	Game.feedback.connect(_feedback)
	refresh()
	if Game.storage.blocked:
		_feedback(Game.storage.message)

func make_label(text: String, font_size: int) -> Label:
	var value: Label = Label.new()
	value.text = text
	value.add_theme_font_size_override("font_size", font_size)
	return value

func make_button(text: String, callback: Callable) -> Button:
	var value: Button = Button.new()
	value.text = text
	value.custom_minimum_size.y = 52
	value.pressed.connect(callback)
	return value

func refresh() -> void:
	var economy: ShopEconomy = Game.economy
	summary.text = "%d coins • Level %d\n%s • Upgrades spent %d" % [economy.coins, economy.shop_level(), economy.progression.xp_text(economy.customers), economy.upgrade_spending]
	objective.text = economy.next_objective()
	for definition: Dictionary in economy.upgrade_rules.definitions:
		var id: String = definition["id"]
		var current: int = int(economy.shelf_upgrades[id])
		var cost: int = economy.upgrade_rules.cost(id, current)
		var bonus: int = current * int(definition["capacity_per_level"])
		# Base capacities are configured per product; show the bonus independently.
		upgrade_details[id].text = "%s • Upgrade %d/%d\nCapacity bonus +%d per product" % [definition["name"], current, definition["requirements"].size(), bonus]
		if cost < 0:
			upgrade_buttons[id].text = "Fully upgraded"
			upgrade_buttons[id].disabled = true
			continue
		var requirement: int = int(definition["requirements"][current])
		upgrade_details[id].text += " → +%d\nNext upgrade %d → %d • Requires shop level %d" % [bonus + int(definition["capacity_per_level"]), current, current + 1, requirement]
		upgrade_buttons[id].text = "Upgrade / %d coins" % cost if economy.shop_level() >= requirement else "Level %d required • %d coins" % [requirement, cost]
		upgrade_buttons[id].disabled = economy.shop_level() < requirement
	var rows: Array[Dictionary] = economy.goals()
	for index: int in rows.size():
		var goal: Dictionary = rows[index]
		goal_labels[index].text = "%s %s • %d/%d" % ["✓" if goal["complete"] else "○", goal["title"], int(goal["value"]), int(goal["target"])]

func _feedback(message: String) -> void:
	feedback_label.text = message
