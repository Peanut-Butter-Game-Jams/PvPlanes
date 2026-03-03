extends Entity
class_name Player

# What device id to listen to (default 0 = keyboard)
@export var device_id: int = 0

# Maximum total turn speed (deg/s)
@export var max_turn_speed: float = 180.0

var shoot_timer : Timer = Timer.new()
var is_shooting : bool = false

func _ready() -> void:
	add_child(shoot_timer)
	shoot_timer.one_shot = true
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

func _physics_process(delta: float) -> void:
	if shoot_timer.is_stopped() and is_shooting:
			shoot()
			shoot_timer.start(fire_rate * fire_rate_modifier)
	super._physics_process(delta)

# Gets the keycode of a joypad button or key agnostically as an int
func get_keycode(event: InputEvent) -> int:
	if event is InputEventKey:
		return event.keycode
	if event is InputEventJoypadButton:
		return event.button_index
	return -1

func _input(event):
	# Check only if the event is from the device we want
	if not event.device == device_id:
		return
		
	if event.is_action_pressed("kb_space") or event.is_action_pressed("controller_interact"):
		is_shooting = true
	if event.is_action_released("kb_space") or event.is_action_released("controller_interact"):
		is_shooting = false		
	
	# Keyboard Movement
	if event is InputEventKey:
		if event.is_action_pressed("kb_left"):
			action_states["left"] = true
		if event.is_action_released("kb_left"):
			action_states["left"] = false
		
		if event.is_action_pressed("kb_right"):
			action_states["right"] = true
		if event.is_action_released("kb_right"):
			action_states["right"] = false
			
	# D-Pad Movement		
	elif event is InputEventJoypadButton:
		if event.is_action_pressed("controller_left"):
			action_states["left"] = true
		if event.is_action_released("controller_left"):
			action_states["left"] = false
		
		if event.is_action_pressed("controller_right"):
			action_states["right"] = true
		if event.is_action_released("controller_right"):
			action_states["right"] = false
			
	# Joypad Movement
	elif event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_LEFT_X:
			# Move left
			action_states["left"] = event.axis_value < -DEADZONE
			# Move right
			action_states["right"] = event.axis_value > DEADZONE

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
	move_and_collide(velocity * delta)
	handle_screen_wrap()

func set_device_id(new_device_id) -> void:
	device_id = new_device_id
	
