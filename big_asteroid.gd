extends KinematicBody2D

signal spawn_replacement(new_position, rotation_speed, velocity, movement_dir,isResource)

# Constants for how the asteroid behaves.
const MAX_ROTATION_VEL = 5
const MAX_VELOCITY = 3
const MIN_VELOCITY = 1

# Constants for the known playfield.  These are raw values - the boundaries of our playfield
# without taking into account any screen dimensions.
const PLAYFIELD_MAX_X = 9600
const PLAYFIELD_MIN_X = 800
const PLAYFIELD_MAX_Y = 7200
const PLAYFIELD_MIN_Y = 600



# Gameplay vars
var hit_points
var is_resource = false

# Asteroid vars managing placement and movement.
var rotation_vel
var movement_speed
var movement_dir
var velocity = Vector2()

# "system" vars to govern the way the asteroid interacts with the outside world
var should_shutdown = false
var shutting_down = false
var has_been_visible = false
var half_screen_size = Vector2()



# Called when the node enters the scene tree for the first time.
func _ready():
	$lifetime_timer.start()
	
func setup_random():
	rotation_vel = rand_range(-MAX_ROTATION_VEL, MAX_ROTATION_VEL)
	if randi() % 4 == 0:
		$asteroid_sprite.animation = "resource"
		is_resource = true
	else:
		$asteroid_sprite.animation = "empty"
		is_resource = false
	
	movement_dir = rand_range(0,2 * PI)
	movement_speed = rand_range(MIN_VELOCITY, MAX_VELOCITY)
	
func setup_params(inPosition, inRotationVel, inMovementSpeed, inMovementDir, inIsResource):
	position = inPosition
	rotation_vel = inRotationVel
	movement_speed = inMovementSpeed
	movement_dir = inMovementDir
	is_resource = inIsResource
	if (is_resource):
		$asteroid_sprite.animation = "resource"
	else:
		$asteroid_sprite.animation = "empty"

func set_screen_params(size):
	half_screen_size = size / 2
	print ("Asteroid screen size changed half=(" + str(half_screen_size) + ") all = (" + str(size) + ")")

func check_my_location():
	if position.x < (PLAYFIELD_MIN_X + half_screen_size.x):
		should_shutdown = true
	elif position.x > (PLAYFIELD_MAX_X - half_screen_size.x):
		should_shutdown = true
	
	if position.y < (PLAYFIELD_MIN_Y + half_screen_size.y):
		should_shutdown = true
	elif position.y > (PLAYFIELD_MAX_Y - half_screen_size.y):
		should_shutdown = true
	print("loc = " + should_shutdown)
		

func check_my_visibility():
	var xvis = false
	var yvis = false
	
	if position.x > PLAYFIELD_MIN_X and position.x < PLAYFIELD_MAX_X:
		xvis = true
	if position.y > PLAYFIELD_MIN_Y and position.y < PLAYFIELD_MAX_Y:
		yvis = true
	has_been_visible = xvis and yvis
	
	print("vis = " + has_been_visible)

func _physics_process(delta):
	rotation += rotation_vel * delta
	velocity = Vector2(movement_speed,0).rotated(movement_dir)
	velocity = move_and_collide(velocity)
	
	# what has to happen is this:
	# Emit a signal that we're going off the playfield
	# This tells main game to spawn a new asteroid at the location, 
	# direction and rotation that this instance has.  NOT wrap.  
	# then set a timer for like 10 seconds after which this instance
	# dies.
	
	# @note - have to spawn earlier.  Because if the player gets to the new spot before the asteroid does, it can just pop into existance.  Also...
	# should spawn it off in the distance so it doesn't seem to just blink into existance at the screen's edge.
	
	if has_been_visible:
		check_my_location()
	else:
		check_my_visibility()
		
	if should_shutdown and !shutting_down:
		shutting_down = true
		$killme_timer.start()
		emit_signal("spawn_replacement",position, rotation_vel, movement_speed, movement_dir, is_resource)
	

func _on_lifetime_timer_timeout():
	# when this happens, we should just blink
	# the asteroid out of existence.
	# there should be something more sexy than just
	# freeing it.
	# theoretically speaking, this would mean separating the connection from the 
	# killme timer into a different function without sexy effects.
	print("Killing asteroid.")
	queue_free()


func _on_big_asteroid_body_entered(_body):
	rotation_vel = rand_range(-MAX_ROTATION_VEL, MAX_ROTATION_VEL)
