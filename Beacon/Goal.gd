extends "res://Beacon/Beacon.gd"


func _ready() -> void:
	super()
	show()
	
func _on_timer_timeout() -> void:
	print("Goal beacon finished. " + str(player) + " money: " + str(player.money))
	player.money_delivered()
	player = null
