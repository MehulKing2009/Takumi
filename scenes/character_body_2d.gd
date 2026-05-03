extends CharacterBody2D

const SPEED = 120.0
const DETECTION_RANGE = 200.0
const BITE_RANGE = 18.0
const SWING_RANGE = 26.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D
var can_attack := true


func _ready():
	player = get_parent().get_node("adam")


func _physics_process(delta: float) -> void:
	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()

	# Flip sprite
	if direction.x != 0:
		anim.flip_h = direction.x < 0

	# Out of range → idle
	if distance > DETECTION_RANGE:
		anim.play("idle")
		velocity = Vector2.ZERO

	else:
		# Bite (closest)
		if distance <= BITE_RANGE and can_attack:
			velocity = Vector2.ZERO
			anim.play("bite_attack")

		# Swing
		elif distance <= SWING_RANGE and can_attack:
			velocity = Vector2.ZERO
			anim.play("swing_attack")

		# Walk
		else:
			anim.play("walking")
			velocity = direction * SPEED

	move_and_slide()


func _on_AnimatedSprite2D_frame_changed():
	if not can_attack:
		return

	if anim.frame == 1:
		var distance = global_position.distance_to(player.global_position)

		if distance <= BITE_RANGE:
			can_attack = false
			player.player_got_damage(randi_range(1, 20))

		elif distance <= SWING_RANGE:
			can_attack = false
			player.player_got_damage(randi_range(10, 30))


func _on_AnimatedSprite2D_animation_finished():
	if anim.animation in ["bite_attack", "swing_attack"]:
		can_attack = true
