class_name ShieldUpgradeStrategy
extends BaseUpgradeStrategy

@export var shield_value := 25

func _ready() -> void:
	isPlayerUpgrade = true;

func apply_upgrade_to_player(player: CharacterBody2D):
	player.add_shield()
	
func apply_upgrade_to_projectile(bullet: Bullet):
	pass
