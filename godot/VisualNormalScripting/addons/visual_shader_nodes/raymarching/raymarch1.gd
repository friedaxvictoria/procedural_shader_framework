# RaymarchDynamicNode.gd
# Save this file as: res://addons/sdf_nodes/RaymarchDynamicNode.gd
@tool
extends VisualShaderNodeCustom
class_name RaymarchDynamicNode

func _get_name() -> String:
	return "Raymarch1"

func _get_category() -> String:
	return "MyShaderNodes"

func _get_description() -> String:
	return "Core raymarching function - takes object count for precise control"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count() -> int:
	return 3

func _get_input_port_name(port: int) -> String:
	match port:
		0: return "ray_origin"
		1: return "ray_direction"
		2: return "object_count"
		_: return ""

func _get_input_port_type(port: int) -> int:
	match port:
		0: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 3

func _get_output_port_name(port: int) -> String:
	match port:
		0: return "hit_distance"
		1: return "hit_position"
		2: return "hit_id"
		_: return ""

func _get_output_port_type(port: int) -> int:
	match port:
		0: return VisualShaderNode.PORT_TYPE_SCALAR
		1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode: Shader.Mode) -> String:
	return """
void callRaymarchDynamic(
	vec3 rayOrigin,
	vec3 rayDirection,
	int objectCount,
	out float hitDistance,
	out vec3 hitPosition,
	out int hitID
) {
	// Set the active count for this specific raymarch
	active_sdf_count = objectCount;
	hitDistance = raymarchDynamic(rayOrigin, rayDirection, hitPosition, hitID);
}
"""

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	var ray_origin = input_vars[0] if input_vars[0] != "" else "vec3(0.0, 0.0, 7.0)"
	var ray_direction = input_vars[1] if input_vars[1] != "" else "vec3(0.0, 0.0, -1.0)"
	var object_count = input_vars[2] if input_vars[2] != "" else "0"
	
	return "callRaymarchDynamic(%s, %s, %s, %s, %s, %s);" % [
		ray_origin,
		ray_direction,
		object_count,
		output_vars[0],  # hit_distance
		output_vars[1],  # hit_position
		output_vars[2]   # hit_id
	]