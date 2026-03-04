class_name DamageUpgradeStrategy
extends BaseUpgradeStrategy

@export var damage_increase := 5

func _ready() -> void:
	isPlayerUpgrade = false;

func apply_upgrade_to_player(player: CharacterBody2D):
	pass
	
func apply_upgrade_to_projectile(bullet: Bullet):
	bullet.damage += damage_increase
