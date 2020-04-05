extends Node

signal screen_resized(size)
signal player_moved(location, rotation)

# Constants for the known playfield.  These are raw values - the boundaries of our playfield
# without taking into account any screen dimensions.
const PLAYFIELD_MAX_X = 9600
const PLAYFIELD_MIN_X = 800
const PLAYFIELD_MAX_Y = 7200
const PLAYFIELD_MIN_Y = 600



export (PackedScene) var BigAsteroid
# little asteroid
# enemy basics
# enemy fighter
var playerLoc
var screenSize = Vector2()



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	get_tree().get_root().connect("size_changed", self, "screen_size_changed")

func new_game():
	screenSize = get_viewport().size
	$player.start($startPos.position)
	var newAsteroid = BigAsteroid.instance()
	add_child(newAsteroid)
	newAsteroid.setup_random()
	newAsteroid.position = $startPos.position + Vector2(100,100)
	newAsteroid.connect("spawn_replacement", self, "asteroid_out_of_bounds")
	newAsteroid.set_screen_params(screenSize)
	self.connect("screen_resized", newAsteroid, "set_screen_params")

func player_pos_updated(location, in_rotation):
	var in_pos = location - Vector2(800,600)
	in_pos = in_pos / 20
	$HUD.set_top_text("mini: (" + str(int(in_pos.x)) + ", "+ str(int(in_pos.y)) + ")" + "-- Position: (" + str(location.x) + ", " + str(location.y) + ")")
	#$HUD.set_top_text("Position: (" + str(location.x) + ", " + str(location.y) + ")")
	emit_signal("player_moved", location, in_rotation)

func asteroid_out_of_bounds(old_asteroid_dict):
	var old_position = old_asteroid_dict["position"]
	var new_position = old_position
	var half_screen_size = screenSize / 2

	if old_position.x < (PLAYFIELD_MIN_X + half_screen_size.x):
		new_position.x = PLAYFIELD_MAX_X + half_screen_size.x
	elif old_position.x > (PLAYFIELD_MAX_X - half_screen_size.x):
		new_position.x = PLAYFIELD_MIN_X - half_screen_size.x
	
	if old_position.y < (PLAYFIELD_MIN_Y + half_screen_size.y):
		new_position.y = PLAYFIELD_MAX_Y + half_screen_size.y
	elif old_position.y > (PLAYFIELD_MAX_Y - half_screen_size.y):
		new_position.y = PLAYFIELD_MIN_Y - half_screen_size.y
	
	var newAsteroid = BigAsteroid.instance()
	old_asteroid_dict["position"] = new_position
	newAsteroid.setup_params(old_asteroid_dict)
	newAsteroid.connect("spawn_replacement", self, "asteroid_out_of_bounds")
	self.connect("screen_resized", newAsteroid, "set_screen_params")
	newAsteroid.set_screen_params(screenSize)
	add_child(newAsteroid)
	print("Spawning at: " + str(new_position))
	
func screen_size_changed():
	screenSize = get_viewport().size
	emit_signal("screen_resized", screenSize)
