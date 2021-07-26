extends Spatial

export(bool) var burning = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var fire = $CPUParticles # Replace with function body.
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("FireSpread")
	print($AnimationPlayer.current_animation)



func _on_AnimationPlayer_animation_changed(old_name, new_name):
	print("work")
