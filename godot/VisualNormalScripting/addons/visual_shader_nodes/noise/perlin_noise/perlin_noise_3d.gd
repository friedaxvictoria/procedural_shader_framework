# perlin_noise_3d.gd
@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodePerlinNoise3D


func _get_name():
	return "PerlinNoise3D"


func _get_category():
	return "MyShaderNodes"


func _get_description():
	return "Classic Perlin-Noise-3D function (by Curly-Brace)"


func _init():
	set_input_port_default_value(2, 0.0)


func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR


func _get_input_port_count():
	return 4


func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "offset"
		2:
			return "scale"
		3:
			return "time"


func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR_3D
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR


func _get_output_port_count():
	return 1


func _get_output_port_name(port):
	return "result"


func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
    
	return '#include "res://addons/includes/noise/perlin_noise/perlin_noise_3d.gdshaderinc"'
func _get_code(input_vars, output_vars, mode, type):
	return output_vars[0] + " = cnoise(vec3((%s.xy + %s.xy) * %s, %s)) * 0.5 + 0.5;" % [input_vars[0], input_vars[1], input_vars[2], input_vars[3]]