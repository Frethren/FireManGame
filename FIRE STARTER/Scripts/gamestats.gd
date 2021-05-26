extends Node


onready var interaction_label = get_node("FireAmountLabel")

var fire_counter

# Called when the node enters the scene tree for the first time.
func _ready():
	#randomize()
	fire_counter = 0
	#var i = floor(rand_range(0,len(fire)-1))
	#fire[i].burning = true
	#fire[i].get_node("SpreadTimer").start()
	
func add_fire():
	fire_counter+=1

func reduce_fire():
	fire_counter-=1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
