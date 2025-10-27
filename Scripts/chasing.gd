extends State
class_name Chasing

@onready var navigation_agent: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var guard_body: CharacterBody3D = $"../.."
@onready var prisoner: Node3D = get_tree().get_first_node_in_group("Players")
@onready var patrol_points: Array[Node3D] = $"../..".patrol_points

@export var chase_speed := 4.0
@export var attack_range := 1.0
@export var attack_buffer := 0.2
@export var vision_range := 20.0
@export var vision_angle := 360.0
@export var lose_sight_timer := 2.0

var time_since_seen := 0.0

func enter(_msg := {}) -> void:
	animation_player.play("Run")

func update(delta: float) -> void:
	# Don't override Attacking
	if state_machine.current_state.name == "Attacking":
		return

	if not is_instance_valid(prisoner):
		# Check patrol points to decide where to go
		if patrol_points and not patrol_points.is_empty():
			state_machine.transition_to("Patrolling")
		else:
			state_machine.transition_to("Idle")
		return

	var to_prisoner = prisoner.global_position - guard_body.global_position
	var dist = to_prisoner.length()

	# Within attack range → transition to attacking
	if dist <= attack_range + attack_buffer:
		if is_instance_valid(navigation_agent):
			navigation_agent.set_physics_process(false)
		call_deferred("transition_to_attacking")
		return

	# See prisoner → move toward them
	if can_see_prisoner():
		time_since_seen = 0.0
		navigation_agent.target_position = prisoner.global_position
		move_guard(delta)
	else:
		time_since_seen += delta
		if time_since_seen > lose_sight_timer:
			if patrol_points and not patrol_points.is_empty():
				# Resume patrolling from last index
				var patrolling_state = get_node("../Patrolling") as Patrolling
				if patrolling_state:
					patrolling_state.patrol_index = patrolling_state.patrol_index % patrol_points.size()
				state_machine.transition_to("Patrolling")
			else:
				state_machine.transition_to("Idle")

func move_guard(_delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return
	var next_path_point = navigation_agent.get_next_path_position()
	var direction = (next_path_point - guard_body.global_position).normalized()
	guard_body.velocity = direction * chase_speed
	guard_body.move_and_slide()
	orient_guard(direction)

func orient_guard(direction: Vector3):
	if direction.length() > 0.01:
		var look_pos = guard_body.global_position + direction
		look_pos.y = guard_body.global_position.y
		guard_body.look_at(look_pos, Vector3.UP)

func can_see_prisoner() -> bool:
	if not is_instance_valid(prisoner):
		return false
	var to_target = prisoner.global_position - guard_body.global_position
	if to_target.length() > vision_range:
		return false
	var space_state = guard_body.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		guard_body.global_position + Vector3.UP,
		prisoner.global_position + Vector3.UP
	)
	query.exclude = [guard_body]
	var result = space_state.intersect_ray(query)
	return result.is_empty() or result.get("collider") == prisoner

func transition_to_attacking():
	state_machine.transition_to("Attacking")
