extends AnimatableBody2D

@onready var top_detector = $TopDetector

var spawned := false

func _ready() -> void:
	top_detector.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if spawned:
		return
	
	# Check if it's the player (adjust name/group as needed)
	if body.name == "Player":
		spawned = true
		
		var new_platform = duplicate()
		get_parent().add_child(new_platform)
		
		new_platform.position = position + Vector2(0, -20)
