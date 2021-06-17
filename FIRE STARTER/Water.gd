extends Spatial

var velocity = Vector2(350, 0)


const KILL_TIMER = 4
var timer = 0

var hit_something = false

func _ready():
	$Area.connect("body_entered", self, "collided")


func _physics_process(delta):
	var forward_dir = global_transform.basis.x.normalized()
	global_translate(forward_dir * velocity * delta)

	timer += delta
	if timer >= KILL_TIMER:
		queue_free()


func collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(self.global_transform.origin)

	hit_something = true
	queue_free()
	
	
func _process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation = velocity.angle()
