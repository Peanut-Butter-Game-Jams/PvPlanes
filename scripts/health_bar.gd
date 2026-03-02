extends TextureProgressBar

@export var entity : Entity
@export var health_bar : bool
@export var shield_bar : bool

func _ready() -> void:
	value = 0

func _process(delta: float) -> void:
	if entity:
		if health_bar:
			value = entity.current_health
		elif entity.current_shield and shield_bar:
			value = entity.current_shield.health
	else:
		value = 0
