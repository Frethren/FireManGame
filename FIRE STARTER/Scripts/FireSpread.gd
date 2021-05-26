extends Interactable


export(bool) var burning = false
var flame_exists = false
export var interactable = true

onready var flame = preload("res://Scenes/FIRE/Fire.tscn")

func set_burning(b):
	burning = b
	$SpreadTimer.start()
	Gamestats.add_fire()
	print(Gamestats.fire_counter)
	
func _ready():
	if burning:
		$SpreadTimer.start()
#	var r = rand_range(1,2)
	#scale = Vector3(r,r,r)
		
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
			point.set_burning(true)
#			point.get_node("SpreadTimer").start()



func _process(_delta):
	check_flame()

func _on_Timer_timeout():
	expand_area()
