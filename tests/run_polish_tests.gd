extends SceneTree
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(value: bool, description: String) -> void:
	checks += 1
	if value:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _run() -> void:
	var folder: String = "user://polish-tests-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	var settings: ShopSettings = ShopSettings.new(folder)
	check(settings.load_settings() and settings.enabled, "Missing preferences default to sound on")
	check(settings.save_enabled(false), "Sound preference writes successfully")
	var restored: ShopSettings = ShopSettings.new(folder)
	check(restored.load_settings() and not restored.enabled, "Muted setting survives fresh settings instance")
	check(restored.save_enabled(true) and restored.load_settings() and restored.enabled, "Existing preference can be atomically replaced")
	var invalid: ShopSettings = ShopSettings.new(folder.path_join("missing"))
	check(not invalid.save_enabled(false) and invalid.enabled, "Failed setting write preserves active value")
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "enabled", "wrong type")
	config.save(folder.path_join("preferences.cfg"))
	check(not restored.load_settings() and restored.enabled, "Malformed preference safely falls back to on")
	restored.save_enabled(true)
	var game: Node = root.get_node("Game")
	game.economy = ShopEconomy.new()
	game.storage = LocalSave.new(folder)
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	await process_frame
	var audio: Node = scene.audio
	check(audio.voices.size() == 4 and scene.world.cues.size() == 4, "Sound voices and visual cues use fixed four-instance pools")
	check(audio.CLIPS.size() == 8, "Eight original local audio clips available offline")
	for name: String in audio.CLIPS:
		var clip: AudioStreamWAV = audio.CLIPS[name]
		check(clip.get_length() >= 0.05 and clip.get_length() <= 0.31 and not clip.stereo and clip.mix_rate == 22050, name + " is short mono 22kHz audio")
	audio.last_play.clear()
	check(audio.play("pickup") and not audio.play("pickup"), "Repeated sound within 80ms is suppressed")
	check(not audio.play("unknown") and not audio.play("produce"), "Unknown events and repetitive production remain silent")
	scene._toggle_sound()
	check(not audio.settings.enabled and scene.sound_button.text == "Sound: Off", "Menu toggle mutes and updates its label")
	check(not audio.play("cash"), "Muted audio rejects gameplay cues")
	var stopped: bool = true
	for voice: AudioStreamPlayer in audio.voices:
		stopped = stopped and not voice.playing
	check(stopped, "Muting stops all active voices immediately")
	check(restored.load_settings() and not restored.enabled, "Menu mute persists to local preferences")
	var events: Array[String] = []
	game.presentation.connect(func(kind: String, _point: Vector2, _amount: int) -> void: events.append(kind))
	game.economy.production.produce_one()
	var pickup: Vector2 = game.economy.handling.station_point("pickup")
	check(game.interact_burgers("pickup", pickup) and events.back() == "pickup", "Real saved pickup emits presentation event")
	check(scene.world.cues[0].visible and scene.world.cues[0].caption == "+1 PICKED", "Pickup displays actual transferred quantity")
	var event_count: int = events.size()
	game.interact_burgers("pickup", pickup)
	check(events.size() == event_count, "Empty machine cannot emit a false pickup effect")
	check(game.interact_burgers("deliver", game.economy.handling.station_point("deliver")) and events.back() == "serve", "Real counter transfer emits serve effect")
	var before: int = game.economy.coins
	var nodes: int = get_node_count()
	for index: int in 2000:
		game.presentation.emit("pickup", pickup, 1)
	check(get_node_count() == nodes and audio.voices.size() == 4 and scene.world.cues.size() == 4, "Two thousand presentation events do not grow node pools")
	check(game.economy.coins == before and game.economy.handling.counter == 1, "Presentation events cannot mutate money or stock")
	var ticket: int = game.economy.burger_sales.register_customer()
	check(game.sell_burger(ticket) and events.back() == "sale", "Committed customer sale emits cash accrual feedback")
	event_count = events.size()
	check(not game.sell_burger(ticket) and events.size() == event_count, "Duplicate customer sale emits no effect")
	check(game.collect_cash(game.economy.cash_pickup.point) == 20 and events.back() == "cash", "Cash effect follows exact successful wallet transfer")
	event_count = events.size()
	check(game.collect_cash(game.economy.cash_pickup.point) == 0 and events.size() == event_count, "Empty cash collection emits no reward")
	game.economy.coins = 2000
	check(game.purchase_operation("speed") and events.back() == "upgrade", "Paid machine upgrade emits upgrade feedback")
	check(game.purchase_operation("stocker") and events.back() == "hire", "Paid stocker hire emits distinct feedback")
	scene.stocker_controller.set_paused(true)
	check(game.purchase_expansion("fries") and events.back() == "unlock", "Paid expansion emits unlock feedback")
	event_count = events.size()
	check(not game.purchase_expansion("fries") and events.size() == event_count, "Owned expansion cannot replay purchase feedback")
	for cue: Node in scene.world.cues:
		cue._process(1)
		check(not cue.visible and not cue.is_processing(), "Expired cue stops processing and hides")
	scene._toggle_sound()
	audio.last_play.clear()
	check(audio.play("cash"), "Enabling sound restores playback")
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(audio.suspended and not audio.play("serve") and scene.world.presentation_paused, "Focus loss suspends audio and world presentation")
	check(scene.world.player.hand_lift == 0 and not scene.world.cash_reward.visible, "Pause clears transient pose and cash reward")
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	check(not audio.suspended and not scene.world.presentation_paused, "Resume accepts fresh presentation events")
	scene.production_controller.set_paused(true)
	scene.fries_controller.set_paused(true)
	scene.customer_controller.set_paused(true)
	game.economy.production.stock = game.economy.production.capacity()
	scene.world._refresh_machine()
	for fixture: Node in scene.world.fixtures:
		if fixture.definition.id == "burger_machine":
			check(not fixture.is_processing(), "Full machine stops idle animation processing")
		elif fixture.definition.id != "fries_machine":
			check(not fixture.is_processing(), "Static fixture has no animation loop")
	for index: int in 20:
		scene.open_menu()
		scene._open_operations()
		scene.close_menu()
	await create_timer(0.2).timeout
	check(not scene.menu.visible and not scene.operations_layer.visible and scene.joystick.enabled and scene.menu.modulate.a == 1, "Rapid menu transitions leave controls and visibility consistent")
	scene.open_menu()
	await create_timer(0.2).timeout
	check(scene.menu.modulate.a == 1 and not scene.joystick.enabled, "Menu fade completes while gameplay input stays blocked")
	scene.queue_free()
	await process_frame
	await process_frame
	print("POLISH RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
