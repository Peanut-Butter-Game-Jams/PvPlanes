extends Node2D

var health_bars : Array
var shield_bars : Array

func _ready() -> void:
	health_bars = [$PlayerOne/HealthBar,$PlayerTwo/HealthBar,$PlayerThree/HealthBar,$PlayerFour/HealthBar]
	shield_bars = [$PlayerOne/ShieldBar,$PlayerTwo/ShieldBar,$PlayerThree/ShieldBar,$PlayerFour/ShieldBar]
	initialize()
	Manager.on_scene_ready()

func initialize() -> void:
	for i in range(Manager.players.size()):
		if Manager.players[i]:
			health_bars[i].entity = Manager.players[i]
			shield_bars[i].entity = Manager.players[i]
		else:
			health_bars[i].visible = false
			shield_bars[i].visible = false
