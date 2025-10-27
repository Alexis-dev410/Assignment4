extends Node3D

signal camera_orientation_changed

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var tilt_limit = deg_to_rad(30)
@export var capture_camera = true

@onready var _camera := %Camera3D as Camera3D
@onready var _camera_pivot := $"." as Node3D

var adjusted_mouse_sensitivity: float

# Called when the node enters the scene tree for the first time.
func _ready():
	adjusted_mouse_sensitivity = mouse_sensitivity * 0.01
	if capture_camera:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_camera_pivot.rotation.x -= event.relative.y * adjusted_mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.relative.x * adjusted_mouse_sensitivity
		camera_orientation_changed.emit(_camera_pivot.rotation.y)
	if event.is_action_pressed("ui_cancel"): # Escape by default
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
