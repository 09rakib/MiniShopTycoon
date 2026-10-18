class_name ProductIcons
extends RefCounted
static var cache: Dictionary = {}

static func texture(id: String) -> Texture2D:
	if not cache.has(id):
		cache[id] = load("res://assets/icons/%s.svg" % id)
	return cache[id]
