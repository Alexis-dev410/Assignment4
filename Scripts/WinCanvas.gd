extends CanvasLayer

@onready var panel2: Control = $Panel2
@onready var panel: Control = $Panel
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready():
	print("[WinCanvas] Ready — setting up buttons.")

	panel.visible = false
	panel2.visible = false

	# ✅ Allow UI to still work while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_button.process_mode = Node.PROCESS_MODE_ALWAYS

	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	print("[WinCanvas] Connected button signals.")

func show_lose_screen():
	print("[WinCanvas] Showing lose screen.")
	panel2.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func show_win_screen():
	print("[WinCanvas] Showing win screen.")
	panel.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_pressed():
	print("[WinCanvas] Restart button pressed.")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	print("[WinCanvas] Quit button pressed.")
	get_tree().quit()
