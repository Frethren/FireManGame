extends KinematicBody

var path = []
var path_node = 0

var speed = 10

onready var nav = $"../Navigation"
onready var player = $"../Player"

var target = Vector3.ZERO

func _ready():
	new_path()
#	target = Vector3(rand_range(-10,10),rand_range(-10,10),rand_range(-10,10))
#	target = nav.get_closest_point(target)
#	path = nav.get_simple_path(global_transform.origin, target)
#	if path_node < path.size():
#		var direction = (path[path_node] - global_transform.origin)
#		if direction.length() < 1:
#			path_node += 1
#		else:
#			move_and_slide(direction.normalized() * speed, Vector3.UP)
			
func new_path():
	target = Vector3(rand_range(-400,400),rand_range(-40,40),rand_range(-40,40))
	target = nav.get_closest_point(target)
	path = nav.get_simple_path(global_transform.origin, target)
	path_node = 0
	
func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)
		look_at(transform.origin + direction.normalized(), Vector3.UP)
	else:
		new_path()
	
	if $RayCast.is_colliding():
		if $RayCast.get_collider().is_in_group("Door"):
			new_path()
		elif $RayCast.get_collider():
			pass

#func move_to(target_pos):
#	path = nav.get_simple_path(global_transform.origin, target_pos)
#	path_node = 0

#func _on_Timer_timeout():
#	move_and_slide(target)
