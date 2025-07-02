@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeCameraInput

func _get_name():
    return "CameraInput"

func _get_category():
    return "Input/Camera"

func _get_description():
    return "Provides camera data from CameraShaderController"

func _get_return_icon_type():
    return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _get_input_port_count():
    return 0  # No inputs - this is a pure input node

func _get_output_port_count():
    return 4

func _get_output_port_name(port):
    match port:
        0:
            return "position"
        1:
            return "direction"
        2:
            return "forward"
        3:
            return "distance_from_origin"

func _get_output_port_type(port):
    match port:
        0:
            return VisualShaderNode.PORT_TYPE_VECTOR_3D
        1:
            return VisualShaderNode.PORT_TYPE_VECTOR_3D
        2:
            return VisualShaderNode.PORT_TYPE_VECTOR_3D
        3:
            return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
    return '#include "res://addons/includes/camera/camera_input.gdshaderinc"'

func _get_code(input_vars, output_vars, mode, type):
    return """
%s = get_camera_position();
%s = get_camera_direction();
%s = get_camera_forward();
%s = length(get_camera_position());
""" % [output_vars[0], output_vars[1], output_vars[2], output_vars[3]]