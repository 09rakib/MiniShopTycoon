class_name ShopEconomy
extends RefCounted
## All transactions are synchronous; the UI never writes balances or inventory.

var catalog: Dictionary
var products: Array = []
var coins: int
var revenue: int = 0
var cost_of_goods: int = 0
var customers: int = 0
var stock: Dictionary = {}
var stock_spending: int = 0
var upgrade_spending: int = 0
var shelf_upgrades: Dictionary = {}
var retained_unlocks: Array[String] = []
var progression: ShopProgression = ShopProgression.new()
var upgrade_rules: ShelfUpgrades = ShelfUpgrades.new()
var production: ProductionState = ProductionState.new()
const MAX_TOTAL: int = 1000000000000
const LEGACY_PRODUCTS: Array[String] = ["bread", "milk", "apples"]

func _init() -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/catalog.json"))
	var error: String = ProductCatalog.validate(catalog)
	assert(error.is_empty(), error)
	products = catalog["products"]
	reset()

func reset() -> void:
	production.reset()
	coins = int(catalog["starting_coins"])
	revenue = 0
	cost_of_goods = 0
	customers = 0
	stock_spending = 0
	upgrade_spending = 0
	retained_unlocks.clear()
	shelf_upgrades.clear()
	for definition: Dictionary in upgrade_rules.definitions:
		shelf_upgrades[definition["id"]] = 0
	stock.clear()
	for product: Dictionary in products:
		stock[product["id"]] = 0

func find_product(id: String) -> Dictionary:
	for product: Dictionary in products:
		if product["id"] == id:
			return product
	return {}

func buy(id: String, quantity: int) -> String:
	var product: Dictionary = find_product(id)
	if product.is_empty() or quantity <= 0:
		return "Invalid stock order."
	if not is_unlocked(id):
		return "%s unlocks at shop level %d." % [product["name"], int(product["unlock_level"])]
	# Compare before adding/multiplying, so even INT64_MAX orders cannot overflow.
	if quantity > capacity(id) - int(stock[id]):
		return "Not enough shelf space for this order. Try +1 or wait for a sale."
	var cost: int = int(product["wholesale"]) * quantity
	if coins < cost:
		return "Not enough coins for this order."
	if stock_spending > MAX_TOTAL - cost:
		return "Stock spending limit reached."
	coins -= cost
	stock_spending += cost
	stock[id] = int(stock[id]) + quantity
	return ""

func sell(id: String) -> bool:
	var product: Dictionary = find_product(id)
	if product.is_empty() or int(stock.get(id, 0)) <= 0:
		return false
	if coins > MAX_TOTAL - int(product["price"]) or revenue > MAX_TOTAL - int(product["price"]) \
		or cost_of_goods > MAX_TOTAL - int(product["wholesale"]) or customers >= MAX_TOTAL:
		return false
	stock[id] = int(stock[id]) - 1
	coins += int(product["price"])
	revenue += int(product["price"])
	cost_of_goods += int(product["wholesale"])
	customers += 1
	return true

func shop_level() -> int:
	return progression.level_for(customers)

func is_unlocked(id: String) -> bool:
	var product: Dictionary = find_product(id)
	return not product.is_empty() and (id in retained_unlocks or shop_level() >= int(product["unlock_level"]))

func capacity(id: String) -> int:
	var product: Dictionary = find_product(id)
	if product.is_empty():
		return 0
	return int(product["capacity"]) + upgrade_rules.bonus(int(product["shelf"]), shelf_upgrades)

func unlocked_count() -> int:
	var result: int = 0
	for product: Dictionary in products:
		if is_unlocked(product["id"]):
			result += 1
	return result

func upgrade_count() -> int:
	var result: int = 0
	for value: int in shelf_upgrades.values():
		result += value
	return result

func goals() -> Array[Dictionary]:
	return progression.goal_rows(customers, stock_spending, upgrade_count(), unlocked_count())

func next_objective() -> String:
	for goal: Dictionary in goals():
		if not goal["complete"]:
			return "Next: %s (%d/%d)" % [goal["title"], int(goal["value"]), int(goal["target"])]
	return "All milestones reached! Keep your market thriving."

func buy_upgrade(id: String) -> String:
	var definition: Dictionary = upgrade_rules.find(id)
	if definition.is_empty():
		return "Unknown upgrade."
	var current: int = int(shelf_upgrades[id])
	var cost: int = upgrade_rules.cost(id, current)
	if cost < 0:
		return "This shelf is fully upgraded."
	var required_level: int = int(definition["requirements"][current])
	if shop_level() < required_level:
		return "Requires shop level %d." % required_level
	if coins < cost:
		return "Not enough coins for this upgrade."
	var can_sell: bool = false
	var seed_cost: int = MAX_TOTAL
	for product: Dictionary in products:
		can_sell = can_sell or int(stock[product["id"]]) > 0
		if is_unlocked(product["id"]):
			seed_cost = mini(seed_cost, int(product["wholesale"]))
	if not can_sell and coins - cost < seed_cost:
		return "Keep at least %d coins to buy stock before upgrading." % seed_cost
	if upgrade_spending > MAX_TOTAL - cost:
		return "Upgrade spending limit reached."
	coins -= cost
	upgrade_spending += cost
	shelf_upgrades[id] = current + 1
	return ""

func snapshot() -> Dictionary:
	return {"schema_version": 4, "coins": coins, "revenue": revenue, "stock_spending": stock_spending,
		"production": production.snapshot(),
		"upgrade_spending": upgrade_spending, "shelf_upgrades": shelf_upgrades.duplicate(),
		"retained_unlocks": retained_unlocks.duplicate(),
		"cost_of_goods": cost_of_goods, "customers": customers,
		"stock": stock.duplicate(), "saved_at": int(Time.get_unix_time_from_system())}

func inventory_value() -> int:
	var total: int = 0
	for product: Dictionary in products:
		total += int(stock[product["id"]]) * int(product["wholesale"])
	return total

func restore(data: Dictionary) -> bool:
	# Validate the entire record before touching working state.
	if not _valid_integer(data.get("schema_version"), 1, 4) or not data.get("stock") is Dictionary:
		return false
	for key: String in ["coins", "revenue", "cost_of_goods", "customers"]:
		if not _valid_integer(data.get(key), 0, MAX_TOTAL):
			return false
	if int(data["cost_of_goods"]) > int(data["revenue"]):
		return false
	var loaded_stock: Dictionary = data["stock"]
	var version: int = int(data["schema_version"])
	var loaded_spending: Variant = data.get("stock_spending")
	if version == 1:
		# Phase 1 had no rewards/expenses beyond stock, so spending is reconstructible.
		loaded_spending = 500 + int(data["revenue"]) - int(data["coins"])
	if not _valid_integer(loaded_spending, 0, MAX_TOTAL):
		return false
	var loaded_upgrades: Dictionary = {}
	var loaded_retained: Array[String] = []
	var loaded_upgrade_spending: Variant = 0
	if version >= 3:
		if not data.get("shelf_upgrades") is Dictionary or not data.get("retained_unlocks") is Array:
			return false
		loaded_upgrade_spending = data.get("upgrade_spending")
		if not _valid_integer(loaded_upgrade_spending, 0, MAX_TOTAL):
			return false
		for definition: Dictionary in upgrade_rules.definitions:
			var value: Variant = data["shelf_upgrades"].get(definition["id"])
			if not _valid_integer(value, 0, definition["requirements"].size()):
				return false
			loaded_upgrades[definition["id"]] = int(value)
		for id: Variant in data["retained_unlocks"]:
			if not id is String or find_product(id).is_empty() or id in loaded_retained:
				return false
			loaded_retained.append(id)
	else:
		# Existing versions had no product locks: never take away prior access.
		for product: Dictionary in products:
			if version == 2 or product["id"] in LEGACY_PRODUCTS:
				loaded_retained.append(product["id"])
	for product: Dictionary in products:
		var fallback: Variant = 0 if version == 1 and not product["id"] in LEGACY_PRODUCTS else null
		var max_stock: int = int(product["capacity"]) + upgrade_rules.bonus(int(product["shelf"]), loaded_upgrades)
		if not _valid_integer(loaded_stock.get(product["id"], fallback), 0, max_stock):
			return false
	var loaded_production: ProductionState = ProductionState.new()
	if version == 4:
		if not data.get("production") is Dictionary or not loaded_production.restore(data["production"]):
			return false
	# All fields have validated. Update the existing instance so controllers keep
	# their reference across restores/resets; no partial state is applied earlier.
	production.restore(loaded_production.snapshot())
	coins = int(data["coins"])
	revenue = int(data["revenue"])
	cost_of_goods = int(data["cost_of_goods"])
	customers = int(data["customers"])
	stock_spending = int(loaded_spending)
	upgrade_spending = int(loaded_upgrade_spending)
	retained_unlocks = loaded_retained
	for definition: Dictionary in upgrade_rules.definitions:
		shelf_upgrades[definition["id"]] = int(loaded_upgrades.get(definition["id"], 0))
	for product: Dictionary in products:
		stock[product["id"]] = int(loaded_stock.get(product["id"], 0))
	return true

func _valid_integer(value: Variant, minimum: int, maximum: int) -> bool:
	return ProductCatalog.integer_in_range(value, minimum, maximum)
