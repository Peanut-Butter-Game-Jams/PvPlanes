extends Node2D
@export var pve : bool = true

@onready var start_menu = preload("res://scenes/StartMenu.tscn")
@onready var player_menu = preload("res://scenes/PlayerMenu.tscn")
@onready var game_scene = preload("res://scenes/GameScene.tscn")

@onready var upgrades : Array[BaseUpgradeStrategy] = [
	preload("res://resources/strategies/Damage.tres"),
	preload("res://resources/strategies/FireRate.tres"),
	preload("res://resources/strategies/Health.tres"),
	preload("res://resources/strategies/Shield.tres"),
	preload("res://resources/strategies/Range.tres")
	]
@onready var upgrade_scene = preload("res://scenes/Upgrade.tscn")
@onready var player_scene: PackedScene = preload("res://scenes/Player.tscn")
@onready var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@onready var player_sprites: Array = [preload("res://imgs/plane_1_cyan.png"), preload("res://imgs/plane_2_magenta.png"), preload("res://imgs/plane_3_red.png"), preload("res://imgs/plane_4_green.png")]

@onready var border_x = get_viewport_rect().size.x
@onready var border_y = get_viewport_rect().size.y
@onready var player_one_quadrant = [[border_offset,border_x/2],[-border_offset, border_y/2]]
@onready var player_two_quadrant = [[border_x/2, border_x],[-border_offset, border_y/2]]
@onready var player_three_quadrant = [[border_offset, border_x/3],[border_y/2,border_y + border_offset]]
@onready var player_four_quadrant = [[border_x/2, border_x],[border_y/2,border_y + border_offset]]
@onready var quadrants = [player_one_quadrant, player_two_quadrant, player_three_quadrant, player_four_quadrant]
const max_upgrade_count = 5
var current_upgrade_count = 0
const border_offset = 25 # Offset to prevent nodes from spawning around the edges
var players : Array
var upgrade_nodes : Array

func _ready() -> void:
	randomize()
	
func set_players(new_players: Array):
	players = new_players

# Function to prepare the next scene before changing to it
func start_game():
	await get_tree().create_timer(1).timeout
	spawn_players()
	if pve:
		spawn_enemy()
	load_game_scene()

func on_scene_ready():
	start_upgrade_spawn_timer()

func start_upgrade_spawn_timer():
	var wait_time = randf_range(0, 5)
	var timer = get_tree().create_timer(wait_time)
	timer.timeout.connect(spawn_node)
	
func spawn_node() -> void:
	if max_upgrade_count > current_upgrade_count:
		var upgrade_type = randi_range(0,upgrades.size()-1)
		var new_upgrade = upgrade_scene.instantiate()
		new_upgrade.upgrade_strategy = upgrades[upgrade_type]
	
		var x = randf_range(border_offset, get_viewport_rect().size.x - border_offset)
		var y = randf_range(-border_offset, get_viewport_rect().size.y + border_offset)
		
		new_upgrade.position = Vector2(x,y)
		new_upgrade.tree_exited.connect(func():
			current_upgrade_count -= 1
		)
	
		add_child(new_upgrade)
		upgrade_nodes.append(new_upgrade)
		current_upgrade_count += 1	
	start_upgrade_spawn_timer()

func spawn_players() -> void:	
	for i in range(players.size()):
		if players[i] == true:
			var new_player = player_scene.instantiate()
			players[i] = new_player
			new_player.set_device_id(i)
			add_child(new_player)
			new_player.global_position = Vector2(randi_range(quadrants[i][0][0], quadrants[i][0][1]),randi_range(quadrants[i][1][0], quadrants[i][1][1]))
			new_player.rotation = i * 90 + 45
			new_player.set_sprite(player_sprites[i])
			add_child(new_player)

func spawn_enemy() -> void:
	var new_enemy = enemy_scene.instantiate()
	var random_pos = Vector2(randi_range(0,800),randi_range(0,800))
	var random_rot = randi_range(0,359)
	new_enemy.global_rotation = random_rot
	new_enemy.global_position = random_pos
	add_child(new_enemy)

func load_game_scene() -> void:
	get_tree().change_scene_to_packed(game_scene)

func get_random_upgrade() -> Node2D:
	if not upgrade_nodes.is_empty():
		return upgrade_nodes[randi_range(0, upgrade_nodes.size() - 1)]
	return
