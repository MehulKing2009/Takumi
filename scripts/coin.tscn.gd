extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump with W
	if (Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_SPACE)) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := 0

	if Input.is_key_pressed(KEY_A):
		direction -= 1
		animated_sprite_2d.flip_h = true
	if Input.is_key_pressed(KEY_D):
		direction += 1
		animated_sprite_2d.flip_h = false

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	
func play_death(body: Node2D):
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	$AnimatedSprite2D.play("death")
	
	Engine.time_scale = 1
