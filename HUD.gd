extends CanvasLayer

signal start_game

func _ready():
	pass # Replace with function body.



func _on_Button_pressed():
	$startButton.hide()
	emit_signal("start_game")

func set_top_text(text):
	$pos_label.text = text
