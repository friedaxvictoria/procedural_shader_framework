@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeTimeInput

func _get_name():
    return "TimeInput"

func _get_category():
    return "Input/Time"

func _get_description():
    return "Provides time data for animations and effects"

func _get_return_icon_type():
    return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
    return 2

func _get_input_port_name(port):
    match port:
        0:
            return "time_scale"
        1:
            return "frequency"

func _get_input_port_type(port):
    match port:
        0:
            return VisualShaderNode.PORT_TYPE_SCALAR
        1:
            return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
    return 6

func _get_output_port_name(port):
    match port:
        0:
            return "time"
        1:
            return "scaled_time"  
        2:
            return "delta_time"
        3:
            return "pulse"
        4:
            return "triangle_wave"
        5:
            return "sawtooth_wave"

func _get_output_port_type(port):
    return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
    return '#include "res://addons/includes/time/time_input.gdshaderinc"'

func _get_code(input_vars, output_vars, mode, type):
    var time_scale = input_vars[0] if input_vars[0] != "" else "1.0"
    var frequency = input_vars[1] if input_vars[1] != "" else "1.0"
    
    return """
%s = TIME;
%s = TIME * %s;
%s = get_delta_time();
%s = sin(TIME * %s) * 0.5 + 0.5;
%s = abs(mod(TIME * %s, 2.0) - 1.0);
%s = mod(TIME * %s, 1.0);
""" % [output_vars[0], output_vars[1], time_scale, output_vars[2], 
       output_vars[3], frequency, output_vars[4], frequency, output_vars[5], frequency]