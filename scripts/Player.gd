extends Entity
class_name Player

# Whether the action is pressed or not
var action_states := {
	"left": false,
	"right": false,
}
# What device id to listen to (default 0 = keyboard)
@export var device_id: int = 0

# Maximum total turn speed (deg/s)
@export var max_turn_speed: float = 3.0

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _input(event):
	# Check only if the event is from the device we want
	if not event.device == device_id:
		return
	
	# Shooting
	if event.is_action_pressed("kb_space") or event.is_action_pressed("controller_interact"):
		is_shooting = true
	if event.is_action_released("kb_space") or event.is_action_released("controller_interact"):
		is_shooting = false		
	
	# Boosting
	if event.is_action_pressed("kb_shift") or event.is_action_pressed("controller_accept"):
		is_boosting = true
	if event.is_action_released("kb_shift") or event.is_action_released("controller_accept"):
		is_boosting = false		
		
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
			action_states["left"] = event.axis_value
			# Move right
			action_states["right"] = event.axis_value

# Handles inputs that affect movement
# and finalizes the position of the player 
func handle_movement(delta: float) -> void:
	if action_states["left"]:
		rotation_degrees -= max_turn_speed * delta * 90
	if action_states["right"]:
		rotation_degrees += max_turn_speed * delta * 90
	
	super.handle_movement(delta)

func set_device_id(new_device_id) -> void:
	device_id = new_device_id
	
