extends Node2D

@export var shader_material_target: CanvasItem
@export var max_objects := 10

# Struct-like object definition for input
class ShaderObject:
	var type: int
	var position: Vector3
	var size: Vector3
	var radius: float
	var color: Vector3

	func set_values(t, pos, sz, r, c) -> ShaderObject:
		type = t
		position = pos
		size = sz
		radius = r
		color = c
		return self
#============




#============
func _ready():
	var objects := [
		ShaderObject.new().set_values(0, Vector3(0.0, 0.0, 0.0), Vector3.ZERO, 1.0, Vector3(0.2, 0.2, 1.)),
		ShaderObject.new().set_values(1, Vector3(1.9,0.0,0.0), Vector3(1.0,1.0,1.0), 0.2, Vector3(0.2, 1., 0.2)),
		ShaderObject.new().set_values(1, Vector3(-1.9,0.0,0.0), Vector3(1.0,1.0,1.0), 0.2, Vector3(0.2, 1., 0.2)),
		ShaderObject.new().set_values(2, Vector3(0.0,0.0,0.0), Vector3(1.0,5.0,1.5), 0.2, Vector3(1., 0.2, 0.2))
	]

	fill_shader_parameters(objects)

func fill_shader_parameters(obj_list: Array):
	var mat := shader_material_target.material
	if mat == null or not mat is ShaderMaterial:
		push_error("No valid ShaderMaterial found on the CanvasItem!")
		return

	var count: int = min(obj_list.size(), max_objects)

	var types := PackedInt32Array()
	var positions := PackedVector3Array()
	var sizes := PackedVector3Array()
	var radii := PackedFloat32Array()
	var colors := PackedVector3Array()

	for i in range(count):
		var obj: ShaderObject = obj_list[i]
		types.append(obj.type)
		positions.append(obj.position)
		sizes.append(obj.size)
		radii.append(obj.radius)
		colors.append(obj.color)

	# Pad to max_objects
	while types.size() < max_objects:
		types.append(0)
		positions.append(Vector3.ZERO)
		sizes.append(Vector3.ZERO)
		radii.append(0.0)
		colors.append(Vector3.ZERO)

	mat.set_shader_parameter("obj_type", types)
	mat.set_shader_parameter("obj_position", positions)
	mat.set_shader_parameter("obj_size", sizes)
	mat.set_shader_parameter("obj_radius", radii)
	mat.set_shader_parameter("obj_color", colors)
	mat.set_shader_parameter("inputCount", count)
    mat.set_shader_parameter("obj_color_phnong", colors)
	# Set screen resolution (for canvas shaders)
	var resolution: Vector2 = get_viewport().get_visible_rect().size
	mat.set_shader_parameter("screen_resolution", resolution)

	print("Shader parameters updated with", count, "objects and resolution:", resolution)
