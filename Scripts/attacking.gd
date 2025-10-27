extends State
class_name Attacking

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var guard_body: CharacterBody3D = $"../.."
@onready var prisoner: Node3D = get_tree().get_first_node_in_group("Players") # <-- updated to group
@onready var navigation_agent: NavigationAgent3D = $"../../NavigationAgent3D"

@export var attack_range := 0.5
@export var attack_exit_buffer := 3.0
@export var attack_cooldown := 1.2

var attack_timer := 0.0
var attack_position := Vector3.ZERO
var is_attacking := false
var has_hit := false # ensure player is only hit once per attack

func enter(_msg := {}) -> void:
	attack_position = guard_body.global_position
	guard_body.velocity = Vector3.ZERO
	guard_body.move_and_slide()

	if is_instance_valid(navigation_agent):
		navigation_agent.set_physics_process(false) # Stop navigation

	animation_player.play("Attack")
	attack_timer = 0.0
	is_attacking = true
	has_hit = false

func exit() -> void:
	if is_instance_valid(navigation_agent):
		navigation_agent.set_physics_process(true)
	is_attacking = false

func update(delta: float) -> void:
	if not is_instance_valid(prisoner):
		state_machine.transition_to("Patrolling")
		return

	var to_prisoner = (prisoner.global_position - guard_body.global_position).normalized()
	var dist = guard_body.global_position.distance_to(prisoner.global_position)

	# Clamp guard in place
	guard_body.global_position = attack_position
	orient_guard(to_prisoner)

	# Trigger player hit when in range
	if dist <= attack_range and not has_hit:
		has_hit = true
		if prisoner.has_method("on_hit"):
			prisoner.on_hit()

	# Re-trigger attack animation if finished and cooldown passed
	attack_timer += delta
	if not animation_player.is_playing() and attack_timer > attack_cooldown:
		animation_player.play("Attack")
		attack_timer = 0.0
		has_hit = false  # reset for next attack cycle

	# Exit attack if prisoner moves out of range
	if dist > attack_exit_buffer:
		is_attacking = false
		state_machine.transition_to("Chasing")

func orient_guard(direction: Vector3):
	if direction.length() > 0.01:
		var target_yaw = atan2(direction.x, direction.z)
		guard_body.rotation.y = lerp_angle(guard_body.rotation.y, target_yaw, 0.1)
