extends Node2D

@export var shader_material_target: CanvasItem
@export var MAX_OBJECTS := 10

class ShaderObject:
	var type: int
	var position: Vector3
	var size: Vector3
	var radius: float
	var color: Vector3
	var specular_color: Vector3 = Vector3.ONE
	var specular_strength: float = 0.5
	var shininess: float = 32.0

	func set_values(t, pos, sz, r, c, spec_col := Vector3.ONE, spec_str := 1.0, shin := 32.0) -> ShaderObject:
		type = t
		position = pos
		size = sz
		radius = r
		color = c
		specular_color = spec_col
		specular_strength = spec_str
		shininess = shin
		return self

func _ready():
	var objects := [
		ShaderObject.new().set_values(0, Vector3(0, 0, 0), Vector3.ZERO, 1.0, Vector3(0.2, 0.2, 1.0)),
		ShaderObject.new().set_values(1, Vector3(1.9, 0, 0), Vector3(1, 1, 1), 0.2, Vector3(0.2, 1.0, 0.2)),
		ShaderObject.new().set_values(1, Vector3(-1.9, 0, 0), Vector3(1, 1, 1), 0.2, Vector3(0.2, 1.0, 0.2)),
		ShaderObject.new().set_values(2, Vector3(0, 0, 0), Vector3(1, 5, 1.5), 0.2, Vector3(1.0, 0.2, 0.2))
	]

	fill_shader_parameters(objects)

func _process(delta):
	update_camera_from_mouse()

func fill_shader_parameters(obj_list: Array):
	var mat := shader_material_target.material
	if mat == null or not mat is ShaderMaterial:
		push_error("No valid ShaderMaterial found on the CanvasItem!")
		return

	var count: int = min(obj_list.size(), MAX_OBJECTS)

	var types := PackedInt32Array()
	var positions := PackedVector3Array()
	var sizes := PackedVector3Array()
	var radii := PackedFloat32Array()
	var colors := PackedVector3Array()
	var specular_colors := PackedVector3Array()
	var specular_strengths := PackedFloat32Array()
	var shininesses := PackedFloat32Array()

	for obj in obj_list:
		types.append(obj.type)
		positions.append(obj.position)
		sizes.append(obj.size)
		radii.append(obj.radius)
		colors.append(obj.color)
		specular_colors.append(obj.specular_color)
		specular_strengths.append(obj.specular_strength)
		shininesses.append(obj.shininess)

	# Pad arrays
	while types.size() < MAX_OBJECTS:
		types.append(0)
		positions.append(Vector3.ZERO)
		sizes.append(Vector3.ZERO)
		radii.append(0.0)
		colors.append(Vector3.ZERO)
		specular_colors.append(Vector3.ONE)
		specular_strengths.append(0.0)
		shininesses.append(1.0)

	mat.set_shader_parameter("obj_type", types)
	mat.set_shader_parameter("obj_position", positions)
	mat.set_shader_parameter("obj_size", sizes)
	mat.set_shader_parameter("obj_radius", radii)
	mat.set_shader_parameter("obj_color", colors)
	mat.set_shader_parameter("specularColorFloat", specular_colors)
	mat.set_shader_parameter("specularStrengthFloat", specular_strengths)
	mat.set_shader_parameter("shininessFloat", shininesses)
	mat.set_shader_parameter("inputCount", count)

	var resolution: Vector2 = get_viewport().get_visible_rect().size
	mat.set_shader_parameter("screen_resolution", resolution)

	print("Shader parameters updated with", count, "objects and resolution:", resolution)

func update_camera_from_mouse():
	var mat := shader_material_target.material
	if mat == null or not mat is ShaderMaterial:
		return

	var screen_size := get_viewport().get_visible_rect().size
	var mouse_pos := get_viewport().get_mouse_position()

	var x_angle = (mouse_pos.x / screen_size.x - 0.5) * TAU      # Horizontal angle
	var y_angle = clamp((mouse_pos.y / screen_size.y - 0.5) * PI, -PI * 0.4, PI * 0.4)  # Vertical angle

	var radius = 6.0
	var cam_x = radius * cos(y_angle) * sin(x_angle)
	var cam_y = radius * sin(y_angle)
	var cam_z = radius * cos(y_angle) * cos(x_angle)

	var cam_pos = Vector3(cam_x, cam_y, cam_z)
	var look_at = Vector3(0, 0, 7)

	mat.set_shader_parameter("camera_position", cam_pos)
	mat.set_shader_parameter("look_at_position", look_at)
