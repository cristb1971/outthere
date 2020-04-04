extends Area2D

const MOVEMENT_VELOCITY = 2100
var projVelocity = Vector2()
var exploding = false


func _ready():
	pass


func _physics_process(delta):
	if !exploding:
		projVelocity = Vector2(MOVEMENT_VELOCITY,0).rotated(rotation)
	else:
		projVelocity = Vector2(0,0)
	position += projVelocity * delta
	position.x = wrapf(position.x, 800, 9600)
	position.y = wrapf(position.y, 600, 7200)

	


func _on_bullet_area_entered(_area):
	$AnimatedSprite.hide()
	$explosion.show()
	$explosion.play()
	exploding = true

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_explosion_animation_finished():
	queue_free()
