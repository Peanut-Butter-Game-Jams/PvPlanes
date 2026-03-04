class_name HealthUpgradeStrategy
extends BaseUpgradeStrategy

@export var min_health_to_add : float = 15.0
@export var max_health_to_add : float = 30.0

func _ready() -> void:
	isPlayerUpgrade = true;

func apply_upgrade_to_player(player: CharacterBody2D):
	var health_to_add = randf_range(min_health_to_add, max_health_to_add)
	player.add_health(health_to_add)
	
func apply_upgrade_to_projectile(bullet: Bullet):
	pass
