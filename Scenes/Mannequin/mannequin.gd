extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.1
const TURN_SPEED := 15.0  
const IDLE_THRESHOLD = 0.05
const RUN_SPEED_MULTIPLIER = 2

var lock_speed = false
var camera_rotation_y: float = 0.0
var run_multiplier = 1

@onready var visual: Node3D = $Node/Skeleton3D
@onready var animation_tree = $AnimationTree

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# WASD input (camera-relative) — unchanged
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("run"):
		run_multiplier = RUN_SPEED_MULTIPLIER
	else:
		run_multiplier = 1

	if direction:
		var adjusted_direction := direction.rotated(Vector3.UP, camera_rotation_y)

		# Move as before
		velocity.x = adjusted_direction.x * SPEED * run_multiplier
		velocity.z = adjusted_direction.z * SPEED * run_multiplier

		# --- only rotate the MODEL while a key is held ---
		if input_dir.length() > 0.0:
			var target_yaw := atan2(adjusted_direction.x, adjusted_direction.z)# - PI/2
			visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, TURN_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	animate()

func _on_camera_3d_camera_rotation_changed(rotation_y_rad) -> void:
	camera_rotation_y = rotation_y_rad  # mouse freelook only; keys never touch camera

func release_jump():
	velocity.y = JUMP_VELOCITY


func animate():
	animation_tree["parameters/conditions/is_idle"] = velocity.length() < IDLE_THRESHOLD
	animation_tree["parameters/conditions/is_moving"] = Vector3(velocity.x, 0, velocity.z).length() >= IDLE_THRESHOLD
	animation_tree["parameters/conditions/is_running"] = Vector3(velocity.x, 0, velocity.z).length() >= SPEED + IDLE_THRESHOLD
	animation_tree["parameters/conditions/grounded"] = is_on_floor()
	animation_tree["parameters/conditions/initiate_jump"] = Input.is_action_just_pressed("ui_accept") and is_on_floor()
	
func delayed_jump():
	velocity.y = JUMP_VELOCITY

func lock_the_speed():
	lock_speed = true
	
func unlock_speed():
	lock_speed = false


func _on_camera_root_camera_orientation_changed(rotation_y_rad)-> void:
	camera_rotation_y = rotation_y_rad
