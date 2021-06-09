extends RigidBody


var shoot = false

const SPEED = 10

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	if shoot:
		apply_impulse(transform.basis.z, -transform.basis.z)

func _on_Area_area_entered(area):
	if area.is_in_group("Fire"):
		area.burning = false
		queue_free()
	else:
		queue_free()
