extends CharacterBody2D

const SPEED = 25.0
const DETECTION_RANGE = 200.0
const BITE_RANGE = 18.0
const SWING_RANGE = 26.0
const SEARCH_DELAY = 0.5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D = null
var can_attack := true
var search_timer := 0.0


func _ready():
	player = null


func _physics_process(delta: float) -> void:
	# Search for player occasionally
	search_timer -= delta
	if search_timer <= 0:
		search_timer = SEARCH_DELAY

		if player == null or not is_instance_valid(player):
			player = get_tree().get_root().find_child("adam", true, false)

	# No player → idle
	if player == null:
		if anim.animation != "idle":
			anim.play("idle")
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()

	# Rotate (sprite faces down)
	anim.rotation = direction.angle() + deg_to_rad(270)

	# OUT OF RANGE
	if distance > DETECTION_RANGE:
		if anim.animation != "idle":
			anim.play("idle")
		velocity = Vector2.ZERO

	else:
		# BITE
		if distance <= BITE_RANGE and can_attack:
			velocity = Vector2.ZERO
			if anim.animation != "bite_attack":
				anim.play("bite_attack")

		# SWING
		elif distance <= SWING_RANGE and can_attack:
			velocity = Vector2.ZERO
			if anim.animation != "swing_attack":
				anim.play("swing_attack")

		# WALK
		else:
			if anim.animation != "walking":
				anim.play("walking")
			velocity = direction * SPEED

	move_and_slide()


func _on_AnimatedSprite2D_frame_changed():
	print("FRAME:", anim.frame)

	if player == null or not can_attack:
		return

	# Damage frame (frame index starts at 0)
	if anim.frame == 1:
		print("ATTACK FRAME")

		var distance = global_position.distance_to(player.global_position)

		if distance <= BITE_RANGE:
			can_attack = false
			print("BITE DAMAGE")
			player.player_got_damage(randi_range(1, 20))

		elif distance <= SWING_RANGE:
			can_attack = false
			print("SWING DAMAGE")
			player.player_got_damage(randi_range(10, 30))


func _on_AnimatedSprite2D_animation_finished():
	if anim.animation in ["bite_attack", "swing_attack"]:
		can_attack = true
