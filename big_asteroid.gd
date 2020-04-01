extends Area2D

# the signal that's emitted when a new copy of this asteroid should be created
# on the other side of the playfield.
signal spawn_replacement(asteroid_dict)

# Constants for how the asteroid behaves.
const MAX_ROTATION_VEL = 5
const MAX_VELOCITY = 150
const MIN_VELOCITY = 1

# Constants for the known playfield.  These are raw values - the boundaries of our playfield
# without taking into account any screen dimensions.
const PLAYFIELD_MAX_X = 9600
const PLAYFIELD_MIN_X = 800
const PLAYFIELD_MAX_Y = 7200
const PLAYFIELD_MIN_Y = 600

var asteroid_val = {
#   Physiological vars
	"hit_points": 0,
	"recent_damage" : 0,
	"shake_level" : 0,
	"resource" : "empty",
#   Representation vars
	"rotation_vel" : 0,
	"movement_speed" : 0,
	"movement_dir" : 0,
	"velocity" : Vector2(),
# Two special case vars.  These are our asteroid location
# and will be used to transfer data from old-asteroid to 
# new-asteroid when the new one is spawned!
# Rotation is the Area2Ds rotation, and location
# is the Area2Ds position.
	"rotation" : 0,
	"position" : Vector2()
}
# "system" vars to govern the way the asteroid interacts with the outside world
var should_shutdown = false
var shutting_down = false
var has_been_visible = false
var half_screen_size = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	$lifetime_timer.start()
	$message_timer.start()  #Uncomment this line if you want to print debug info
	
func setup_random():
	asteroid_val["rotation_vel"] = rand_range(-MAX_ROTATION_VEL, MAX_ROTATION_VEL)
	if randi() % 4 == 0:
		asteroid_val["resource"] = "resource"
	else:
		asteroid_val["resource"] = "empty"
	
	$asteroid_sprite.animation = asteroid_val["resource"]
	asteroid_val["movement_dir"] = rand_range(0,2 * PI)
	asteroid_val["movement_speed"] = rand_range(MIN_VELOCITY, MAX_VELOCITY)
	asteroid_val["hit_points"] = 300
	
func setup_params(inVals):
	if (typeof(inVals) != TYPE_DICTIONARY):
		return
	asteroid_val = inVals
	rotation = asteroid_val["rotation"]
	position = asteroid_val["position"]
	$asteroid_sprite.animation = asteroid_val["resource"]

func set_screen_params(size):
	half_screen_size = size / 2
	print (self.name + ": Asteroid screen size set half=(" + str(half_screen_size) + ") all = (" + str(size) + ")")

##########################################
##  This determines whether the asteroid has drifted way out of the visible
##  space on either side of the playfield.  If it has, then it should be 
##  deleted.
func check_shutdown_border():
	var width = Vector2(PLAYFIELD_MAX_X + half_screen_size.x * 2, PLAYFIELD_MAX_Y + half_screen_size.y * 2)
	var shut_border = Rect2(Vector2(0,0), width)
	if !shut_border.has_point(position):
		print(self.name + ": Killing asteroid due to leaving space.")
		queue_free()


##########################################
##  Checks to see if the asteroid is visible (within a subset of the 
##  usable playfield - defined by the dimensions of the screen).
##  If it is, then a visible flag has been set.  If it -was- visible
##  and no longer is, then a "should shut down" flag is set.
func check_my_visibility():
	var origin = Vector2(PLAYFIELD_MIN_X, PLAYFIELD_MIN_Y)
	var size = Vector2(PLAYFIELD_MAX_X - PLAYFIELD_MIN_X, PLAYFIELD_MAX_Y - PLAYFIELD_MIN_Y)
	origin += half_screen_size
	size -= 2 * half_screen_size
	var visible_border = Rect2(origin, size)
	if visible_border.has_point(position):
		has_been_visible = true
	elif has_been_visible == true:
		should_shutdown = true

func print_status():
	print("I am " + self.name + " at position: " + str(position))
	print("has been visible = " + str(has_been_visible) + " - should shutdown = " + str(should_shutdown))
	print("My HP: " + str(asteroid_val["hit_points"]) + " - recent damage: " + str(asteroid_val["recent_damage"]) + " - Shake Level: " + str(asteroid_val["shake_level"])) 
	print("===================================")
	if (asteroid_val["recent_damage"] > 10):
		asteroid_val["shake_level"] +=1
	elif asteroid_val["shake_level"] > 1 :
		asteroid_val["shake_level"] -= 1
	asteroid_val["recent_damage"] = 0;
		
	
func _physics_process(delta):
	rotation += asteroid_val["rotation_vel"] * delta
	asteroid_val["velocity"] = Vector2(asteroid_val["movement_speed"],0).rotated(asteroid_val["movement_dir"])
	position += asteroid_val["velocity"] * delta
	
	if asteroid_val["shake_level"] > 0:
#		var side = 1 if (randi() % 2 == 0) else -1
#		var rot = rand_range(0, PI / 4)
		var rot = rand_range(0,PI * 2) + asteroid_val["movement_dir"] + (PI / 4)
		var new_spot = Vector2(asteroid_val["shake_level"] * 30,0).rotated(rot)
		position += new_spot * delta
	
	check_my_visibility()
	if shutting_down:
		check_shutdown_border()

##  if the should shut down flag is tripped, the asteroid informs
##  the main game to spawn a new asteroid at its location, except
##  on the other side of the playfield.  But only once!
	if should_shutdown and !shutting_down:
		shutting_down = true
		asteroid_val["position"] = position
		asteroid_val["rotation"] = rotation
		emit_signal("spawn_replacement", asteroid_val)
	

func _on_lifetime_timer_timeout():
	print(self.name + ": Killing asteroid.")
	queue_free()

func _on_big_asteroid_body_entered(body):
	print(self.name + ": Asteroid was hit.")


func _on_big_asteroid_area_entered(area):
	# check for bullet type.  Use duck-typed checking.
	# I just need to figure out how.
	asteroid_val["hit_points"] -= 10
	asteroid_val["recent_damage"] += 10
	if asteroid_val["hit_points"] < 0:
		print("Asteroid shot to death")
		queue_free()

