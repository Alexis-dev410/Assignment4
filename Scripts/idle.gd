extends State
class_name Idle

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var guard_body: CharacterBody3D = $"../.."
@onready var prisoner: Node3D = get_tree().get_first_node_in_group("Prisoner")

@export var vision_range := 20.0
@export var vision_angle := 360.0

var prisoner_seen := false

func enter(_msg := {}) -> void:
	print("[Idle] Entered Idle state.")
	animation_player.play("Idle")
	guard_body.velocity = Vector3.ZERO
	guard_body.move_and_slide()

	# Only check once on enter
	if can_see_prisoner():
		prisoner_seen = true
		print("[Idle] Prisoner detected! Switching to Chasing.")
		call_deferred("_switch_to_chasing")

func update(_delta: float) -> void:
	# Idle stays idle; don't keep checking here
	pass

func _switch_to_chasing():
	state_machine.transition_to("Chasing")

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
