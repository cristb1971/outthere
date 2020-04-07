extends TextureRect

const MINIMAP_SCALE = 20

var playerFactory = preload("res://minimap//minimap_player.tscn")
var bigAsteroidFactory = preload("res://minimap//minimap_big_asteroid.tscn")
var player_icon
var big_asteroids = Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready():
	player_icon = playerFactory.instance()
	add_child(player_icon)

func add_big_asteroid(add_name, loc, type):
	var rep = bigAsteroidFactory.instance()
	loc -= Vector2(800,600)
	rep.position = loc / MINIMAP_SCALE
	if (type == "resource"):
		rep.set_frame(1)
	else:
		rep.set_frame(0)
	add_child(rep)
	big_asteroids[add_name] = rep
	_set_rep_visibility(rep)

func update_big_asteroid(move_name, loc):
	if (big_asteroids.has(move_name)):
		loc -= Vector2(800,600)
		var rep = big_asteroids[move_name]
		rep.position = loc / MINIMAP_SCALE
		_set_rep_visibility(rep)

func remove_big_asteroid(remove_name):
	var rep = big_asteroids[remove_name]
	rep.queue_free()
	big_asteroids.erase(remove_name)

func update_player_position(in_pos, in_rot):
	in_pos -= Vector2(800,600)
	player_icon.position = in_pos / MINIMAP_SCALE
	player_icon.rotation = in_rot

func _set_rep_visibility(rep):
	var screen_rect = Rect2(Vector2(0,0), Vector2(440,330))
	if (screen_rect.has_point(rep.position)):
		rep.show()
	else:
		rep.hide()
	
