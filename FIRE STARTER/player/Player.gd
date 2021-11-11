extends KinematicBody

var mouse_sensitivity = 1
var direction = Vector3()
var gravity_vec = Vector3()
var stick_amount = 10
var velocity = Vector3()
var acceleration = 10
var speed = 4
var speed_multiplier = 1
var gravity = 9.8
var movement = Vector3()
var jump_height = 4
var camera_height = 0.1



var on_ground = false
var is_crouched = false
var head_angle = 0.2
var is_zoomed = false

var can_jump = false

var can_slide = false
onready var watercreate = $Head/Movements/Camera/Muzzle/Position3D
onready var muzzle = $Head/Movements/Camera/Muzzle
onready var water = preload("res://Scenes/WATERHOSE/Water.tscn")
onready var camera = $Head/Movements/Camera
onready var kickray = $KickRay




func _ready():
	$legs.visible = false
	$Head/DirectionIndicator.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x - event.relative.y * mouse_sensitivity / 10, -70, 80)
	
	direction = Vector3()
	walk()

func _process(delta):
	if Input.is_action_pressed("fire"):
		var new_water = water.instance()
		new_water.global_transform = watercreate.global_transform
		get_tree().get_root().get_node("House").add_child(new_water)
		new_water.velocity = -new_water.transform.basis.z * new_water.muzzle_velocity



func walk():
	if not is_crouched:
		speed_multiplier = 1
		head_angle = 0.2
	else:
		head_angle = 0
	camera_height = -0.1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		direction.z = -1
		if Input.is_key_pressed(KEY_SHIFT) and is_on_floor() and not Input.is_mouse_button_pressed(BUTTON_LEFT) and not Input.is_mouse_button_pressed(BUTTON_RIGHT) and not $CrouchTween.is_active():
			if is_crouched:
				crouching_animation(false)
			speed_multiplier = 2
			camera_height = -0.3
			head_angle = 0.6
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.z = 1
	
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
		direction.x = -1
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x = 1
	
	direction = direction.normalized()
	if direction.z < 0:
		direction.z = direction.z * speed_multiplier
	direction = direction.rotated(Vector3.UP, rotation.y)

func _physics_process(delta):
	# To enable
	if Input.is_action_just_pressed("Menu"):
		get_tree().quit()
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
	if speed_multiplier == 2:
		camera.fov = lerp(camera.fov, 80, 5 * delta)
	else:
		camera.fov = lerp(camera.fov, 70, 5 * delta)
	
	if direction != Vector3() and is_on_floor():
		if not $CameraTween.is_active():
			var amplitude = 0.5 * speed_multiplier
			head_angle = -head_angle
			var animation_speed = clamp(0.25 / speed_multiplier, 0.25/1.6, 0.25)
			#bobbing
			$CameraTween.interpolate_property($Head/Movements, "rotation_degrees", Vector3(), Vector3(-amplitude, 0, head_angle), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CameraTween.interpolate_property($Head/Movements, "rotation_degrees", Vector3(-amplitude, 0, head_angle), Vector3(), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT, animation_speed)
			$CameraTween.start()
	
	if direction != Vector3():
		$Head/Movements.translation.y = lerp($Head/Movements.translation.y, camera_height, 10 * delta)
	else:
		$Head/Movements.translation.y = lerp($Head/Movements.translation.y, 0, 10 * delta)
	
	if is_on_floor():
		if not on_ground:
			landing_animation()
			$JumpTimer.start()
		gravity_vec = -get_floor_normal() * stick_amount
		on_ground = true
	else:
		can_jump = false
		if on_ground:
			gravity_vec = Vector3()
			on_ground = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_key_pressed(KEY_SPACE):
		if is_on_floor() and can_jump:
			jump()
			jump_animation()
			if is_crouched:
				crouching_animation(false)
	
	if Input.is_key_pressed(KEY_CONTROL) or Input.is_key_pressed(KEY_C):
		if not $CrouchTween.is_active():
			crouching_animation(!is_crouched)
			if is_crouched:
				speed_multiplier = 0.5
				
	if Input.is_action_just_pressed("Kick"):
		#rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10
			#get global transform of camera
		$legs.visible = true
		var a = to_global(kickray.translation)
		var b = kickray.get_collision_point()
		var look_vec = b-a
		look_vec = look_vec.normalized()
		$legs/AnimationPlayer.play("default")
		yield(get_tree().create_timer(0.9), "timeout")
		print(a, b, b-a,look_vec)
		look_vec = look_vec
		var door = kickray.get_collider() 
		
		if door and door.is_in_group("Door"):
			
			door.apply_impulse(door.to_local(b),look_vec * delta * 5)
		yield($legs/AnimationPlayer,"animation_finished")
		$legs.visible = false
		

		
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	movement.z = velocity.z + gravity_vec.z
	movement.x = velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	movement = move_and_slide(movement, Vector3.UP)

	if Input.is_mouse_button_pressed(BUTTON_RIGHT) and is_on_floor():
		mouse_sensitivity = 0.5
	else:
		mouse_sensitivity = 1

func jump():
	on_ground = false
	gravity_vec = Vector3.UP * jump_height

# Animations

func jump_animation():
	var animation_speed = 0.25

	$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:x", 0, -5, 0.2 , Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:x", -5, 0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	
	$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", 0, -1, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", -1, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.5)
	
	$CameraTween.interpolate_property($Head/Movements, "translation:y", 0, -0.5, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$CameraTween.interpolate_property($Head/Movements, "translation:y", -0.5, 0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	$CameraTween.start()


func landing_animation():
	$CameraTween.interpolate_property($Head/Movements, "translation:y", 0, -0.5, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$CameraTween.interpolate_property($Head/Movements, "translation:y", -0.5, 0, 0.35, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.15)
	
	$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:x", 0, -5, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:x", -5, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.3)
	
	$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", 0, -1, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", -1, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	$CameraTween.start()

func crouching_animation(crouching):
	is_crouched = crouching
	var animation_speed = 0.4
	if crouching:
		$CrouchTween.interpolate_property($Head, "translation:y", $Head.translation.y, 0.9/1.5, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", 0, -1, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.35)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", -1, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.5)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:x", 0, -1, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.35)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:x", -1, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.5)
		$CrouchTween.interpolate_property($CollisionShape, "shape:height", $CollisionShape.shape.height, 1/1.5, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$CrouchTween.interpolate_property($MeshInstance, "mesh:mid_height", $MeshInstance.mesh.mid_height, 1/1.5, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$CrouchTween.start()
		$CameraTween.start()
	else:
		$CrouchTween.interpolate_property($Head, "translation:y", $Head.translation.y, 0.9, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", 0, 1, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", 1, -1, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.15)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:z", -1, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.3)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:x", 0, -1, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$CameraTween.interpolate_property($Head/Movements, "rotation_degrees:x", -1, 0, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.3)
		$CrouchTween.interpolate_property($CollisionShape, "shape:height", $CollisionShape.shape.height, 1, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$CrouchTween.interpolate_property($MeshInstance, "mesh:mid_height", $MeshInstance.mesh.mid_height, 1, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$CrouchTween.start()
		$CameraTween.start()


func _on_JumpTimer_timeout():
	can_jump = true
	
	
