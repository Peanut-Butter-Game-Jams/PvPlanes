####
# Projectile.gd
# 
# Idea: Piercing bullets
####

extends Area2D
class_name Bullet

@export var speed: float = 10.0 # pixels/sec
@export var max_lifetime: float = 1 #seconds
@export var damage: int = 1

var _velocity: Vector2 = Vector2.ZERO
var _lifetime: float = 0.0
var _shooter_id: int = -1

func fire(new_position: Vector2, target_rotation: float, shooter_id: int = -1, speed_override: float = -1.0):
	global_position = new_position
	rotation = target_rotation
	var direction = Vector2.RIGHT.rotated(rotation)
	
	_velocity = direction * (speed if speed_override == -1 else speed_override)
	_lifetime = 0.0
	_shooter_id = shooter_id

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		return
	
	# TODO: Account for tunneling.
	
	position += _velocity * delta
	
	_lifetime += delta * 2
	
	if _lifetime >= max_lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	_apply_hit(body, global_position)

func _apply_hit(body: Node, new_position: Vector2) -> void:
	# Don't hit yourself.
	if body.get_instance_id() == _shooter_id:
		return
	
	if body is CharacterBody2D:
		body.apply_damage(damage) 
	
	# Play effects
	_run_hit_effects(new_position)

func _run_hit_effects(new_position: Vector2) -> void:
	queue_free()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
