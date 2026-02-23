extends CharacterBody2D
class_name Player

# Bullet scene
@onready var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")

# Containers
var sound_players : Array[AudioStreamPlayer] = []
var bullet_upgrades : Array[BaseUpgradeStrategy] = []
var player_upgrades : Array[BaseUpgradeStrategy] = []

@export var fire_sound : AudioStream

# What device id to listen to (default 0 = keyboard)
@export var device_id: int = 0

# Maximum total velocity of the player (units/s)
@export var max_velocity: float = 256

# Maximum total turn speed (deg/s)
@export var max_turn_speed: float = 90.0

# Maximum health
@export var max_health: int = 100

# Current health
var current_health: int = max_health

# Current shield
var current_shield: int = 0

# Fire rate (s)
@export var fire_rate: float = 1.0

# Fire rate modifier
var fire_rate_modifier: float = 1.0

# Timers
@onready var gun_cooldown_timer: Timer = Timer.new()
@onready var collision_cooldown_timer: Timer = Timer.new()

# Booleans
var can_collide: bool= true

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
	collision_cooldown_timer.one_shot = true
	add_child(gun_cooldown_timer)
	add_child(collision_cooldown_timer)
	
	collision_cooldown_timer.timeout.connect(_on_CollisionCooldownTimer_timeout)
	
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

# Process physics
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_weapon_actions(delta)
	if(current_health <= 0):
		die()

func die() -> void:
	#TODO: Play some sort of death animation
	queue_free()

# Gets the keycode of a joypad button or key agnostically as an int
func get_keycode(event: InputEvent) -> int:
	if event is InputEventKey:
		return event.keycode
	if event is InputEventJoypadButton:
		return event.button_index
	return -1

func _input(event):
	# Check only if the event is from the device we want
	if event.device == device_id:
		if event is InputEventKey or event is InputEventJoypadButton:
			for action in action_states.keys():
				var found: bool = false
				for keycode in ACTION_TO_BUTTON[action]:
					if get_keycode(event) == int(keycode):
						found = true
						break
				if found:
					action_states[action] = event.pressed
		# Handle joystick axes
		elif event is InputEventJoypadMotion:
			if event.axis == JOY_AXIS_LEFT_X:
				# Move left
				action_states["left"] = event.axis_value < -DEADZONE
				# Move right
				action_states["right"] = event.axis_value > DEADZONE

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
func add_shield(shield: int) -> void:
	current_shield += shield

# Add health to the player, no more than max
func add_health(health: int) -> void:
	current_health = min(current_health + health, max_health)
	
# Applies damage to the player,
# first to the shield, then to the health
func apply_damage(damage: int) -> void:
	if damage <= 0:
		return
	
	var shield_before_damage = current_shield
	current_shield = max(current_shield - damage, 0)
	damage -= shield_before_damage - current_shield

	current_health = max(current_health - damage, 0)
	print_debug(device_id, " health: ", current_health)

# Handles inputs that affect movement
# and finalizes the position of the player 
func handle_movement(delta: float) -> void:
	if action_states["left"]:
		rotation_degrees -= max_turn_speed * delta
	if action_states["right"]:
		rotation_degrees += max_turn_speed * delta
	
	# Calculate new velocity
	velocity = Vector2.from_angle(rotation) * max_velocity
	
	# Apply movement and check for player collision
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Player:
			on_collision_with_player(collider)
	
	handle_screen_wrap()

func on_collision_with_player(collider):
	if can_collide:
		self.apply_damage(max_health)
		collider.apply_damage(collider.max_health)
		can_collide = false
		collision_cooldown_timer.start(1.0)
		
		print_debug("Collision between ", device_id, " and, ", collider.device_id)
		
		# Disable collisions temporarily
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)

func _on_CollisionCooldownTimer_timeout():
	can_collide = true
	# Re-enable collisions (use your original layer/mask numbers)
	set_deferred("collision_layer", 1)
	set_deferred("collision_mask", 1)

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
