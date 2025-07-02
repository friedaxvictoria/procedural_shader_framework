@tool
extends VisualShaderNodeCustom
class_name SDFRaymarchNode

var GLOBALS_SHADER_CODE := ""

func _init():
	var file = FileAccess.open("res://addons/NodesOfVisualShader/global_variables.gdshaderinc", FileAccess.READ)
	if file:
		GLOBALS_SHADER_CODE = file.get_as_text()
	else:
		push_error("Could not load global_variables.gdshaderinc")

func _get_name() -> String:
	return "SDFRaymarch"

func _get_category() -> String:
	return "SDF/myNodes"

func _get_description() -> String:
	return "Raymarches through SDF objects and outputs hit position, normal, and hitID"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_input_port_count() -> int:
	return 2

func _get_input_port_name(port: int) -> String:
	match port:
		0: return "numSDF"
		1: return "uv"
		_: return ""

func _get_input_port_type(port: int) -> int:
	match port:
		0: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		1: return VisualShaderNode.PORT_TYPE_VECTOR_2D
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 3

func _get_output_port_name(port: int) -> String:
	return ["hitPos", "normal", "hitID"][port]

func _get_output_port_type(port: int) -> int:
	match port:
		0, 1: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode: Shader.Mode) -> String:
	return GLOBALS_SHADER_CODE +"""
float sdSphere(vec3 p, float radius) {
	return length(p) - radius;
}

float sdRoundBox(vec3 p, vec3 b, float r) {
	vec3 q = abs(p) - b + r;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdTorus(vec3 p, vec2 radius) {
	vec2 q = vec2(length(p.xy) - radius.x, p.z);
	return length(q) - radius.y;
}

float evalSDF(int i, vec3 p) {
	int t = int(obj_type[i]);
	float dist = 1e5;
	if (t == 0)
		dist = sdSphere(p - obj_position[i], obj_radius[i]);
	else if (t == 1)
		dist = sdRoundBox(p - obj_position[i], obj_size[i], obj_radius[i]);
	else if (t == 2)
		dist = sdTorus(p - obj_position[i], obj_size[i].yz);
	return dist;
}

vec3 get_normal(int i, vec3 p) {
	float h = 0.0001;
	vec2 k = vec2(1.0, -1.0);
	return normalize(
		k.xyy * evalSDF(i, p + k.xyy * h) +
		k.yyx * evalSDF(i, p + k.yyx * h) +
		k.yxy * evalSDF(i, p + k.yxy * h) +
		k.xxx * evalSDF(i, p + k.xxx * h)
	);
}
"""

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	var numSDF = input_vars[0] if input_vars[0] != "" else "0"
	var uv = input_vars[1] if input_vars[1] != "" else "vec2(0.0)"
	var out_hitPos = output_vars[0]
	var out_normal = output_vars[1]
	var out_hitID = output_vars[2]

	return """
vec3 ro = vec3(0.0, 0.0, 7.0);
vec3 rd = normalize(vec3(%s, -1.0));

float t = 0.0;
vec3 p = vec3(0.0);
int bestID = -1;
%s = vec3(0.0);
%s = -1;

for (int i = 0; i < 100; i++) {
	p = ro + rd * t;
	float d = 1e5;
	for (int j = 0; j < %s; ++j) {
		float dj = evalSDF(j, p);
		if (dj < d) {
			d = dj;
			bestID = j;
		}
	}
	if (d < 0.001) {
		%s = p;
		%s = get_normal(bestID, p);
		%s = bestID;
		break;
	}
	if (t > 50.0) break;
	t += d;
}
""" % [uv, out_hitPos, out_hitID, numSDF, out_hitPos, out_normal, out_hitID]
