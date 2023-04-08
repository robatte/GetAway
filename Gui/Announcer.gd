extends CenterContainer
@onready var label = $Label

func announce():
	$AnimationPlayer.stop(true)
	$AnimationPlayer.play("Announcement")

func money_stashed(player, money):
	rpc("announce_money_stashed", player, money)
	
@rpc("any_peer", "call_local", "reliable")
func announce_money_stashed(player, money):
	label.text = " § " + str(money) + " has stashed by " + player + " "
	announce()

@rpc("any_peer", "call_local", "reliable")
func announce_crime(location):
	var x = snapped(location.x, 1) 
	var z = snapped(location.z, 1)
	label.text = "Crime in progress at " + str(x) + ", " + str(z)
	announce()
	get_tree().call_group("Arrow", "new_destination", location)

func victory(criminals_win):
	Helper.Log("Announcer", "Victory")
	rpc("announce_victory", criminals_win)
	
@rpc("any_peer", "call_local", "reliable")
func announce_victory(criminals_win):
	if criminals_win:
		label.text = "Ha! The Criminals won! Crime Pays."
	else:
		label.text = "Cops win! Order is restored."
	announce()
	pass	
