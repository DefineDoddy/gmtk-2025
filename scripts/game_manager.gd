extends Node

const TimerLabel = preload("res://scripts/ui/timer_label.gd")

var vignette_material: ShaderMaterial
var timer_label: TimerLabel
var vignette_tween: Tween
var deaths := 0

func _ready():
	vignette_material = get_node("../Main/GameUI/DeathVignette").material as ShaderMaterial
	timer_label = get_node("../Main/GameUI/TimerLabel") as TimerLabel
	timer_label.hide()

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

func trigger_death():
	fade_in_vignette()
	vignette_tween.finished.connect(func():
		deaths += 1
		get_tree().create_timer(1).timeout.connect(func():
			reset_vignette(true)
			vignette_tween.finished.connect(func():
				start_countdown_dialogue()
				if deaths >= 3: start_timer()
			)
		)
	)

func show_timer():
	timer_label.show()

func start_timer():
	timer_label.start()

func pulse_vignette(duration := 2, max_alpha := 1.0, end_alpha := 0.5):
	vignette_tween = create_tween().set_trans(Tween.TRANS_SINE)
	vignette_tween.tween_method(
		func(val): vignette_material.set_shader_parameter("alpha", val),
		vignette_material.get_shader_parameter("alpha"), max_alpha, duration * 0.5
	)
	vignette_tween.tween_method(
		func(val): vignette_material.set_shader_parameter("alpha", val),
		max_alpha, end_alpha, duration * 0.5
	)

func reset_vignette(tween := false):
	if tween:
		vignette_tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
		vignette_tween.tween_method(
			func(val): vignette_material.set_shader_parameter("alpha", val),
			vignette_material.get_shader_parameter("alpha"), 0.0, 1.0
		)
		vignette_tween.tween_method(
			func(val): vignette_material.set_shader_parameter("inner_radius", val),
			vignette_material.get_shader_parameter("inner_radius"), 0.55, 1.0
		)
		vignette_tween.tween_method(
			func(val): vignette_material.set_shader_parameter("outer_radius", val),
			vignette_material.get_shader_parameter("outer_radius"), 1.235, 1.0
		)
		vignette_tween.tween_method(
			func(val): vignette_material.set_shader_parameter("color", val),
			vignette_material.get_shader_parameter("color"), Color(72, 0, 0), 1.0
		)
	else:
		vignette_material.set_shader_parameter("alpha", 0.0)
		vignette_material.set_shader_parameter("inner_radius", 0.55)
		vignette_material.set_shader_parameter("outer_radius", 1.235)
		vignette_material.set_shader_parameter("color", Color(72, 0, 0))

func fade_in_vignette(target_alpha := 1, duration := 3, target_inner_radius := 0, target_outer_radius := 0, target_color := Color(0, 0, 0), color_delay := 2.5):
	vignette_tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	vignette_tween.tween_method(
		func(val): vignette_material.set_shader_parameter("alpha", val),
		vignette_material.get_shader_parameter("alpha"), target_alpha, duration
	)
	vignette_tween.tween_method(
		func(val): vignette_material.set_shader_parameter("inner_radius", val),
		vignette_material.get_shader_parameter("inner_radius"), target_inner_radius, duration
	)
	vignette_tween.tween_method(
		func(val): vignette_material.set_shader_parameter("outer_radius", val),
		vignette_material.get_shader_parameter("outer_radius"), target_outer_radius, duration * 2
	)
	vignette_tween.tween_method(
		func(val): vignette_material.set_shader_parameter("color", val),
		vignette_material.get_shader_parameter("color"), target_color, duration
	).set_delay(color_delay)
