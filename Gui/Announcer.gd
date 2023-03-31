extends CenterContainer

func money_stashed(player, money):
	rpc("announce_money_stashed", player, money)
	
@rpc("any_peer","call_local","reliable")
func announce_money_stashed(player, money):
	$Label.text = " § " + str(money) + " has stashed by " + player + " "
	$AnimationPlayer.play("Announcement")

func announce_crime(location):
	var x = snapped(location.x, 1) 
	var z = snapped(location.z, 1)
	$Label.text = "Crime in progress at " + str(x) + ", " + str(z)
	$AnimationPlayer.play("Announcement")
	get_tree().call_group("Arrow", "new_destination", location)
