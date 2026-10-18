extends Node
signal changed
signal feedback(text: String)
signal level_up(level: int)
signal production_changed

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

func restart() -> void:
	if storage.reset_with(economy):
		production_dirty = false
		changed.emit()
		production_changed.emit()
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
