#include "res://addons/NodesOfVisualShader/global_variables.gdshaderinc"

@tool
extends VisualShaderNodeCustom
class_name AddSphereNode

# ======== VISUAL SHADER NODE DEFINITION ========


func _get_name() -> String:
	return "AddSphere"

func _get_category() -> String:
	return "SDF/myNodes"

func _get_description() -> String:
	return "Adds a sphere to the SDF scene and outputs index + 1"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR_INT

func _get_input_port_count() -> int:
	return 7

func _get_input_port_name(port: int) -> String:
	match port:
		0: return "index"
		1: return "position"
		2: return "radius"
		3: return "baseColor"
		4: return "specColor"
		5: return "specStrength"
		6: return "shininess"
		_: return ""

func _get_input_port_type(port: int) -> int:
	match port:
		0: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_SCALAR
		3: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		4: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		5: return VisualShaderNode.PORT_TYPE_SCALAR
		6: return VisualShaderNode.PORT_TYPE_SCALAR
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "index_out"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR_INT

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	var index     = input_vars[0] if input_vars[0] != "" else "0"
	var position  = input_vars[1] if input_vars[1] != "" else "vec3(0.0)"
	var radius    = input_vars[2] if input_vars[2] != "" else "1.0"
	var baseColor = input_vars[3] if input_vars[3] != "" else "vec3(1.0)"
	var specColor = input_vars[4] if input_vars[4] != "" else "vec3(1.0)"
	var specStr   = input_vars[5] if input_vars[5] != "" else "0.5"
	var shininess = input_vars[6] if input_vars[6] != "" else "32.0"

	return "%s = %s + 1;" % [output_vars[0], index]

# ======== RUNTIME LOGIC TO UPDATE UNIFORMS ========

func add_sphere_to_shader_material(
	material: ShaderMaterial,
	index: int,
	position: Vector3,
	radius: float,
	base_color: Vector3,
	spec_color: Vector3,
	spec_strength: float,
	shininess: float,
	max_objects: int = 10
) -> int:
	if material == null or not material is ShaderMaterial:
		push_error("Invalid ShaderMaterial passed to add_sphere_to_shader_material()")
		return index

	# Geometry arrays
	var sdf_type := material.get_shader_parameter("obj_type")
	var sdf_position := material.get_shader_parameter("obj_position")
	var sdf_size := material.get_shader_parameter("obj_size")
	var sdf_radius := material.get_shader_parameter("obj_radius")

	# Material arrays
	var base_colors := material.get_shader_parameter("u_baseColorFloat")
	var spec_colors := material.get_shader_parameter("u_specularColorFloat")
	var spec_strengths := material.get_shader_parameter("u_specularStrengthFloat")
	var shininesses := material.get_shader_parameter("u_shininessFloat")

	# Pad arrays
	while sdf_type.size() < max_objects:
		sdf_type.append(0)
		sdf_position.append(Vector3.ZERO)
		sdf_size.append(Vector3.ZERO)
		sdf_radius.append(0.0)

		base_colors.append(Vector3.ONE)
		spec_colors.append(Vector3.ONE)
		spec_strengths.append(0.0)
		shininesses.append(1.0)

	# Set values
	sdf_type[index] = 0  # 0 = sphere
	sdf_position[index] = position
	sdf_size[index] = Vector3.ZERO
	sdf_radius[index] = radius

	base_colors[index] = base_color
	spec_colors[index] = spec_color
	spec_strengths[index] = spec_strength
	shininesses[index] = shininess

	# Push back
	material.set_shader_parameter("obj_type", sdf_type)
	material.set_shader_parameter("obj_position", sdf_position)
	material.set_shader_parameter("obj_size", sdf_size)
	material.set_shader_parameter("obj_radius", sdf_radius)

	material.set_shader_parameter("u_baseColorFloat", base_colors)
	material.set_shader_parameter("u_specularColorFloat", spec_colors)
	material.set_shader_parameter("u_specularStrengthFloat", spec_strengths)
	material.set_shader_parameter("u_shininessFloat", shininesses)

	return index + 1
