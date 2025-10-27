extends State
class_name Patrolling

@onready var patrol_points: Array[Node3D] = $"../..".patrol_points
@onready var navigation_agent: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var guard_body: CharacterBody3D = $"../.."
@onready var prisoner: Node3D = get_tree().get_first_node_in_group("Prisoner")

var patrol_index := 0
@export var patrol_speed := 2.5
@export var vision_range := 20.0
@export var vision_angle := 360.0

func enter(_msg := {}) -> void:
	animation_player.play("Walk")
	select_next_target()

func update(delta: float) -> void:
	if patrol_points.is_empty():
		state_machine.transition_to("Idle")
		return

	if navigation_agent.is_navigation_finished():
		select_next_target()
	else:
		move_guard(delta)

	if can_see_prisoner():
		state_machine.transition_to("Chasing")


func move_guard(_delta: float) -> void:
	var next_path_point = navigation_agent.get_next_path_position()
	var direction = (next_path_point - guard_body.global_position).normalized()
	guard_body.velocity = direction * patrol_speed
	guard_body.move_and_slide()
	orient_guard(direction)

func select_next_target():
	if patrol_points.is_empty():
		return
	patrol_index += 1
	var next_target = patrol_points[patrol_index % patrol_points.size()]
	navigation_agent.target_position = next_target.global_position
	if not navigation_agent.is_target_reachable():
		patrol_index += 1
		next_target = patrol_points[patrol_index % patrol_points.size()]
		navigation_agent.target_position = next_target.global_position

func orient_guard(direction: Vector3):
	if direction.length() > 0.01:
		var look_pos = guard_body.global_position + direction
		look_pos.y = guard_body.global_position.y
		guard_body.look_at(look_pos, Vector3.UP)
		guard_body.rotate_y(deg_to_rad(180))

func can_see_prisoner() -> bool:
	if not is_instance_valid(prisoner):
		return false

	var to_target = prisoner.global_position - guard_body.global_position
	if to_target.length() > vision_range:
		return false

	var forward = -guard_body.global_transform.basis.z
	var angle = rad_to_deg(acos(forward.dot(to_target.normalized())))
	if angle > vision_angle:
		return false

	var space_state = guard_body.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		guard_body.global_position + Vector3.UP,
		prisoner.global_position + Vector3.UP
	)
	query.exclude = [guard_body]
	var result = space_state.intersect_ray(query)
	return result.is_empty() or result.get("collider") == prisoner
