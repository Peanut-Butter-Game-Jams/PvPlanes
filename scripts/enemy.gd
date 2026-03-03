extends Entity

var current_target: Node2D
## Used in lerp function to control the speed the enemy looks at the player
@export var turn_speed : float = 1.0 
@onready var node_timer: Timer = $NodeTimer
# Ready function
func _ready() -> void:
	node_timer.one_shot = true
	node_timer.timeout.connect(set_new_target)
	super._ready()

# applies player upgrades to the player
func _process(delta: float) -> void:
	super._process(delta)

# Process physics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if(current_target):
		var angle_to_target_radians = atan2((current_target.global_position.y - global_position.y),(current_target.global_position.x - global_position.x))
		var target_pos = current_target.global_position
		rotation = lerp_angle(rotation, angle_to_target_radians, turn_speed * delta)
	else:
		if node_timer.is_stopped():
			node_timer.start(randi_range(1,3))

# Handles inputs that affect movement
# and finalizes the position of the player 
func handle_movement(delta: float) -> void:
	# Calculate new velocity
	velocity = Vector2.from_angle(rotation) * max_velocity
	# Apply movement
	move_and_collide(velocity * delta)	
	handle_screen_wrap()
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		current_target = body

func _on_attack_area_body_entered(body: Node2D) -> void:
	action_states["fire"] = 1

func _on_attack_area_body_exited(body: Node2D) -> void:
	action_states["fire"] = 0

func _on_detection_area_area_entered(area: Area2D) -> void:
	if area is Upgrade:
		current_target = area	

func set_new_target() -> void:
	node_timer.stop()
	if not current_target:
		current_target = Manager.get_random_upgrade()
