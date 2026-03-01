class_name HealthUpgradeStrategy
extends BaseUpgradeStrategy

@export var health_value := .5

func _ready() -> void:
	isPlayerUpgrade = true;

func apply_upgrade_to_player(player: CharacterBody2D):
	player.add_health(floor(player.max_health * health_value))
	
func apply_upgrade_to_projectile(bullet: Bullet):
	pass
