extends Entity

var current_target: Node2D
## Used in lerp function to control the speed the enemy looks at the player
@export var turn_speed : float = 1.0 
@export var detection_range_threshold : int = 25
@export var evasion_time : int = 3
@onready var node_timer: Timer = $NodeTimer
@onready var detection_area: Area2D = %DetectionArea
@onready var attack_area: Area2D = $AttackArea
var evasion_timer : Timer = Timer.new()
# Ready function
func _ready() -> void:
	add_child(evasion_timer)
	evasion_timer.one_shot = true
	evasion_timer.timeout.connect(target_evaded)
	node_timer.one_shot = true
	detection_area.apply_scale(Vector2(detection_range_threshold, detection_range_threshold))
	attack_area.apply_scale(Vector2(-detection_range_threshold, -detection_range_threshold))
	super._ready()

# applies player upgrades to the player
func _process(delta: float) -> void:
	super._process(delta)
	# Scan for Player
	current_target = scan_for_target()
		
# Process physics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	# Look at target
	if current_target:
		var angle_to_target_radians = atan2((current_target.global_position.y - global_position.y),(current_target.global_position.x - global_position.x))
		var target_pos = current_target.global_position
		rotation = lerp_angle(rotation, angle_to_target_radians, turn_speed * delta)

# Handles inputs that affect movement
# and finalizes the position of the player 
func handle_movement(delta: float) -> void:
	# Calculate new velocity
	velocity = Vector2.from_angle(rotation) * max_velocity
	# Apply movement
	move_and_collide(velocity * delta)	
	handle_screen_wrap()

func scan_for_target() -> Node2D:
	var closest_node = null
	var closest_node_distance = 999
	for node in detection_area.get_overlapping_bodies():
		if node is Player:
			var distance = distance_to(node.global_position)
			if not closest_node:
				closest_node = node
				closest_node_distance = distance
			if distance < closest_node_distance:
				closest_node = node
				closest_node_distance = distance
	for node in detection_area.get_overlapping_areas():
		if node is Upgrade:
			var distance = distance_to(node.global_position)
			if not closest_node:
				closest_node = node
				closest_node_distance = distance
			if distance < closest_node_distance:
				closest_node = node
				closest_node_distance = distance
	return closest_node
	
func distance_to(position) -> float:
	return global_position.distance_to(position)

func _on_detection_area_body_exited(body: Node2D) -> void:
	evasion_timer.start(evasion_time)

func target_evaded() -> void:
	current_target = null
	
func _on_attack_area_body_entered(body: Node2D) -> void:
	is_shooting = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	is_shooting = false
