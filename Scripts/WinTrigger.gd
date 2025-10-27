extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready():
	# Hide UI initially
	panel.visible = false

	# Connect button signals
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func show_win_screen():
	panel.visible = true
	get_tree().paused = true   # optional: pause the game

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
