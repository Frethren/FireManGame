extends Spatial


export var muzzle_velocity = 20
export var g = Vector3.DOWN * 50

var velocity = Vector3.ZERO


const KILL_TIMER = 4
var timer = 0

var hit_something = false




func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta


func collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(self.global_transform.origin)

	hit_something = true
	queue_free()
	
	



func _on_Area_area_entered(area):
	if area.is_in_group("Fire"):
		if area.burning:
			area.remove_fire()
			



func _on_waterarea_body_entered(body):
	queue_free()
