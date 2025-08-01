extends Node

const DeathVignette = preload("res://scripts/ui/death_vignette.gd")
const TimerLabel = preload("res://scripts/ui/timer_label.gd")

var death_vignette: DeathVignette
var timer_label: TimerLabel
var deaths: int = 1

func _ready():
	death_vignette = get_node("../Main/GameUI/DeathVignette") as DeathVignette
	timer_label = get_node("../Main/GameUI/TimerLabel") as TimerLabel

	timer_label.hide()
	death_vignette.set_death_completed_callback(_reset_loop)
	start_countdown_dialogue()

func start_countdown_dialogue():
	var layout = Dialogic.start("countdown")
	layout.register_character(load("res://dialogue/characters/You.dch"), get_node("../Main/Characters/You"))
	layout.register_character(load("res://dialogue/characters/Action.dch"), get_node("../Main/Characters/You"))
	layout.register_character(load("res://dialogue/characters/Evelyn.dch"), get_node("../Main/Characters/Evelyn"))
	layout.register_character(load("res://dialogue/characters/Jasper.dch"), get_node("../Main/Characters/Jasper"))
	layout.register_character(load("res://dialogue/characters/Lucas.dch"), get_node("../Main/Characters/Lucas"))
	layout.register_character(load("res://dialogue/characters/Sophie.dch"), get_node("../Main/Characters/Sophie"))
	layout.register_character(load("res://dialogue/characters/Thomas.dch"), get_node("../Main/Characters/Thomas"))

func pulse_vignette():
	death_vignette.play_pulse_animation()

func trigger_death():
	deaths += 1
	death_vignette.play_death_animation()

func _reset_loop():
	start_countdown_dialogue()
	if deaths >= 3: start_timer()

func show_timer():
	timer_label.show()

func start_timer():
	timer_label.start()
