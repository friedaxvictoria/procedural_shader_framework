# SetMaterialParamsNode.gd

#include "res://addons/NodesOfVisualShader/global_variables.gdshaderinc"

@tool
extends VisualShaderNodeCustom
class_name SetMaterialParamsNode

# ======== VISUAL SHADER NODE DEFINITION ========

func _get_name() -> String:
	return "SetMaterialParams"

func _get_category() -> String:
	return "SDF/myNodes"

func _get_description() -> String:
	return "Sets material parameters at runtime and outputs index + 1"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR_INT

func _get_input_port_count() -> int:
	return 5

func _get_input_port_name(port: int) -> String:
	match port:
		0: return "index"
		1: return "baseColor"
		2: return "specColor"
		3: return "specStrength"
		4: return "shininess"
		_: return ""

func _get_input_port_type(port: int) -> int:
	match port:
		0: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		3: return VisualShaderNode.PORT_TYPE_SCALAR
		4: return VisualShaderNode.PORT_TYPE_SCALAR
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "index_out"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR_INT

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	var index = input_vars[0] if input_vars[0] != "" else "0"
	return "%s = %s + 1;" % [output_vars[0], index]

# ======== RUNTIME LOGIC TO UPDATE UNIFORMS ========

func apply_to_shader_material(
	material: ShaderMaterial,
	index: int,
	base_color: Vector3,
	spec_color: Vector3,
	spec_strength: float,
	shininess: float,
	max_objects: int = 10
) -> int:
	if material == null or not material is ShaderMaterial:
		push_error("Invalid ShaderMaterial passed to apply_to_shader_material()")
		return index

	var base_colors := material.get_shader_parameter("u_baseColorFloat")
	var spec_colors := material.get_shader_parameter("u_specularColorFloat")
	var spec_strengths := material.get_shader_parameter("u_specularStrengthFloat")
	var shininesses := material.get_shader_parameter("u_shininessFloat")

	# Pad arrays if needed
	while base_colors.size() < max_objects:
		base_colors.append(Vector3.ONE)
		spec_colors.append(Vector3.ONE)
		spec_strengths.append(0.0)
		shininesses.append(1.0)

	# Set values at index
	if index >= 0 and index < max_objects:
		base_colors[index] = base_color
		spec_colors[index] = spec_color
		spec_strengths[index] = spec_strength
		shininesses[index] = shininess

	# Push back into shader
	material.set_shader_parameter("u_baseColorFloat", base_colors)
	material.set_shader_parameter("u_specularColorFloat", spec_colors)
	material.set_shader_parameter("u_specularStrengthFloat", spec_strengths)
	material.set_shader_parameter("u_shininessFloat", shininesses)

	return index + 1
