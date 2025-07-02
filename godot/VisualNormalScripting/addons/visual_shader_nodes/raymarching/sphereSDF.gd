# SphereSDFNode.gd
# Save as: res://addons/sdf_nodes/SphereSDFNode.gd
@tool
extends VisualShaderNodeCustom
class_name SphereSDFNode

func _get_name() -> String:
	return "SphereSDF"

func _get_category() -> String:
	return "SDF Objects"

func _get_description() -> String:
	return "Adds a sphere to the SDF scene"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR_INT

func _get_input_port_count() -> int:
	return 4

func _get_input_port_name(port: int) -> String:
	match port:
		0: return "index_in"
		1: return "position"
		2: return "radius"
		3: return "enabled"
		_: return ""

func _get_input_port_type(port: int) -> int:
	match port:
		0: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_SCALAR
		3: return VisualShaderNode.PORT_TYPE_BOOLEAN
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "index_out"

func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR_INT

func _get_global_code(mode: Shader.Mode) -> String:
	return """
int addSphereNode(vec3 position, float radius, int inputIndex, bool enabled) {
	if (!enabled) {
		return inputIndex;
	}
	return inputIndex + 1;
}
"""

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	var index_in = input_vars[0] if input_vars[0] != "" else "0"
	var position = input_vars[1] if input_vars[1] != "" else "vec3(0.0)"
	var radius = input_vars[2] if input_vars[2] != "" else "1.0"
	var enabled = input_vars[3] if input_vars[3] != "" else "true"
	return "%s = addSphereNode(%s, %s, %s, %s);" % [output_vars[0], position, radius, index_in, enabled]