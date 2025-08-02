extends ColorRect

enum DeathState {NONE, FADING_IN, WAITING, FADING_OUT, RESTARTING}
var death_state = DeathState.NONE
var tween: Tween
var on_death_completed: Callable
var on_revive_started: Callable
var on_revive_completed: Callable

func play_death_animation():
	if death_state != DeathState.NONE: return
	death_state = DeathState.FADING_IN
	fade_in_vignette()

	if tween.finished.is_connected(_on_fade_in_finished):
		tween.finished.disconnect(_on_fade_in_finished)

	tween.finished.connect(_on_fade_in_finished, CONNECT_ONE_SHOT)

func _on_fade_in_finished():
	death_state = DeathState.WAITING
	if on_death_completed: on_death_completed.call()
	get_tree().create_timer(1.0).timeout.connect(_on_death_wait_timeout, CONNECT_ONE_SHOT)
	
func _on_death_wait_timeout():
	death_state = DeathState.FADING_OUT
	if on_revive_started: on_revive_started.call()
	fade_out_vignette()
	
	if tween.finished.is_connected(_on_fade_out_finished):
		tween.finished.disconnect(_on_fade_out_finished)

	get_tree().create_timer(3.0).timeout.connect(_on_fade_out_finished, CONNECT_ONE_SHOT)
	
func _on_fade_out_finished():
	death_state = DeathState.RESTARTING
	if on_revive_completed: on_revive_completed.call()
	death_state = DeathState.NONE

func set_death_completed_callback(callback: Callable):
	on_death_completed = callback

func set_revive_started_callback(callback: Callable):
	on_revive_started = callback

func set_revive_completed_callback(callback: Callable):
	on_revive_completed = callback

func play_pulse_animation(duration := 2.0):
	if death_state != DeathState.NONE: return
		
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)

	tween.tween_method(
		func(val): material.set_shader_parameter("alpha", val),
		material.get_shader_parameter("alpha"), 1.0, duration * 0.5
	)
	tween.tween_method(
		func(val): material.set_shader_parameter("alpha", val),
		1.0, 0.5, duration * 0.5
	)

func fade_in_vignette():
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	
	tween.tween_method(
		func(val): material.set_shader_parameter("alpha", val),
		material.get_shader_parameter("alpha"), 1.0, 3.0
	)
	tween.tween_method(
		func(val): material.set_shader_parameter("inner_radius", val),
		material.get_shader_parameter("inner_radius"), 0.0, 3.0
	)
	tween.tween_method(
		func(val): material.set_shader_parameter("outer_radius", val),
		material.get_shader_parameter("outer_radius"), 0.0, 6.0
	)
	tween.tween_method(
		func(val): material.set_shader_parameter("color", val),
		material.get_shader_parameter("color"), Color(0, 0, 0), 3.0
	).set_delay(2.5)

func fade_out_vignette():
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_parallel(true)

	tween.tween_method(
		func(val): material.set_shader_parameter("alpha", val),
		material.get_shader_parameter("alpha"), 0.0, 5.0
	)
	tween.tween_method(
		func(val): material.set_shader_parameter("inner_radius", val),
		material.get_shader_parameter("inner_radius"), 0.55, 5.0
	)
	tween.tween_method(
		func(val): material.set_shader_parameter("outer_radius", val),
		material.get_shader_parameter("outer_radius"), 1.235, 4.0
	)
	tween.tween_method(
		func(val): material.set_shader_parameter("color", val),
		material.get_shader_parameter("color"), Color(0.282, 0, 0), 4.0
	)