extends Area2D

const MOVEMENT_VELOCITY = 2100
var projVelocity = Vector2()


func _ready():
	pass


func _physics_process(delta):
	projVelocity = Vector2(MOVEMENT_VELOCITY,0).rotated(rotation)
	position += projVelocity * delta
	position.x = wrapf(position.x, 800, 9600)
	position.y = wrapf(position.y, 600, 7200)

	


func _on_bullet_area_entered(area):
	# Can check here to see if our layer has been hit.
	queue_free()



func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
