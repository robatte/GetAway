extends VehicleBody3D

var money = 0
const money_drop = 50 
const beacon_money = 1000

@export var max_arrest_value = 150

var arrest_value = 0

var criminal_detected = false

var siren = false
var horn = false


#var players = {}
#var player_data = {"steer": 0, "engine": 0, "brakes": 0, 
#					"position": null, "speed": 0, "money": 0, "siren": false, "horn": false}
@onready var input = $PlayerInputSynchronizer
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInputSynchronizer.set_multiplayer_authority(id)

@export var speed = 0.0
@export var steering_value = 0.0
@export var engine = 0.0
		
func is_local_player():
	return get_multiplayer_authority() == multiplayer.get_unique_id()

func _ready():
	if player == multiplayer.get_unique_id():
		$Camera.current = true
		
func _physics_process(delta):
	
	if is_local_player():		
		steering_value = input.steering_value
		engine = input.engine
		brake = input.brakes
		
	steering = steering_value
	engine_force = engine
	brake = brake
		



func _on_body_entered(body: Node) -> void:
	pass

