@abstract class_name Entity extends CharacterBody2D

# Bullet scene
@onready var bullet_scene: PackedScene = preload("res://scenes/projectiles/Bullet.tscn")
@onready var shield_scene: PackedScene = preload("res://scenes/upgrades/Upgrade.tscn")

# Containers
var sound_players : Array[AudioStreamPlayer] = []
var bullet_upgrades : Array[BaseUpgradeStrategy] = []
var player_upgrades : Array[BaseUpgradeStrategy] = []
@export var fire_sound : AudioStream

# Entity Upgrades
var current_shield: Node2D = null

# Health
@export var max_health: int = 100
var current_health: int = max_health
var lives = 3

# Velocity
@export var max_velocity: float = 256
@export var boost_multiplier: float = 1.50
@export var max_boost : float = 100.0
var is_boosting : bool = false
var boost_speed : float = 1.0
var current_boost : float

# Shooting
@export var min_bullet_velocity : float = 1000.0
@export var fire_rate: float = 1.0
var fire_rate_modifier: float = 1.0
var is_shooting : bool = false
var shoot_timer : Timer = Timer.new()
var current_bullet_velocity : float
@onready var gun_cooldown_timer: Timer = Timer.new()

# Timers
@onready var collision_cooldown_timer: Timer = Timer.new()

# Points
var points : int = 0

# Ready function
func _ready() -> void:
	# Set Current Values
	current_boost = max_boost
	current_health = max_health
	current_bullet_velocity = min_bullet_velocity
	current_shield = null
	
	# Set cooldown timers
	add_child(shoot_timer)
	shoot_timer.one_shot = true
	gun_cooldown_timer.one_shot = true
	add_child(gun_cooldown_timer)
	
	#Setup Audio Players
	for i in range(0, 10):
		var sound_player = AudioStreamPlayer.new()
		sound_players.append(sound_player)
		add_child(sound_player)
	
	# Start Animations
	for child in $SpriteBoundingBox.get_children():
		if child is AnimatedSprite2D:
			child.play("forward")

# applies player upgrades to the player
func _process(delta: float) -> void:
	for upgrade in player_upgrades:
		upgrade.apply_upgrade_to_player(self)
	player_upgrades.clear()
	
	if is_boosting:
		boost_speed = boost_multiplier
		if current_boost <= 0:
			is_boosting = false
		else:
			current_boost -= 1.0
	else:
		boost_speed = 1.0
		if current_boost <= 100.0:
			current_boost += 0.5
		
	if shoot_timer.is_stopped() and is_shooting:
			shoot()
			shoot_timer.start(fire_rate * fire_rate_modifier)

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	if(current_health <= 0):
		die()

func handle_movement(delta : float) -> void:
	# Calculate velocity
	velocity = Vector2.from_angle(rotation) * max_velocity * boost_speed
	
	# Apply movement and check for player collision
	move_and_collide(velocity * delta)
	handle_screen_wrap()

func die() -> void:
	#TODO: Play some sort of death animation
	queue_free()

func shoot() -> void:
	# Fire Input
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	for upgrade in bullet_upgrades:
		upgrade.apply_upgrade_to_projectile(bullet)
	
	bullet.fire(global_position, rotation, get_instance_id())
	play_sound_effect(fire_sound)
	bullet.show()

func play_sound_effect(stream: AudioStream):
	for sound_player in sound_players:
		if not sound_player.playing:
			sound_player.stream = stream
			sound_player.play()
			return
	sound_players[0].stop()
	sound_players[0].stream = stream
	sound_players[0].play()

# Add shield to the player
func add_shield() -> void:
	if not current_shield:
		current_shield = shield_scene.instantiate()
		add_child(current_shield)
		
# Add health to the player, no more than max
func add_health(health: int) -> void:
	current_health = min(current_health + health, max_health)
	
# Applies damage to the player,
# first to the shield, then to the health
func apply_damage(damage: int) -> void:
	if damage <= 0:
		return
	
	if(current_shield):
		damage = current_shield.apply_damage(damage)
		
	current_health = max(current_health - damage, 0)
	
func handle_screen_wrap() -> void:
	var screen_size = get_viewport().get_visible_rect().size

	var sprite_bounding_box = get_node("SpriteBoundingBox").get_shape().size
	
	if position.x - sprite_bounding_box.x >= screen_size.x:
		position.x = 0
	elif position.x <= -sprite_bounding_box.x:
		position.x = screen_size.x
	
	if position.y - sprite_bounding_box.y >= screen_size.y:
		position.y = 0
	elif position.y <= -sprite_bounding_box.y:
		position.y = screen_size.y

func set_sprite(sprite : Texture2D) -> void:
	$SpriteBoundingBox/BodySprite.texture = sprite
