extends Area3D

var activated = false
var player_in_range = false
@onready var player = $"../Mannequin"

func _process(_delta):
	if Input.is_action_pressed("activate"):
		var distance = (global_position - player.global_position).length()
		if distance < 4.0:
			activate_lever()

func activate_lever():
	if activated:
		return
	activated = true
	move_lever()
	GlobalSignals.emit_signal("open_main_gates") # ✅ emit the signal instead of touching doors directly

func move_lever():
	var lever_switch = $handle/handle_switchers_0
	var tween = create_tween()
	tween.tween_property(lever_switch, "rotation_degrees:x", 110, 2)
