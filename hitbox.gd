extends CharacterBody2D

const SPEED = 200.0

@onready var hand = $Hand

var sword_scene = preload("res://lightsaber.tscn")
var attacking := false

func _physics_process(delta):
	if attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()

func _input(event):
	if event.is_action_pressed("attack") and not attacking:
		attack()

func attack():
	attacking = true

	var sword = sword_scene.instantiate()
	hand.add_child(sword)
	sword.position = Vector2.ZERO

	# pass reference so you don’t hit yourself
	sword.owner_ref = self

	# start animation
	sword.start()

	# when sword disappears → allow movement again
	sword.connect("tree_exited", Callable(self, "_on_attack_done"))

func _on_attack_done():
	attacking = false
