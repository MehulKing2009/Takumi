extends CharacterBody2D

const SPEED = 25.0
const DETECTION_RANGE = 200.0
const BITE_RANGE = 18.0
const SWING_RANGE = 26.0
const SEARCH_DELAY = 0.5
const LOOK_DELAY = 0.3

const HIT_FRAME_BITE = 1
const HIT_FRAME_SWING = 1

const ATTACK_COOLDOWN := 0.8

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D = null
var can_attack := true
var search_timer := 0.0
var look_timer := 0.0
var attack_timer := 0.0
var last_direction := Vector2.DOWN

func _ready() -> void:
	player = null
	anim.frame_changed.connect(_on_AnimatedSprite2D_frame_changed)
	anim.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)

func _physics_process(delta: float) -> void:
	attack_timer = maxf(attack_timer - delta, 0.0)
	can_attack = attack_timer <= 0.0

	search_timer -= delta
	if search_timer <= 0.0:
		search_timer = SEARCH_DELAY
		if player == null or not is_instance_valid(player):
			player = get_tree().get_root().find_child("adam", true, false)

	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := player.global_position - global_position
	var distance := direction.length()
	if distance > 0.0:
		direction = direction.normalized()

	look_timer -= delta
	if look_timer <= 0.0:
		look_timer = LOOK_DELAY
		last_direction = direction

	if last_direction.length() > 0.0:
		anim.rotation = last_direction.angle() - deg_to_rad(90)

	if distance > DETECTION_RANGE:
		velocity = Vector2.ZERO
		if anim.animation != "idle":
			anim.play("idle")
	else:
		if distance > SWING_RANGE:
			velocity = direction * SPEED
			if anim.animation != "walking":
				anim.play("walking")
		else:
			velocity = Vector2.ZERO

			if can_attack:
				if distance <= BITE_RANGE:
					if anim.animation != "bite_attack" or not anim.is_playing():
						anim.play("bite_attack")
				elif distance <= SWING_RANGE:
					if anim.animation != "swing_attack" or not anim.is_playing():
						anim.play("swing_attack")

	move_and_slide()

func _on_AnimatedSprite2D_frame_changed() -> void:
	if player == null or not is_instance_valid(player) or not can_attack:
		return

	if anim.animation == "bite_attack" and anim.frame == HIT_FRAME_BITE:
		if global_position.distance_to(player.global_position) <= BITE_RANGE:
			can_attack = false
			attack_timer = ATTACK_COOLDOWN
			player.player_got_damage(randi_range(1, 20))
			print("Bite hit!")

	elif anim.animation == "swing_attack" and anim.frame == HIT_FRAME_SWING:
		if global_position.distance_to(player.global_position) <= SWING_RANGE:
			can_attack = false
			attack_timer = ATTACK_COOLDOWN
			player.player_got_damage(randi_range(10, 30))
			print("Swing hit!")

func _on_AnimatedSprite2D_animation_finished() -> void:
	if anim.animation in ["bite_attack", "swing_attack"]:
		can_attack = true
