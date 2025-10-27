extends State
class_name Idle

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var guard_body: CharacterBody3D = $"../.."
@onready var prisoner: Node3D = get_tree().get_first_node_in_group("Prisoner")

@export var vision_range := 20.0
@export var vision_angle := 50.0
@export var attack_range := 1.0

func enter(_msg := {}) -> void:
	print("[Idle] Entered Idle state.")
	animation_player.play("Idle")
	guard_body.velocity = Vector3.ZERO
	guard_body.move_and_slide()

	# Check once on enter if prisoner is in sight
	if is_instance_valid(prisoner):
		var dist = guard_body.global_position.distance_to(prisoner.global_position)
		if dist <= attack_range:
			print("[Idle] Prisoner in attack range! Switching to Attacking.")
			call_deferred("_switch_to_attacking")
		elif can_see_prisoner():
			print("[Idle] Prisoner detected! Switching to Chasing.")
			call_deferred("_switch_to_chasing")

func update(_delta: float) -> void:
	# Idle stays idle; do not continuously check to prevent overwriting other states
	pass

func _switch_to_chasing():
	if is_instance_valid(state_machine):
		state_machine.transition_to("Chasing")

func _switch_to_attacking():
	if is_instance_valid(state_machine):
		state_machine.transition_to("Attacking")

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
