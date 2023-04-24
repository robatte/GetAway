extends ItemList


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear()

func console_log(txt):
	add_item(txt)
