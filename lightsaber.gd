extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $Area2D

var owner_ref = null
@export var damage := 1

func _ready():
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_body_entered)

func start():
	anim.play("slash")

func enable_hit():
	hitbox.monitoring = true

func disable_hit():
	hitbox.monitoring = false

func _on_body_entered(body):
	if body == owner_ref:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_animation_finished():
	queue_free()
