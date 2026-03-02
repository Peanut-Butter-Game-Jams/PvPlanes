extends Node2D
@onready var start_menu = preload("res://scenes/StartMenu.tscn")
@onready var player_menu = preload("res://scenes/PlayerMenu.tscn")
@onready var game_scene = preload("res://scenes/GameScene.tscn")
var player_health_bar
var player_shield_bar
var enemy_health_bar
var enemy_shield_bar

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

const max_upgrade_count = 5
var current_upgrade_count = 0

var players : Array

func _ready() -> void:
	randomize()
	

func set_players(new_players: Array):
	players = new_players

# Function to prepare the next scene before changing to it
func start_game():
	await get_tree().create_timer(1).timeout
	load_game_scene()

func on_scene_initialized():
	player_health_bar = get_tree().current_scene.find_child("PlayerHealthBar", true, false)
	player_shield_bar = get_tree().current_scene.find_child("PlayerShieldBar", true, false)
	enemy_health_bar = get_tree().current_scene.find_child("EnemyHealthBar", true, false) 
	enemy_shield_bar = get_tree().current_scene.find_child("EnemyShieldBar", true, false) 
	spawn_players()
	spawn_enemy()
	
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
	
		var x = randf_range(0, get_viewport_rect().size.x)
		var y = randf_range(0, get_viewport_rect().size.y)
		
		new_upgrade.position = Vector2(x,y)
		new_upgrade.tree_exited.connect(func():
			current_upgrade_count -= 1
		)
	
		add_child(new_upgrade)
		current_upgrade_count += 1	
	start_upgrade_spawn_timer()

func spawn_players() -> void:	
	for i in range(players.size()):
		if players[i] == true:
			var new_player = player_scene.instantiate()
			player_health_bar.entity = new_player
			player_shield_bar.entity = new_player
			var random_pos = Vector2(randi_range(0,800),randi_range(0,800))
			new_player.set_sprite(player_sprites[i])
			new_player.global_position = random_pos
			add_child(new_player)

func spawn_enemy() -> void:
	var new_enemy = enemy_scene.instantiate()
	enemy_health_bar.entity = new_enemy
	enemy_shield_bar.entity = new_enemy
	var random_pos = Vector2(randi_range(0,800),randi_range(0,800))
	var random_rot = randi_range(0,359)
	#new_enemy.global_rotation = random_rot
	new_enemy.global_position = random_pos
	add_child(new_enemy)

func setup_hud() -> void:
	var health_bar = game_scene.get_child(0)

func load_game_scene() -> void:
	get_tree().change_scene_to_packed(game_scene)
