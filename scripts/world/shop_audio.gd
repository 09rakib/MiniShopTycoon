class_name ShopAudio
extends Node
const CLIPS: Dictionary = {
	"pickup": preload("res://assets/audio/pickup.wav"),
	"serve": preload("res://assets/audio/serve.wav"),
	"sale": preload("res://assets/audio/sale.wav"),
	"cash": preload("res://assets/audio/cash.wav"),
	"upgrade": preload("res://assets/audio/upgrade.wav"),
	"unlock": preload("res://assets/audio/unlock.wav"),
	"hire": preload("res://assets/audio/hire.wav"),
	"menu": preload("res://assets/audio/menu.wav")}
var settings: ShopSettings
var voices: Array[AudioStreamPlayer] = []
var cursor: int = 0
var last_play: Dictionary = {}
var suspended: bool = false
var play_count: int = 0
# Headless simulations validate cue routing without starting a hardware mixer.
# Desktop previews and Android use real playback through the same voice pool.
var playback_enabled: bool = DisplayServer.get_name() != "headless"

func _ready() -> void:
	if settings == null:
		settings = ShopSettings.new(Game.storage.directory)
	settings.load_settings()
	for index: int in 4:
		var voice: AudioStreamPlayer = AudioStreamPlayer.new()
		voice.volume_db = -19
		add_child(voice)
		voices.append(voice)
	Game.presentation.connect(_on_cue)

func _on_cue(kind: String, _point: Vector2, _amount: int) -> void:
	play(kind)

func play(kind: String) -> bool:
	var staff: bool = kind.begins_with("staff_")
	var sound: String = kind.trim_prefix("staff_") if staff else kind
	if not settings.enabled or suspended or get_tree().paused or not CLIPS.has(sound):
		return false
	var now: int = Time.get_ticks_msec()
	if now - int(last_play.get(sound, -1000)) < 80:
		return false
	last_play[sound] = now
	var voice: AudioStreamPlayer = voices[cursor]
	cursor = (cursor + 1) % voices.size()
	voice.stop()
	voice.stream = CLIPS[sound]
	voice.volume_db = -24 if staff else -24 if sound == "menu" else -17 if sound == "cash" else -19
	if playback_enabled:
		voice.play()
	play_count += 1
	return true

func set_sound_enabled(value: bool) -> bool:
	if not settings.save_enabled(value):
		return false
	if not value:
		stop_all()
	return true

func stop_all() -> void:
	for voice: AudioStreamPlayer in voices:
		voice.stop()
		voice.stream = null

func _exit_tree() -> void:
	stop_all()

func set_suspended(value: bool) -> void:
	suspended = value
	if value:
		stop_all()
