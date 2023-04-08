extends Control

@onready var debug_overlay_list = $DebugItemList

func _ready() -> void:
#	Helper.Log("[color=yellow]Gui[/color]", "ready")
	$DebugItemList.hide()
	$Announcer.add_to_group("Announcements")


func _process(_delta: float) -> void:
	if is_instance_valid($DebugItemList) and $DebugItemList.visible:
		$DebugItemList.clear()
		$DebugItemList.add_item("fps: " + str(Performance.get_monitor(Performance.TIME_FPS)), null, false)
		$DebugItemList.add_item("id: " + str(Network.local_player_id), null, false)
		$DebugItemList.add_item("isServer: " + str(Network.local_player_id == 1), null, false)

func _input(event):
	if event.is_action_released("console") and $DebugItemList != null:
		$DebugItemList.visible = !$DebugItemList.visible
