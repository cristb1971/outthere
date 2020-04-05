extends TextureRect

const MINIMAP_SCALE = 20

var player = preload("res://minimap_player.tscn")
var player_icon

# Called when the node enters the scene tree for the first time.
func _ready():
	player_icon = player.instance()
	add_child(player_icon)


func update_player_position(in_pos, in_rot):
	in_pos -= Vector2(800,600)
	
	player_icon.position = in_pos / MINIMAP_SCALE
	player_icon.rotation = in_rot
