extends Node2D

var health_bars : Array
var shield_bars : Array
var boost_bars : Array
func _ready() -> void:
	health_bars = [$PlayerOne/HealthBar,$PlayerTwo/HealthBar,$PlayerThree/HealthBar,$PlayerFour/HealthBar]
	shield_bars = [$PlayerOne/ShieldBar,$PlayerTwo/ShieldBar,$PlayerThree/ShieldBar,$PlayerFour/ShieldBar]
	boost_bars = [$PlayerOne/BoostBar, $PlayerTwo/BoostBar, $PlayerThree/BoostBar, $PlayerFour/BoostBar]
	initialize()
	Manager.on_scene_ready()

func initialize() -> void:
	for i in range(Manager.players.size()):
		var player = Manager.players[i]
		if player:
			health_bars[i].entity = player
			shield_bars[i].entity = player
			boost_bars[i].entity = player
		else:
			health_bars[i].visible = false
			shield_bars[i].visible = false
			boost_bars[i].visible = false
