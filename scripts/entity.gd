extends CharacterBody2D
class_name Entity 

# Bullet scene
@onready var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
@onready var shield_scene: PackedScene = preload("res://scenes/shield.tscn")

# Containers
var sound_players : Array[AudioStreamPlayer] = []
var bullet_upgrades : Array[BaseUpgradeStrategy] = []
var player_upgrades : Array[BaseUpgradeStrategy] = []

@export var fire_sound : AudioStream

# Maximum total velocity of the player (units/s)
@export var max_velocity: float = 256

# Maximum health
@export var max_health: int = 100

# Current health
var current_health: int = max_health

# Current shield
var current_shield: Node2D

# Fire rate (s)
@export var fire_rate: float = 1.0

# Fire rate modifier
var fire_rate_modifier: float = 1.0

# Timers
@onready var gun_cooldown_timer: Timer = Timer.new()
@onready var collision_cooldown_timer: Timer = Timer.new()

# Booleans
var can_collide: bool = false

# Deadzone for joystick movement
const DEADZONE = 0.2

# Whether the action is pressed or not
var action_states := {
	"left": false,
	"right": false,
	"fire": false,
}

# Maps the actions to certain buttons
# Joysticks are handled separately
const ACTION_TO_BUTTON := {
	"left": [KEY_LEFT],
	"right": [KEY_RIGHT],
	"fire": [KEY_SPACE, KEY_ENTER, JOY_BUTTON_B],
}

# Ready function
func _ready() -> void:
	# Set cooldown timers
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

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_weapon_actions(delta)
	if(current_health <= 0):
		die()

func die() -> void:
	#TODO: Play some sort of death animation
	queue_free()

func handle_weapon_actions(delta: float) -> void:
	# Fire Input
	if action_states["fire"] and gun_cooldown_timer.is_stopped():
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		for upgrade in bullet_upgrades:
			upgrade.apply_upgrade_to_projectile(bullet)
		
		bullet.fire(global_position, rotation, get_instance_id())
		play_sound_effect(fire_sound)
		bullet.show()
		gun_cooldown_timer.start(fire_rate * fire_rate_modifier)

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
	
func handle_movement(delta: float) -> void:
	pass

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
