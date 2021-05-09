extends Area


export(bool) var burning = false
var flame_exists = false


onready var flame = preload("res://Scenes/FIRE/Fire.tscn")

func _ready():
	if burning:
		$SpreadTimer.start()
		
func check_flame():
	if burning and not flame_exists:
		var f = flame.instance()
		add_child(f)
		flame_exists = true
		pass

func expand_area():
	var spread = get_overlapping_areas()
	for point in spread:
		if point.burning == false:
			point.burning = true
			point.get_node("SpreadTimer").start()


func _process(delta):
	check_flame()

func _on_Timer_timeout():
	expand_area()
