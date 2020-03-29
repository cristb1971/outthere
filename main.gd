extends Node

var playerLoc



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func new_game():
	$player.start($startPos.position)

func player_pos_updated(location):
	$HUD.set_top_text("Position: (" + str(location.x) + ", " + str(location.y) + ")")
