extends Entity
class_name Player

# What device id to listen to (default 0 = keyboard)
@export var device_id: int = 0

# Maximum total turn speed (deg/s)
@export var max_turn_speed: float = 180.0

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

func _physics_process(delta: float) -> void:
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
