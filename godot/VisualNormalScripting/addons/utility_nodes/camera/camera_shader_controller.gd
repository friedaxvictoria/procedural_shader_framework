@tool
extends Camera3D
class_name CameraShaderController
#to pass uniform vriable values to the shader
@export var materials: Array[Material] = []
@export var camera_position_uniform: String = "u_camera_position"
@export var camera_direction_uniform: String = "u_camera_direction"

# global variable value to store the previous camera posn and location
var last_transform: Transform3D

func _ready():
    print("CameraShaderController created")
    #store previous camera posn, contains position and direction of camera
    last_transform = global_transform
    update_shader_uniforms()

func _enter_tree():
    print("CameraShaderController entered scene")

func _input(event):
    if event is InputEventMouseMotion:
        if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            var sensitivity = 0.02
            global_rotation_degrees.y -= event.relative.x * sensitivity
            global_rotation_degrees.x -= event.relative.y * sensitivity
            global_rotation_degrees.x = clamp(global_rotation_degrees.x, -90, 90)

func _process(_delta):
    var moved = false
    var movement_speed = 8.0
    
    if Input.is_action_pressed("ui_right"):
        global_position.x += movement_speed * _delta
        moved = true
    if Input.is_action_pressed("ui_left"):
        global_position.x -= movement_speed * _delta
        moved = true
    if Input.is_action_pressed("ui_up"):
        global_position.z -= movement_speed * _delta
        moved = true
    if Input.is_action_pressed("ui_down"):
        global_position.z += movement_speed * _delta
        moved = true
    
    if moved or global_transform != last_transform:
        update_shader_uniforms()
        last_transform = global_transform

func update_shader_uniforms():
    var camera_pos = global_position
    var camera_dir = -global_transform.basis.z
    
    for material in materials:
        if material is ShaderMaterial:
            var shader_material = material as ShaderMaterial
            shader_material.set_shader_parameter(camera_position_uniform, camera_pos)
            shader_material.set_shader_parameter(camera_direction_uniform, camera_dir)