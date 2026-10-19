extends Node
signal changed
signal feedback(text: String)
signal level_up(level: int)
signal production_changed
signal handling_changed
signal burger_sale_completed(amount: int)
signal cash_collected(amount: int)
signal machine_upgraded(kind: String)

var economy: ShopEconomy = ShopEconomy.new()
var storage: LocalSave = LocalSave.new()
var running: bool = false
var production_dirty: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	storage.load_into(economy)
	get_tree().auto_accept_quit = false

func buy(id: String, quantity: int = 0) -> void:
	var requested: int = int(economy.catalog["stock_batch"]) if quantity == 0 else quantity
	var error: String = economy.buy(id, requested)
	if error.is_empty():
		var saved: bool = persist()
		changed.emit()
		if saved:
			feedback.emit("Shelf stocked. Customers check out automatically!")
	else:
		feedback.emit(error)

func sell(id: String) -> bool:
	var before_level: int = economy.shop_level()
	if not economy.sell(id):
		return false
	persist()
	changed.emit()
	if economy.shop_level() > before_level:
		level_up.emit(economy.shop_level())
	return true

func buy_upgrade(id: String) -> void:
	var error: String = economy.buy_upgrade(id)
	if not error.is_empty():
		feedback.emit(error)
		return
	var saved: bool = persist()
	changed.emit()
	if saved:
		feedback.emit("Shelf upgraded! +%d capacity for every product in this group." % int(economy.upgrade_rules.find(id)["capacity_per_level"]))

func persist() -> bool:
	if not storage.write(economy):
		feedback.emit(storage.message)
		return false
	production_dirty = false
	return true

func interact_burgers(action: String, worker_position: Vector2) -> bool:
	var result: Dictionary = economy.handling.transfer(action, worker_position, economy.production)
	if int(result["amount"]) <= 0:
		feedback.emit(result["error"])
		return false
	var saved: bool = persist()
	handling_changed.emit()
	if saved:
		var amount: int = int(result["amount"])
		feedback.emit(("Picked up %d burger%s." if action == "pickup" else "Delivered %d burger%s.") % [amount, "s" if amount != 1 else ""])
	return true

func sell_burger(ticket: int) -> bool:
	var amount: int = economy.burger_sales.purchase(ticket, economy.handling, economy.production)
	if amount == 0:
		return false
	persist()
	handling_changed.emit()
	burger_sale_completed.emit(amount)
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
	feedback.emit("Stocker hired! Two burgers per trip." if kind == "stocker" else "Burger machine upgraded!")
	return true

func stocker_transfer(action: String, worker_position: Vector2) -> int:
	var result: Dictionary = economy.handling.transfer(action, worker_position, economy.production, economy.operations)
	var amount: int = int(result["amount"])
	if amount > 0:
		production_dirty = true
		persist()
		handling_changed.emit()
	return amount

func restart() -> void:
	if storage.reset_with(economy):
		production_dirty = false
		changed.emit()
		production_changed.emit()
		handling_changed.emit()
		feedback.emit("A fresh start — stock your first shelf!")
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
