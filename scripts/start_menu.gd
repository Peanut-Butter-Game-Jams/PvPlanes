extends Node2D
signal go_to_player_menu()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start_button: TextureButton = $StartButton
@onready var quit_button: TextureButton = $QuitButton
var selected_button: TextureButton
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	animation_player.play("pulsate")
	selected_button = start_button
	var connected_joypads = Input.get_connected_joypads()
	for i in range(0,connected_joypads.size()):
		connected_joypads[i] = (i+1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("controller_one_down") or Input.is_action_just_pressed("controller_one_up"):
		if selected_button == quit_button:
			selected_button.release_focus()
			selected_button = start_button
			selected_button.grab_focus()
		elif selected_button == start_button:
			selected_button.release_focus()
			selected_button = quit_button
			selected_button.grab_focus()
		
	if Input.is_action_just_pressed("controller_one_confirm") or Input.is_action_just_pressed("mb_select"):
		selected_button.emit_signal("pressed")
		
func _on_start_button_mouse_entered() -> void:
	selected_button.release_focus()
	selected_button = start_button
	selected_button.grab_focus()

func _on_quit_button_mouse_entered() -> void:
	selected_button.release_focus()
	selected_button = quit_button
	selected_button.grab_focus()
