class_name RangeUpgradeStrategy
extends BaseUpgradeStrategy

@export var speed_increase : float = 100.0

func _ready() -> void:
	isPlayerUpgrade = false;

func apply_upgrade_to_player(player: CharacterBody2D):
	pass

func apply_upgrade_to_projectile(bullet: Bullet):
	bullet.speed += speed_increase
