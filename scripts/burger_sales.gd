class_name BurgerSales
extends RefCounted
## Only live, registered customers may consume counter stock, once per visit.
const LIMIT: int = 1000000000000
var uncollected_cash: int = 0
var sold: int = 0
var revenue: int = 0
var next_fries: bool = false
var tickets: Dictionary = {}
var next_ticket: int = 0
var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/customers.json"))

func register_customer() -> int:
	if tickets.size() >= int(config["max_active"]):
		return 0
	next_ticket += 1
	tickets[next_ticket] = false
	return next_ticket

func retire(ticket: int) -> void:
	tickets.erase(ticket)

func gross_profit() -> int:
	# Automatic burgers currently have zero ingredient cost; collecting is not a sale.
	return revenue

func collected_cash() -> int:
	return revenue - uncollected_cash

func purchase(ticket: int, handling: BurgerHandling, machine: ProductionState, other_handling: BurgerHandling = null, other_machine: ProductionState = null) -> int:
	var inventory: BurgerHandling = handling
	var source: ProductionState = machine
	# Alternate when both shelves have food; otherwise sell what is stocked.
	var fries_ready: bool = other_handling != null and other_machine != null and other_handling.counter > 0
	if fries_ready and (handling.counter <= 0 or next_fries):
		inventory = other_handling
		source = other_machine
	if not tickets.has(ticket) or tickets[ticket] or inventory.counter <= 0:
		return 0
	var price: int = source.selling_price()
	if uncollected_cash > LIMIT - price or revenue > LIMIT - price or sold >= LIMIT:
		return 0
	# No signals or awaits until both inventory and cash have been committed.
	tickets[ticket] = true
	inventory.counter -= 1
	uncollected_cash += price
	revenue += price
	sold += 1
	next_fries = inventory == handling
	return price

func reset() -> void:
	tickets.clear()
	uncollected_cash = 0
	sold = 0
	revenue = 0
	next_fries = false

func snapshot() -> Dictionary:
	return {"uncollected_cash": uncollected_cash, "sold": sold, "revenue": revenue, "next_fries": next_fries}

func restore(data: Dictionary) -> bool:
	for key: String in ["uncollected_cash", "sold", "revenue"]:
		if not ProductCatalog.integer_in_range(data.get(key), 0, LIMIT):
			return false
	if not data.get("next_fries", false) is bool:
		return false
	if int(data["uncollected_cash"]) > int(data["revenue"]) or (int(data["sold"]) == 0) != (int(data["revenue"]) == 0):
		return false
	next_fries = data.get("next_fries", false)
	uncollected_cash = int(data["uncollected_cash"])
	sold = int(data["sold"])
	revenue = int(data["revenue"])
	tickets.clear()
	return true
