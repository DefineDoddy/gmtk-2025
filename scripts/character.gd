extends Node2D

@onready var sprite = $Sprite2D
@onready var tween := get_tree().create_tween()

var normal_scale := Vector2(10, 10)
var hover_scale := Vector2(12, 12)

func _ready() -> void:
	Dialogic.Text.speaker_updated.connect(_on_speaker_updated)

func highlight():
	if tween.is_running(): tween.kill()
	tween = get_tree().create_tween().set_parallel(true)

	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", hover_scale, 0.5)

	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(val): sprite.material.set_shader_parameter("width", val),
		sprite.material.get_shader_parameter("width"), 0.5, 0.2
	)

func unhighlight():
	if tween.is_running(): tween.kill()
	tween = get_tree().create_tween().set_parallel(true)

	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", normal_scale, 0.5)

	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(val): sprite.material.set_shader_parameter("width", val),
		sprite.material.get_shader_parameter("width"), 0, 0.2
  	)

func _on_speaker_updated(speaker: DialogicCharacter) -> void:
	if speaker and speaker.display_name == name: highlight()
	else: unhighlight()
