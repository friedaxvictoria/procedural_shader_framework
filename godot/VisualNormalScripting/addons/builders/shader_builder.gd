# ShaderBuilder.gd
@tool
extends Node


const INCLUDES := [
	"res://addons/procedural_shaders/includes/noise/perlin_3d.gdshaderinc"
	
]

# Generates the shader code string with includes and base logic
func build_shader_code() -> String:
	var shader_code = ""
	for path in INCLUDES:
		shader_code += '#include "%s"\n' % path

	# Append basic shader structure
	shader_code += """
		void fragment() {
			// Example usage of included functions
			COLOR = vec4(1.0);
		}
	"""
	return shader_code

# Applies the built shader to a ShaderMaterial
func apply_shader_to_material(material: ShaderMaterial) -> void:
	if not material:
		push_error("No ShaderMaterial provided.")
		return

	var shader = Shader.new()
	shader.code = build_shader_code()
	material.shader = shader
