extends CanvasLayer

signal start_game

func _ready():
	$minimap.hide()
	$minimap.rect_position



func _on_Button_pressed():
	$startButton.hide()
	$minimap.show()
	emit_signal("start_game")

func set_top_text(text):
	$pos_label.text = text
