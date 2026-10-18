class_name BurgerSales
extends RefCounted
## Only live, registered customers may consume counter stock, once per visit.
const LIMIT: int = 1000000000000
var uncollected_cash: int = 0
var sold: int = 0
var revenue: int = 0
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

func purchase(ticket: int, handling: BurgerHandling, machine: ProductionState) -> int:
	if not tickets.has(ticket) or tickets[ticket] or handling.counter <= 0:
		return 0
	var price: int = int(machine.definition()["selling_price"])
	if uncollected_cash > LIMIT - price or revenue > LIMIT - price or sold >= LIMIT:
		return 0
	# No signals or awaits until both inventory and cash have been committed.
	tickets[ticket] = true
	handling.counter -= 1
	uncollected_cash += price
	revenue += price
	sold += 1
	return price

func reset() -> void:
	tickets.clear()
	uncollected_cash = 0
	sold = 0
	revenue = 0

func snapshot() -> Dictionary:
	return {"uncollected_cash": uncollected_cash, "sold": sold, "revenue": revenue}

func restore(data: Dictionary) -> bool:
	for key: String in ["uncollected_cash", "sold", "revenue"]:
		if not ProductCatalog.integer_in_range(data.get(key), 0, LIMIT):
			return false
	if int(data["uncollected_cash"]) > int(data["revenue"]) or (int(data["sold"]) == 0) != (int(data["revenue"]) == 0):
		return false
	uncollected_cash = int(data["uncollected_cash"])
	sold = int(data["sold"])
	revenue = int(data["revenue"])
	tickets.clear()
	return true
