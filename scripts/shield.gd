extends Area2D

@onready var shield_sprite: Sprite2D = $Sprite2D
var health = 100

func _process(delta: float) -> void:
	shield_sprite.modulate.a = health / 200.00
	
	if health <= 0:
		queue_free()

func apply_damage(damage : int) -> int:
	health -= damage
	
	# shield was destroyed, return remaining damage
	if health < 0:
		return health
	else:
		return 0
