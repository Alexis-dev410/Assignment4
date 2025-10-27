extends Area3D

@onready var win_ui: CanvasLayer = $"../WinCanvas"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		win_ui.show_win_screen()
