extends RichTextLabel

@export var start_time: float = 300.0
var time_left: float
var running := false

func _ready():
    time_left = start_time
    update_label()

func reset():
    running = false
    time_left = start_time
    update_label()

func start():
    reset()
    running = true

func stop():
    running = false

func _process(delta):
    if running and time_left > 0.0:
        time_left -= delta
        if time_left <= 0.0:
            time_left = 0.0
            running = false
            GameManager.trigger_death()
        update_label()

func update_label():
    var minutes = int(time_left / 60)
    var seconds = int(time_left) % 60
    text = "[wave amp=15.0 freq=6 connected=1][b]%d:%02d[/b][/wave]" % [minutes, seconds]
