extends SceneTree
## Desktop rendering baseline; never substitutes for Android device measurements.
var samples: Array[float] = []
var output: Dictionary = {}
var output_path: String = "res://builds/benchmark.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output_path = argument.trim_prefix("--output=")
	Engine.max_fps = 60
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.size = Vector2i(480, 900)
	var game: Node = root.get_node("Game")
	var folder: String = "user://benchmark-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(folder)
	game.storage = LocalSave.new(folder)
	game.economy = ShopEconomy.new()
	game.economy.coins = 5000
	game.economy.purchase_operation("stocker")
	game.economy.purchase_expansion("fries")
	game.economy.purchase_expansion("furniture")
	game.economy.production.stock = 10
	game.economy.handling.counter = 8
	game.economy.expansion.production.stock = 8
	game.economy.expansion.handling.counter = 4
	var scene: Node = load("res://scenes/playable_shop.tscn").instantiate()
	root.add_child(scene)
	for index: int in 4:
		scene.customer_controller.spawn_customer()
	output = {"platform": OS.get_name(), "renderer": RenderingServer.get_video_adapter_name(),
		"viewport": "480x900", "frame_cap": 60, "warmup_frames": 60, "sample_frames": 180,
		"engine": Engine.get_version_info().string, "android_measurement": false, "scenarios": {}}
	for scenario: String in ["busy", "menu", "idle"]:
		if scenario == "menu":
			scene.open_menu()
		elif scenario == "idle":
			scene.close_menu()
			scene.production_controller.set_paused(true)
			scene.fries_controller.set_paused(true)
			scene.customer_controller.set_paused(true)
			scene.stocker_controller.set_paused(true)
			scene.world.set_presentation_paused(true)
		for index: int in 60:
			await process_frame
		samples.clear()
		var process_samples: Array[float] = []
		var peak_memory: float = 0
		var peak_draws: int = 0
		var peak_nodes: int = 0
		var previous: int = Time.get_ticks_usec()
		for index: int in 180:
			await process_frame
			var now: int = Time.get_ticks_usec()
			samples.append(float(now - previous) / 1000)
			previous = now
			process_samples.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000)
			peak_memory = maxf(peak_memory, Performance.get_monitor(Performance.MEMORY_STATIC))
			peak_draws = maxi(peak_draws, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
			peak_nodes = maxi(peak_nodes, get_node_count())
		samples.sort()
		process_samples.sort()
		output.scenarios[scenario] = {"frame_median_ms": samples[90], "frame_p95_ms": samples[171],
			"process_p95_ms": process_samples[171], "peak_static_memory_bytes": peak_memory,
			"peak_draw_calls": peak_draws, "peak_nodes": peak_nodes}
	var file: FileAccess = FileAccess.open(output_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(output, "\t"))
	file.close()
	scene.queue_free()
	await process_frame
	await process_frame
	print("BENCHMARK: ", JSON.stringify(output))
	quit()
