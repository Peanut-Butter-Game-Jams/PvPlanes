extends Node2D
const GAME_SCENE = preload("res://scenes/GameScene.tscn")
signal game_ready(players : Array)

enum DEVICE
{
	ZERO,
	ONE,
	TWO,
	THREE
}
var players : Array
var ready_players : Array
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
	# PLAYER ONE ACTIONS
	if event.is_action_pressed("kb_space"):
		add_player(DEVICE.ZERO)
	if event.is_action_pressed("kb_escape"):
		if player_is_ready(DEVICE.ZERO):
			player_ready(DEVICE.ZERO, false)
		else:
			remove_player(DEVICE.ZERO)
			
	if event.is_action_pressed("kb_enter"):
		player_ready(DEVICE.ZERO, true)
		
	# PLAYER TWO ACTIONS
	if event.is_action_pressed("controller_one_confirm"):
		add_player(DEVICE.ONE)
	if event.is_action_pressed("controller_one_return"):
		if player_is_ready(DEVICE.ONE):
			player_ready(DEVICE.ONE, false)
		else:
			remove_player(DEVICE.ONE)
			
	if event.is_action_pressed("controller_one_start"):
		player_ready(DEVICE.ONE, true)

	# PLAYER THREE ACTIONS
	if event.is_action_pressed("controller_two_confirm"):
		player_active(DEVICE.TWO, true)
	if event.is_action_pressed("controller_two_return"):
		if player_is_ready(DEVICE.TWO):
			player_ready(DEVICE.TWO, false)
		else:
			player_active(DEVICE.TWO, false)
	if event.is_action_pressed("controller_two_start"):
		if player_is_active(DEVICE.TWO):
			player_ready(DEVICE.TWO, true)
		
	# PLAYER FOUR ACTIONS
	if event.is_action_pressed("controller_three_confirm"):
		player_active(DEVICE.THREE, true)
	if event.is_action_pressed("controller_three_return"):
		if player_is_ready(DEVICE.THREE):
			player_ready(DEVICE.THREE, false)
		else:
			player_active(DEVICE.THREE, false)
	if event.is_action_pressed("controller_three_start"):
		if player_is_active(DEVICE.THREE):
			player_ready(DEVICE.THREE, true)

func _process(delta: float) -> void:
	for i in range(0,players.size()):
		player_buttons[i].visible = false
		player_check_boxes[i].visible = true
		if ready_players[i]:
			player_check_marks[i].visible = true
		else:
			player_check_marks[i].visible = false
	for i in range(players.size(), 4):
		player_buttons[i].visible = true
		player_check_boxes[i].visible = false
		player_check_marks[i].visible = false

func add_player(device_id : int):
	players.append(device_id)
	ready_players.append(false)
	
func remove_player(device_id : int):
	var index = players.find(device_id)
	ready_players.remove_at(index)
	players.erase(device_id)
	
func player_is_ready(device_id : int):
	var index = players.find(device_id)
	if index != -1:
		return ready_players[index]

func player_ready(device_id: int, ready : bool):
	var index = players.find(device_id)
	if index != -1:
		ready_players[index] = ready
		# Start game if all players are ready
		for i in range(ready_players.size()):
			if ready_players[i] == false:
				return
		start_game()

func start_game():
	Manager.set_players(players)
	Manager.start_game()

func player_is_active(player_index: int):
	return players[player_index]
		
func player_active(player_index: int, active : bool):
	players[player_index] = active
	player_buttons[player_index].visible = !active
	player_check_boxes[player_index].visible = active
	
