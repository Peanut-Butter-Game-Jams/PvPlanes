extends Node2D
signal go_to_player_menu()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start_button: TextureButton = $StartButton
@onready var quit_button: TextureButton = $QuitButton
var selected_button: TextureButton
# Called when the node enters the scene tree for the first time.
var using_mouse : bool = false
var buttons : Array
var button_index = 0

func _ready() -> void:
	animation_player.play("pulsate")
	buttons = [start_button, quit_button]

func _input(event) -> void:
	if event.is_action_pressed("controller_down"):
		button_index = abs((button_index + 1) % buttons.size())
	if event.is_action_pressed("controller_up"):
		button_index = abs((button_index - 1) % buttons.size())
	if event.is_action_pressed("controller_confirm") or event.is_action_pressed("mb_select"):
		if selected_button:
			selected_button.emit_signal("pressed")
	
	selected_button = buttons[button_index]
	for button in buttons:
		if button == selected_button:
			button.grab_focus()
		else:
			button.release_focus()

func _process(delta: float) -> void:
	if using_mouse:
		for button in buttons:
			button.release_focus()
			
func _on_start_button_mouse_entered() -> void:
	using_mouse = true
	selected_button.release_focus()
	selected_button = start_button
	selected_button.grab_focus()

func _on_start_button_mouse_exited() -> void:
	using_mouse = false
	selected_button.release_focus()
	
func _on_quit_button_mouse_entered() -> void:
	using_mouse = true
	selected_button.release_focus()
	selected_button = quit_button
	selected_button.grab_focus()
	
func _on_quit_button_mouse_exited() -> void:
	using_mouse = false
	selected_button.release_focus()
