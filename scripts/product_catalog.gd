class_name ProductCatalog
extends RefCounted
## Fail clearly on invalid developer data before any economy transaction occurs.
static func validate(data: Dictionary) -> String:
	for key: String in ["starting_coins", "stock_batch", "max_customers"]:
		if not integer_in_range(data.get(key), 1, 1000000):
			return "Invalid catalog setting: " + key
	for key: String in ["customer_interval", "customer_duration"]:
		var value: Variant = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or float(value) < 0.5:
			return "Invalid customer timing: " + key
	if int(data["max_customers"]) > 16:
		return "Customer pool must be at most 16."
	if not data.get("products") is Array or data["products"].is_empty():
		return "Catalog needs products."
	var seen: Dictionary = {}
	for entry: Variant in data["products"]:
		if not entry is Dictionary:
			return "Invalid product definition."
		var product: Dictionary = entry
		for key: String in ["id", "name", "category", "color"]:
			if not product.get(key) is String or String(product[key]).is_empty():
				return "Missing product field: " + key
		if seen.has(product["id"]):
			return "Duplicate product ID: " + String(product["id"])
		seen[product["id"]] = true
		if not Color.html_is_valid(product["color"]):
			return "Invalid product color."
		for key: String in ["wholesale", "price", "capacity", "unlock_level"]:
			if not integer_in_range(product.get(key), 1, 1000000):
				return "Invalid product value: " + key
		if int(product["price"]) <= int(product["wholesale"]):
			return "Selling price must exceed wholesale cost."
		if int(product["capacity"]) > 10000 or int(data["stock_batch"]) > int(product["capacity"]):
			return "Invalid shelf capacity or batch size."
		if not integer_in_range(product.get("shelf"), 0, 2):
			return "Product must map to a visible shelf."
	return ""

static func integer_in_range(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) \
		and float(value) == floor(float(value)) and float(value) >= minimum and float(value) <= maximum
