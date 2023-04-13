extends Control

@onready var debug_overlay_list = $DebugItemList
@onready var notifications = $Notifications

func _ready() -> void:
#	Helper.Log("[color=yellow]Gui[/color]", "ready")
	$DebugItemList.hide()
	$Announcer.add_to_group("Announcements")
	add_to_group("Notifications")
	show_fps()

func _process(_delta: float) -> void:
	if is_instance_valid($DebugItemList) and $DebugItemList.visible:
		$DebugItemList.clear()
		$DebugItemList.add_item("fps: " + str(Performance.get_monitor(Performance.TIME_FPS)), null, false)
		$DebugItemList.add_item("id: " + str(Network.local_player_id), null, false)
		$DebugItemList.add_item("isServer: " + str(Network.local_player_id == 1), null, false)

func _input(event):
	if event.is_action_released("console") and $DebugItemList != null:
		$DebugItemList.visible = !$DebugItemList.visible
	elif event.is_action_released("debug"):
		var text = "lalaslsla "
		for n in range(randi() % 10): text += "mehr text "
		notify(text)


func show_fps():
	if Save.save_data["show_fps"]:
		$Hud/ColorRect/VBoxContainer/FpsOverlay.visible = true
		$FpsTmer.start()
	else:
		$Hud/ColorRect/VBoxContainer/FpsOverlay.visible = false
		$FpsTmer.start()

func _on_fps_tmer_timeout() -> void:
	$Hud/ColorRect/VBoxContainer/FpsOverlay.text = str(Performance.get_monitor(Performance.TIME_FPS)) + "fps"

func notify(text: String, time = 6):
	var note = Label.new()
	note.text = text
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_stylebox_override("normal", preload("res://Gui/button-stylet.tres"))
	notifications.add_child(note)
	await get_tree().create_timer(maxi(time - 0.5, 1), false).timeout
	await create_tween().tween_property(note, "self_modulate:a", 0, 0.5).set_trans(Tween.TRANS_EXPO).finished
	notifications.remove_child(note)
	note.queue_free()
