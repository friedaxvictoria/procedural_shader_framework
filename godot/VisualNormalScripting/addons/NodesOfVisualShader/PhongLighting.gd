@tool
extends VisualShaderNodeCustom
class_name ApplyPhongLightingNode

var GLOBALS_SHADER_CODE := ""

func _init():
	var file = FileAccess.open("res://addons/NodesOfVisualShader/global_variables.gdshaderinc", FileAccess.READ)
	if file:
		GLOBALS_SHADER_CODE = file.get_as_text()
	else:
		push_error("Could not load global_variables.gdshaderinc")

func _get_name() -> String:
	return "ApplyPhongLighting"

func _get_category() -> String:
	return "SDF/myNodes"

func _get_description() -> String:
	return "Applies Phong lighting using SDF material arrays and hit object ID"

func _get_return_icon_type() -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_input_port_count() -> int:
	return 4  # hitPos, lightPos, normal, hitID

func _get_input_port_name(port: int) -> String:
	match port:
		0: return "hitPos"
		1: return "lightPos"
		2: return "normal"
		3: return "hitID"
		_: return ""

func _get_input_port_type(port: int) -> int:
	match port:
		0, 1, 2: return VisualShaderNode.PORT_TYPE_VECTOR_3D
		3: return VisualShaderNode.PORT_TYPE_SCALAR_INT
		_: return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return "lightingColor"


func _get_output_port_type(port: int) -> int:
	return VisualShaderNode.PORT_TYPE_VECTOR_4D

func _get_global_code(mode: Shader.Mode) -> String:
	return """
// Lighting Helpers
void lightingContext(vec3 hitPos, vec3 lightPos, out vec3 viewDir, out vec3 lightDir, out vec3 lightColor, out vec3 ambientColor) {
	vec3 ro = vec3(0.0, 0.0, 7.0); // Static camera
	viewDir = normalize(ro - hitPos);
	lightDir = normalize(lightPos - hitPos);
	lightColor = vec3(1.0);
	ambientColor = vec3(0.1);
}

void applyPhongLighting_float(vec3 hitPos, vec3 lightPosition, vec3 normal, int hitID, out vec3 lightingColor) {
	vec3 viewDir, lightDir, lightColor, ambientColor;
	lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);

	float diff = max(dot(normal, lightDir), 0.0);
	vec3 R = reflect(-lightDir, normal);
	float spec = pow(max(dot(R, viewDir), 0.0), u_shininessFloat[hitID]);

	vec3 colour = u_baseColorFloat[hitID];
	vec3 diffuse = diff * colour * lightColor;
	vec3 specular = spec * u_specularColorFloat[hitID] * u_specularStrengthFloat[hitID];

	lightingColor = ambientColor + diffuse + specular;

	if (hitPos.z == 0.0) {
		lightingColor = vec3(0.0);
	}
}
"""

func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	var hit_pos   = input_vars[0] if input_vars[0] != "" else "vec3(0.0)"
	var light_pos = input_vars[1] if input_vars[1] != "" else "vec3(0.0)"
	var normal    = input_vars[2] if input_vars[2] != "" else "vec3(0.0)"
	var hit_id    = input_vars[3] if input_vars[3] != "" else "0"

	return """
	vec3 tempColor = vec3(0.0);
	applyPhongLighting_float(%s, %s, %s, %s, tempColor);
	%s = vec4(tempColor, 1.0);
	""" % [hit_pos, light_pos, normal, hit_id, output_vars[0]

]
