extends "res://Beacon/Beacon.gd"


func _ready() -> void:
	super()
	print(wait)
	show()
	
func _on_timer_timeout() -> void:
	player.money_delivered()
