extends GPUParticles3D

const MAX_LIFETIME = 1.5

func _ready() -> void:
	manage_particles(Save.save_data["particles"])
	
func update_particles(speed):
	lifetime = clamp(speed *0.1, 0.01, MAX_LIFETIME)

func manage_particles(value):
	match value:
		0: emitting = false
		1: 
			emitting = true
			amount = 64
		2: 
			emitting = true
			amount = 128

