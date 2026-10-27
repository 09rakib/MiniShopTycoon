extends Node
signal changed
signal feedback(text: String)
signal production_changed
signal handling_changed
signal burger_sale_completed(amount: int)
signal cash_collected(amount: int)
signal machine_upgraded(kind: String)
signal presentation(kind: String, point: Vector2, amount: int)

var economy: ShopEconomy = ShopEconomy.new()
var storage: LocalSave = LocalSave.new()
var production_dirty: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	storage.load_into(economy)
	get_tree().auto_accept_quit = false

func persist() -> bool:
	if not storage.write(economy):
		feedback.emit(storage.message)
		return false
	production_dirty = false
	return true

func interact_burgers(action: String, worker_position: Vector2) -> bool:
	var previous: Dictionary = _food_checkpoint()
	var result: Dictionary = economy.transfer_food(action, worker_position)
	if int(result["amount"]) <= 0:
		feedback.emit(result["error"])
		return false
	var saved: bool = persist()
	if not saved:
		_rollback_food(previous)
		return false
	handling_changed.emit()
	if saved:
		var amount: int = int(result["amount"])
		presentation.emit("pickup" if action in ["pickup", "fries"] else "serve", worker_position, amount)
		feedback.emit(("Picked up %d item%s." if action in ["pickup", "fries"] else "Delivered %d item%s.") % [amount, "s" if amount != 1 else ""])
	return true

func sell_burger(ticket: int) -> bool:
	var previous: Dictionary = economy.burger_sales.snapshot()
	var tickets: Dictionary = economy.burger_sales.tickets.duplicate()
	var burger_counter: int = economy.handling.counter
	var fries_counter: int = economy.expansion.handling.counter
	var amount: int = economy.burger_sales.purchase(ticket, economy.handling, economy.production, economy.expansion.handling if economy.expansion.unlocked else null, economy.expansion.production if economy.expansion.unlocked else null)
	if amount == 0:
		return false
	var saved: bool = persist()
	if not saved:
		economy.handling.counter = burger_counter
		economy.expansion.handling.counter = fries_counter
		economy.burger_sales.restore(previous)
		economy.burger_sales.tickets = tickets
		handling_changed.emit()
		return false
	handling_changed.emit()
	burger_sale_completed.emit(amount)
	if saved:
		presentation.emit("sale", economy.cash_pickup.point, amount)
	return true

func collect_cash(worker_position: Vector2) -> int:
	var amount: int = economy.collect_cash(worker_position)
	if amount == 0:
		if economy.cash_pickup.is_near(worker_position) and economy.burger_sales.uncollected_cash > 0:
			feedback.emit("Wallet limit reached. Spend coins before collecting cash.")
		return 0
	# Publish a reward only after the combined wallet/cash record is durable.
	if not storage.write(economy):
		economy.coins -= amount
		economy.burger_sales.uncollected_cash += amount
		feedback.emit(storage.message)
		return 0
	production_dirty = false
	changed.emit()
	cash_collected.emit(amount)
	presentation.emit("cash", worker_position, amount)
	return amount

func purchase_operation(kind: String) -> bool:
	var previous_coins: int = economy.coins
	var previous_operations: Dictionary = economy.operations.snapshot()
	var previous_machine: Dictionary = economy.production.snapshot()
	var error: String = economy.purchase_operation(kind)
	if not error.is_empty():
		feedback.emit(error)
		return false
	if not storage.write(economy):
		economy.coins = previous_coins
		economy.operations.restore(previous_operations)
		economy.production.level = int(previous_machine["level"])
		economy.production.capacity_level = int(previous_machine["capacity_level"])
		economy.production.price_level = int(previous_machine["price_level"])
		feedback.emit(storage.message)
		return false
	production_dirty = false
	if kind != "stocker":
		machine_upgraded.emit(kind)
		production_changed.emit()
	changed.emit()
	presentation.emit("hire" if kind == "stocker" else "upgrade", economy.handling.station_point("pickup"), 0)
	feedback.emit("Stocker hired! Two burgers per trip." if kind == "stocker" else "Burger machine upgraded!")
	return true

func purchase_expansion(kind: String) -> bool:
	var previous_coins: int = economy.coins
	var previous: Dictionary = economy.expansion.snapshot()
	var error: String = economy.purchase_expansion(kind)
	if not error.is_empty():
		feedback.emit(error)
		return false
	if not storage.write(economy):
		economy.coins = previous_coins
		economy.expansion.restore(previous)
		feedback.emit(storage.message)
		return false
	production_dirty = false
	changed.emit()
	production_changed.emit()
	presentation.emit("unlock", economy.expansion.handling.station_point("pickup") if kind == "fries" else Vector2(170, 790), 0)
	feedback.emit("Fries machine unlocked! Collect at FRIES." if kind == "fries" else "Table and two chairs placed. Seating: 2.")
	return true

func stocker_transfer(action: String, worker_position: Vector2) -> int:
	var previous: Dictionary = _food_checkpoint()
	var result: Dictionary = economy.handling.transfer(action, worker_position, economy.production, economy.operations)
	var amount: int = int(result["amount"])
	if amount > 0:
		production_dirty = true
		var saved: bool = persist()
		if not saved:
			_rollback_food(previous)
			return 0
		handling_changed.emit()
		if saved:
			presentation.emit("staff_pickup" if action == "pickup" else "staff_serve", worker_position, amount)
	return amount

func _food_checkpoint() -> Dictionary:
	return {"stock": economy.production.stock, "carried": economy.handling.carried,
		"counter": economy.handling.counter, "fries_stock": economy.expansion.production.stock,
		"fries_carried": economy.expansion.handling.carried, "fries_counter": economy.expansion.handling.counter,
		"staff_carried": economy.operations.carried, "dirty": production_dirty}

func _rollback_food(previous: Dictionary) -> void:
	economy.production.stock = previous["stock"]
	economy.handling.carried = previous["carried"]
	economy.handling.counter = previous["counter"]
	economy.expansion.production.stock = previous["fries_stock"]
	economy.expansion.handling.carried = previous["fries_carried"]
	economy.expansion.handling.counter = previous["fries_counter"]
	economy.operations.carried = previous["staff_carried"]
	production_changed.emit()
	handling_changed.emit()
	production_dirty = previous["dirty"]

func restart() -> void:
	if storage.reset_with(economy):
		production_dirty = false
		changed.emit()
		production_changed.emit()
		handling_changed.emit()
		feedback.emit("A fresh start — your food shop is ready!")
	else:
		feedback.emit(storage.message)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		persist()
		get_tree().paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		get_tree().paused = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		persist()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		persist()
		get_tree().quit()
