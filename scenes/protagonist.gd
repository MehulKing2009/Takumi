extends CharacterBody2D

const SPEED = 100.0

@onready var anim = $AnimatedSprite2D
@onready var hand = $Hand

var last_dir := "s"

# ----- ATTACK -----
var sword_scene = preload("res://lightsaber.tscn")
var attacking := false


func _physics_process(delta: float) -> void:

	# LOCK movement during attack
	if attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := Vector2.ZERO

	# Proper input system (SET THESE IN INPUT MAP)
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	direction = direction.normalized()
	velocity = direction * SPEED
	move_and_slide()

	# ----- ANIMATION -----
	if direction != Vector2.ZERO:

		# Determine facing direction
		if abs(direction.y) > abs(direction.x):
			if direction.y < 0:
				last_dir = "w"
			else:
				last_dir = "s"
		else:
			if direction.x < 0:
				last_dir = "a"
			else:
				last_dir = "d"

		var new_anim = "anim_" + last_dir
		if anim.animation != new_anim:
			anim.play(new_anim)

	else:
		# Immediate idle
		if anim.animation != "idle":
			anim.play("idle")


func _input(event):
	if event.is_action_pressed("attack") and not attacking:
		attack()


func attack():
	attacking = true

	var sword = sword_scene.instantiate()
	hand.add_child(sword)
	sword.position = Vector2.ZERO
	sword.owner_ref = self

	# ROTATE BASED ON LAST DIRECTION
	if last_dir == "w":
		sword.rotation = -PI/2
	elif last_dir == "s":
		sword.rotation = PI/2
	elif last_dir == "a":
		sword.rotation = PI
	elif last_dir == "d":
		sword.rotation = 0

	sword.start()

	sword.connect("tree_exited", Callable(self, "_on_attack_done"))


func _on_attack_done():
	attacking = false


func play_death(body: Node2D):
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	Engine.time_scale = 10
