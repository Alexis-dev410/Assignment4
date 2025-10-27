extends Area3D

var activated = false
var player_in_range = false
@onready var player = $"../Mannequin"
@onready var gate1 = %MainGate1
@onready var gate2 = %MainGate2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if body.is_in_group("Players") and Input.is_action_just_pressed("ui_accept"):
		#activate_lever()
		
	if Input.is_action_pressed("activate"):
		var distance = (global_position - player.global_position).length()
		var player_in_range = distance < 4.0
		if player_in_range:
			activate_lever()

func activate_lever():
	if activated:
		return
	activated = true
	move_lever()
	open_gates()
	
func move_lever():
	var lever_switch = $handle/handle_switchers_0
	var tween = create_tween()
	tween.tween_property(lever_switch, "rotation_degrees:x", 110, 2)

func open_gates():
	gate1.rotation_degrees.z = -45
	gate2.rotation_degrees.z = 45
	
