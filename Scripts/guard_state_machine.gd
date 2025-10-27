extends StateMachine 

var current_state: State  # keep your own reference to the active state

func _ready() -> void:
	# Wait one frame to ensure all nodes are ready
	await get_tree().process_frame

	# Assign this state machine to all child states
	for child in get_children():
		if "state_machine" in child:
			child.state_machine = self

	# Initialize the first state if defined
	if initial_state != NodePath():
		var state_node = get_node(initial_state)
		change_state(state_node)

func change_state(new_state: State, msg := {}) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(msg)

func transition_to(state_name: String, msg := {}) -> void:
	if not has_node(state_name):
		push_warning("No such state: %s" % state_name)
		return
	var new_state: State = get_node(state_name)
	change_state(new_state, msg)

func _physics_process(_delta: float) -> void:
	if current_state:
		current_state.update(_delta)
