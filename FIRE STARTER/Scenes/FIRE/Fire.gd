extends Spatial

export(bool) var burning = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var fire = $CPUParticles # Replace with function body.
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if burning:
		$AnimationPlayer.play("FireSpread")
