extends Node

const DeathVignette = preload("res://scripts/ui/death_vignette.gd")
const TimerLabel = preload("res://scripts/ui/timer_label.gd")
const UnlockedLabel = preload("res://scripts/ui/unlocked_label.gd")

var death_vignette: DeathVignette
var timer_label: TimerLabel
var unlocked_label: UnlockedLabel
var dialog_audio_player: AudioStreamPlayer
var death_audio_player: AudioStreamPlayer

var deaths: int = 5

func _ready():
	death_vignette = get_node("../Main/GameUI/DeathVignette") as DeathVignette
	timer_label = get_node("../Main/GameUI/TimerLabel") as TimerLabel
	unlocked_label = get_node("../Main/GameUI/UnlockedLabel") as UnlockedLabel

	Dialogic.VAR.variable_was_set.connect(func(info: Dictionary):
		print("Set variable: %s to %s" % [info["variable"], info["new_value"]])

		if info["variable"] == "wine_suspicion":
			if info["new_value"] >= 3:
				Dialogic.VAR.set("unlock_no_wine", true)
				print("Set variable: unlock_no_wine to true")

		if info["variable"].begins_with("unlock_pressure_"):
			var text = info["variable"].replace("unlock_pressure_", "Pressure ").capitalize()
			unlocked_label.show_unlock(text)
	)
	
	dialog_audio_player = AudioStreamPlayer.new()
	dialog_audio_player.stream = load("res://audio/sfx/choice_selected.wav")
	Dialogic.Choices.choice_selected.connect(func(_c): dialog_audio_player.play())
	add_child(dialog_audio_player)

	death_audio_player = AudioStreamPlayer.new()
	add_child(death_audio_player)

	death_vignette.set_death_completed_callback(func(): timer_label.reset())
	death_vignette.set_revive_started_callback(_play_revive_sound)
	death_vignette.set_revive_completed_callback(_reset_loop)

	if deaths >= 3: timer_label.start()
	else: timer_label.hide()
	start_countdown_dialogue()


func start_countdown_dialogue():
	Dialogic.VAR.set("lucas_mood", 0)
	Dialogic.VAR.set("observe_sophie_evelyn", false)
	Dialogic.VAR.set("asked_about_vineyard", false)
	Dialogic.VAR.set("asked_lucas_usual_drink", false)
	Dialogic.VAR.set("asked_thomas_cellar", false)
	Dialogic.VAR.set("no_wine", false)

	var layout = Dialogic.start("countdown")
	layout.register_character(load("res://dialogue/characters/You.dch"), get_node("../Main/Characters/You"))
	layout.register_character(load("res://dialogue/characters/Thought.dch"), get_node("../Main/Characters/You"))
	layout.register_character(load("res://dialogue/characters/Action.dch"), get_node("../Main/Characters/You"))
	layout.register_character(load("res://dialogue/characters/Evelyn.dch"), get_node("../Main/Characters/Evelyn"))
	layout.register_character(load("res://dialogue/characters/Jasper.dch"), get_node("../Main/Characters/Jasper"))
	layout.register_character(load("res://dialogue/characters/Lucas.dch"), get_node("../Main/Characters/Lucas"))
	layout.register_character(load("res://dialogue/characters/Sophie.dch"), get_node("../Main/Characters/Sophie"))
	layout.register_character(load("res://dialogue/characters/Thomas.dch"), get_node("../Main/Characters/Thomas"))

func pulse_vignette():
	death_vignette.play_pulse_animation()
	_play_damage_sound()

func trigger_death():
	deaths += 1

	if Dialogic.VAR.get("no_wine"):
		Dialogic.VAR.set("know_not_wine", true)
		print("Set variable: know_not_wine to true")

	timer_label.stop()
	timer_label.set_time(0.0)
	death_vignette.play_death_animation()
	_play_death_sound()

func _reset_loop():
	start_countdown_dialogue()
	if deaths >= 3: start_timer()

func show_timer():
	timer_label.show()

func start_timer():
	timer_label.start()

func _play_damage_sound():
	death_audio_player.stream = load("res://audio/sfx/damage_pulse.wav")
	death_audio_player.play()

func _play_death_sound():
	death_audio_player.stream = load("res://audio/sfx/death.wav")
	death_audio_player.play()

func _play_revive_sound():
	death_audio_player.stream = load("res://audio/sfx/revive.wav")
	death_audio_player.play()
