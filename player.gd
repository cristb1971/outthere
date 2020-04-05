extends KinematicBody2D

signal player_pos_update(position, rotation)

const VELOCITY_DECAY = 4
const ROTATION_DECAY = .5

export var rotation_speed = 1.5
var screen_size 
var velocity = Vector2()
var decimal_location = Vector2()
var movement_rotation = 0
var movement_velocity = 0
var thrust_rotation = 0
const max_rotation = 12
const maxSpeed = 1200
const speed_increment = 20

var bullet = preload("res://bullet.tscn")


func _ready():
	screen_size = get_viewport_rect().size
	hide()
	$CollisionShape2D.disabled = true
	set_process_input(true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
func _input(event):
	if event.is_action_pressed("ui_fire"):
		# fire a bullet
		var projectile = bullet.instance()
		projectile.position = position
		projectile.rotation = rotation
		var universe = get_parent()
		universe.add_child(projectile)
		
	
func get_input():
	var thruster_on = false
	var rotation_on = false
	if Input.is_action_pressed("ui_right") && movement_rotation < max_rotation:
		movement_rotation += 1
		rotation_on = true
	if Input.is_action_pressed("ui_left") && movement_rotation > -max_rotation:
		movement_rotation -= 1
		rotation_on = true
	if Input.is_action_pressed("ui_up"):
		movement_velocity += speed_increment
		thrust_rotation = rotation
		thruster_on = true
	if Input.is_action_pressed("ui_down"):
		movement_velocity -= speed_increment
		thrust_rotation = rotation
		thruster_on = true
		
	if (movement_velocity > maxSpeed):
		movement_velocity = maxSpeed

	if (thruster_on == false):
		if (movement_velocity > 5):
			movement_velocity -= VELOCITY_DECAY
		elif (movement_velocity < -5):
			movement_velocity += VELOCITY_DECAY
		else:
			movement_velocity = 0
			
	if (rotation_on == false):
		if (movement_rotation > 1):
			movement_rotation -= ROTATION_DECAY
		elif (movement_rotation < -1):
			movement_rotation += ROTATION_DECAY
		else:
			movement_rotation = 0
	
	velocity = Vector2(movement_velocity,0).rotated(thrust_rotation)

func _physics_process(delta):
	get_input()
	rotation += movement_rotation * rotation_speed * delta
	#velocity = move_and_slide(velocity)
	var move_results = move_and_collide(velocity * delta)  # move_and_collide provides a KinematicCollision2D result
		
	position.x = wrapf(position.x, 800, 9600)
	position.y = wrapf(position.y, 600, 7200)
	
	var check_location = Vector2()
	check_location.x = int(position.x)
	check_location.y = int(position.y)
	if (check_location != decimal_location):
		decimal_location = check_location
		emit_signal("player_pos_update", check_location, rotation)
		
func asteroid_hit(asteroid_dir):
	movement_rotation = max_rotation * 3
	if movement_velocity > 0:
		movement_velocity = -2 * movement_velocity
	else:
		movement_velocity = 800
		thrust_rotation = asteroid_dir
#	movement_velocity = 15
	print("Playa was hit by an asteroid")

