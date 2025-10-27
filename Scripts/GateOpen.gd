extends Node3D

@export var open_angle := 45.0

func _ready():
	GlobalSignals.connect("open_main_gates", Callable(self, "_on_open_main_gates"))

func _on_open_main_gates():
	print("Opening door:", name)
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:z", open_angle, 2)
