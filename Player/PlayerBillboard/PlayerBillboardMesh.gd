extends MeshInstance3D

func _ready() -> void:
	var viewport_texture = $"../PlayerBillboardSubViewport".get_texture()
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = viewport_texture
	material.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	set_material_override(material)

