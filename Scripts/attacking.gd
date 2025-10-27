extends State
class_name Attacking

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var guard_body: CharacterBody3D = $"../.."
@onready var prisoner: Node3D = get_tree().get_first_node_in_group("Prisoner")
@onready var navigation_agent: NavigationAgent3D = $"../../NavigationAgent3D"

@export var attack_range := 1.0
@export var attack_exit_buffer := 3.0
@export var attack_cooldown := 1.2

var attack_timer := 0.0
var attack_position := Vector3.ZERO

func enter(_msg := {}) -> void:
	attack_position = guard_body.global_position
	guard_body.velocity = Vector3.ZERO
	guard_body.move_and_slide()
	if is_instance_valid(navigation_agent):
		navigation_agent.target_position = guard_body.global_position
		navigation_agent.velocity = Vector3.ZERO
	animation_player.play("Attack")
	attack_timer = 0.0

func update(delta: float) -> void:
	if not is_instance_valid(prisoner):
		state_machine.transition_to("Patrolling")
		return

	var to_prisoner = (prisoner.global_position - guard_body.global_position).normalized()
	var dist = guard_body.global_position.distance_to(prisoner.global_position)

	# Clamp position
	guard_body.global_position = attack_position
	orient_guard(to_prisoner)

	# Re-trigger attack animation
	attack_timer += delta
	if not animation_player.is_playing() and attack_timer > attack_cooldown:
		animation_player.play("Attack")
		attack_timer = 0.0

	# Exit to chasing if prisoner moves far
	if dist > attack_exit_buffer:
		state_machine.transition_to("Chasing")

func orient_guard(direction: Vector3):
	if direction.length() > 0.01:
		var look_pos = guard_body.global_position + direction
		look_pos.y = guard_body.global_position.y
		guard_body.look_at(look_pos, Vector3.UP)
