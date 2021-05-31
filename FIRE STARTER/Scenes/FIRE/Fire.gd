extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var fire = $CPUParticles # Replace with function body.
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	fire.scale_amount *= 1.01 	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



	

