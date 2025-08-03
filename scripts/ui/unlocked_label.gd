extends RichTextLabel

func _ready():
    self.hide()

func show_unlock(unlock_text: String):
    self.text = "[wave amp=15.0 freq=6 connected=1][color=gold]Unlocked:[/color] [b]%s[/b][/wave]" % unlock_text
    self.show()
    get_tree().create_timer(10.0).timeout.connect(func(): self.hide())
