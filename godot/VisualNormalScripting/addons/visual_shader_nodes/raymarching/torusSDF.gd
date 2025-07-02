# TorusSDFNode.gd
# Save as: res://addons/sdf_nodes/TorusSDFNode.gd
@tool
extends VisualShaderNodeCustom
class_name TorusSDFNode

func _get_name() -> String:
	return "TorusSDF"

func _get_category() -> String:
	return "SDF Objects"

func _get_description() -> String:
	return "Adds a torus to the SDF scene"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR_INT

func _get_input_port_count() -> int:
	return 5

func _get_input_port_name(port: int) -> String:
	match port:
		0: return "index_in"
		1: return "position"
		2: return "major_radius"
		3: return "minor_radius"
		4: return "enabled"
		_: return ""

func _get_input_port_type(port: int) -> int:
	match port:
		0: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_SCALAR
		3: return VisualShaderNode.PORT_TYPE_SCALAR
		4: return VisualShaderNode.PORT_TYPE_BOOLEAN
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "index_out"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR_INT

func _get_global_code(mode: Shader.Mode) -> String:
	return """
int addTorusNode(vec3 position, float majorRadius, float minorRadius, int inputIndex, bool enabled) {
	if (!enabled) {
		return inputIndex;
	}
	return inputIndex + 1;
}
"""

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	var index_in = input_vars[0] if input_vars[0] != "" else "0"
	var position = input_vars[1] if input_vars[1] != "" else "vec3(0.0)"
	var major_radius = input_vars[2] if input_vars[2] != "" else "1.0"
	var minor_radius = input_vars[3] if input_vars[3] != "" else "0.3"
	var enabled = input_vars[4] if input_vars[4] != "" else "true"
	return "%s = addTorusNode(%s, %s, %s, %s, %s);" % [output_vars[0], position, major_radius, minor_radius, index_in, enabled]