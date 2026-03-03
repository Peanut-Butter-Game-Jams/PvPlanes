extends Node2D
const GAME_SCENE = preload("res://scenes/GameScene.tscn")
signal game_ready(players : Array)

var players = [false,false,false,false]
var ready_players = [false,false,false,false]
var all_players_ready = false

var player_buttons : Array
var player_labels : Array
var player_check_boxes : Array
var player_check_marks : Array

@onready var player_one_button: Sprite2D = $PlayerOne/PlayerOneButton
@onready var player_one_label: Label = $PlayerOne/PlayerOneLabel
@onready var check_box_one: TextureRect = $PlayerOne/CheckBoxOne
@onready var check_one: TextureRect = $PlayerOne/CheckOne

@onready var player_two_button: Sprite2D = $PlayerTwo/PlayerTwoButton
@onready var player_two_label: Label = $PlayerTwo/PlayerTwoLabel
@onready var check_box_two: TextureRect = $PlayerTwo/CheckBoxTwo
@onready var check_two: TextureRect = $PlayerTwo/CheckTwo

@onready var player_three_button: Sprite2D = $PlayerThree/PlayerThreeButton
@onready var player_three_label: Label = $PlayerThree/PlayerThreeLabel
@onready var check_box_three: TextureRect = $PlayerThree/CheckBoxThree
@onready var check_three: TextureRect = $PlayerThree/CheckThree

@onready var player_four_button: Sprite2D = $PlayerFour/PlayerFourButton
@onready var player_four_label: Label = $PlayerFour/PlayerFourLabel
@onready var check_box_four: TextureRect = $PlayerFour/CheckBoxFour
@onready var check_four: TextureRect = $PlayerFour/CheckFour

func _ready() -> void:
	player_buttons = [player_one_button, player_two_button, player_three_button, player_four_button]
	player_labels = [player_one_label, player_two_label, player_three_label, player_four_label]
	player_check_boxes = [check_box_one, check_box_two, check_box_three, check_box_four]
	player_check_marks = [check_one, check_two, check_three, check_four]

func _input(event: InputEvent) -> void:
	var device_id = event.device
	if Input.is_action_just_pressed("controller_confirm") or Input.is_action_just_pressed("kb_space"):
		player_active(device_id, true)
	if Input.is_action_just_pressed("controller_return") or Input.is_action_just_pressed("kb_escape"):
		if ready_players[device_id]:
			player_ready(device_id, false)
		else:
			player_active(device_id, false)
	if Input.is_action_just_pressed("controller_start") or Input.is_action_just_pressed("kb_enter"):
		player_ready(device_id, true)
		
func player_active(player_index: int, active : bool):
	players[player_index] = active
	player_buttons[player_index].visible = !active
	player_check_boxes[player_index].visible = active
	
func player_ready(player_index: int, ready : bool):
	ready_players[player_index] = ready
	player_check_marks[player_index].visible = ready
	
	if players == ready_players:
		start_game()
	
func start_game():
	Manager.set_players(players)
	Manager.start_game()
