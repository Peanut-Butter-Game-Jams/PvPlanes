extends Node2D

var players : Array = []

# Function to prepare the next scene before changing to it
func start_game():
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func set_players(new_players: Array):
	players = new_players
