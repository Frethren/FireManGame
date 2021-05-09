extends Position3D
export (bool) var burning = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	pass # Replace with function body.
	var areas = $Area.get_overlapping_areas()
	for area in areas:
		pass
		
		#spawn fire and set burning on other area to true
	
