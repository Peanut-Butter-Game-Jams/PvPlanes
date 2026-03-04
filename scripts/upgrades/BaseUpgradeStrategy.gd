@abstract class_name BaseUpgradeStrategy extends Resource

# Sprite variable
@export var texture : Texture2D = preload("res://sprites/upgrades/BlankUpgrade.png")
@export var upgrade_text : String = "Upgrade"
@export var isPlayerUpgrade : bool = false

@abstract
func apply_upgrade_to_player(player: CharacterBody2D)

@abstract	
func apply_upgrade_to_projectile(bullet: Bullet)
