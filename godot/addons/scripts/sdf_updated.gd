extends Node2D

@export var shader_material_target: CanvasItem
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY) 
var MAX_OBJECTS: int = 25
@export var lightPosition: Vector3 = Vector3(0.0, 4.0, 7.0)
@export var cameraPosition: Vector3 = Vector3(0.0, 13.0 , 13.0)
@export var camera_mode1: CameraMode1 = CameraMode1.AUTO_ORBIT
@export var camera_mode2: CameraMode2 = CameraMode2.BACKANDFORTH
@export var shake_speed: float = 0.5
@export var shake_intensity: float = 3.0
@export var orbit_speed: float = 0.5
@export var orbit_axis: Vector3 = Vector3.UP
@export var movement_speed: float = 0.5
@export var terrain_mode: TerrainMode = TerrainMode.NONE
@export var color_mode: ColorMode=ColorMode.STATIC
@export var cycle_speed: float = 0.5
@export var wave_speed: float = 0.5
@export var animation_mode: AnimationMode=AnimationMode.NO_ANIMATION


# enum for Camera control options
enum CameraMode1 {
	MOUSE_CONTROL,
	AUTO_ORBIT,
	STATIC_CAMERA,
	BACKANDFORTH,
	SHAKE
}
enum CameraMode2 {
	MOUSE_CONTROL,
	AUTO_ORBIT,
	STATIC_CAMERA,
	BACKANDFORTH,
	SHAKE
}
# enum for water, desert or none
enum TerrainMode {
	NONE,
	WATER,
	DESERT
}

enum ColorMode {
	STATIC,
	CYCLE_COLOR,
	WAVE_COLOR
	
}
enum AnimationMode {
	NO_ANIMATION,
	PULSE_ANIMATION
	
}
class ShaderObject:
	var type: int
	var position: Vector3
	var size: Vector3
	var radius: float
	var color: Vector3
	var noise_type: int

	var specular_color: Vector3 = Vector3.ONE
	var specular_strength: float = 0.5
	var shininess: float = 32.0
	# New dolphin-specific parameters
	var speed: float = 1.0
	var direction: Vector3 = Vector3(1, 0, 0)
	var time_offset: float = 0.0
	

	func set_values(t, pos, sz, r, c,noi_typ, spec_col := Vector3.ONE, spec_str := 1.0, shin := 32.0, spd := 1.0, dir := Vector3(1, 0, 0), time_off := 0.0) -> ShaderObject:
		type = t
		position = pos
		size = sz
		radius = r
		color = c
		noise_type=noi_typ
		specular_color = spec_col
		specular_strength = spec_str
		shininess = shin
		speed = spd
		direction = dir
		time_offset = time_off
		
		return self

var shader_objects := []



func _ready():
	#	if shader_material_target == null:
	#		return
	#User Step1:Add SDFs
	#Guide user by poviding numbers 
	shader_objects = [
	
	
	#Cart_1
	#Back-left wheel
	ShaderObject.new().set_values(2, Vector3(-7.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), # Cactus body	
	# Rock pillar
	ShaderObject.new().set_values(1, Vector3(-5.0, 2.0, -4.0), Vector3(3.0, 1.0, 1.0), 0.1, Vector3(0.5, 0.3, 0.2), 1), 		
	#Back-right wheel
	ShaderObject.new().set_values(2, Vector3(-7.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), 
	
	#Front-Left wheel
	ShaderObject.new().set_values(2, Vector3(-2.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), # Cactus body
	#Front-right wheel
	ShaderObject.new().set_values(2, Vector3(-2.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), # Cactus body
	

	#Left Cart Diamonds(#1)
	# Option 1: Classic White Diamond
	ShaderObject.new().set_values(5, Vector3(-6.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
	ShaderObject.new().set_values(5, Vector3(-4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
	#ShaderObject.new().set_values(5, Vector3(-4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
	ShaderObject.new().set_values(5, Vector3(-4.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
	ShaderObject.new().set_values(5, Vector3(-6.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),

	# Option 2: Blue Diamond (more colorful)
	ShaderObject.new().set_values(5, Vector3(-8.0, 3.5, -4.0), Vector3(1, 1, 1), 1.0, Vector3(0.85, 0.9, 1.0), 0, Vector3(0.7, 0.75, 1.0), 0.98, 150.0),


	#Cart_2
	#Back-left wheel
	ShaderObject.new().set_values(2, Vector3(3.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), # Cactus body	
	# Rock pillar
	ShaderObject.new().set_values(1, Vector3(6.0, 2.0, -4.0), Vector3(3.0, 1.0, 1.0), 0.1, Vector3(0.5, 0.3, 0.2), 1), 		
	#Back-right wheel
	ShaderObject.new().set_values(2, Vector3(3.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), 
	
	#Front-Left wheel
	ShaderObject.new().set_values(2, Vector3(8.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), # Cactus body
	#Front-right wheel
	ShaderObject.new().set_values(2, Vector3(8.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), # Cactus body
	
	
	#Right Cart Diamonds(#2)
	# Option 1: Classic White Diamond
	ShaderObject.new().set_values(5, Vector3(6.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
	ShaderObject.new().set_values(5, Vector3(4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
	#ShaderObject.new().set_values(5, Vector3(4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
	ShaderObject.new().set_values(5, Vector3(4.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
	ShaderObject.new().set_values(5, Vector3(6.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),

	# Option 2: Blue Diamond (more colorful)
	ShaderObject.new().set_values(5, Vector3(8.0, 3.5, -4.0), Vector3(1, 1, 1), 1.0, Vector3(0.85, 0.9, 1.0), 0, Vector3(0.7, 0.75, 1.0), 0.98, 150.0),



]

	fill_shader_parameters(shader_objects)

func _process(delta):
	update_shader_uniforms()

func fill_shader_parameters(obj_list: Array):
	var mat := shader_material_target.material
	if mat == null or not mat is ShaderMaterial:
		push_error("No valid ShaderMaterial found!")
		return

	var count := min(obj_list.size(), MAX_OBJECTS)

	var types := PackedInt32Array()
	var positions := PackedVector3Array()
	var sizes := PackedVector3Array()
	var radii := PackedFloat32Array()
	var colors := PackedVector3Array()
	var noise_types:=PackedInt32Array()
	var specular_colors := PackedVector3Array()
	var specular_strengths := PackedFloat32Array()
	var shininesses := PackedFloat32Array()
	# New dolphin parameter arrays
	var speeds := PackedFloat32Array()
	var directions := PackedVector3Array()
	var time_offsets := PackedFloat32Array()

	for obj in obj_list:
		types.append(obj.type)
		positions.append(obj.position)
		sizes.append(obj.size)
		radii.append(obj.radius)
		colors.append(obj.color)
		noise_types.append(obj.noise_type)
		specular_colors.append(obj.specular_color)
		specular_strengths.append(obj.specular_strength)
		shininesses.append(obj.shininess)
		speeds.append(obj.speed)
		directions.append(obj.direction)
		time_offsets.append(obj.time_offset)

	while types.size() < MAX_OBJECTS:
		types.append(0)
		positions.append(Vector3.ZERO)
		sizes.append(Vector3.ZERO)
		radii.append(0.0)
		colors.append(Vector3.ZERO)
		noise_types.append(0)
		specular_colors.append(Vector3.ONE)
		specular_strengths.append(0.0)
		shininesses.append(1.0)
		speeds.append(1.0)
		directions.append(Vector3(1, 0, 0))
		time_offsets.append(0.0)

	mat.set_shader_parameter("obj_type", types)
	mat.set_shader_parameter("obj_position", positions)
	mat.set_shader_parameter("obj_size", sizes)
	mat.set_shader_parameter("obj_radius", radii)
	mat.set_shader_parameter("obj_color", colors)
	mat.set_shader_parameter("obj_noise", noise_types)
	mat.set_shader_parameter("specularColorFloat", specular_colors)
	mat.set_shader_parameter("specularStrengthFloat", specular_strengths)
	mat.set_shader_parameter("shininessFloat", shininesses)
	# Set new dolphin parameters
	mat.set_shader_parameter("obj_speed", speeds)
	mat.set_shader_parameter("obj_direction", directions)
	mat.set_shader_parameter("obj_time_offset", time_offsets)
	mat.set_shader_parameter("inputCount", count)
	# Debug print to check if dolphin is being sent
	print("Object count: ", count)
	print("Types: ", types)
	print("Positions: ", positions)
	print("Noise Types:",noise_types)
func update_shader_uniforms():
	#	if shader_material_target == null:
	#		return
		
	var mat := shader_material_target.material
	if mat == null or not mat is ShaderMaterial:
		return

	var screen_size := get_viewport().get_visible_rect().size
	var mouse_pos := get_viewport().get_mouse_position()

	# Update common uniforms 
	mat.set_shader_parameter("screen_resolution", screen_size)
	mat.set_shader_parameter("_ScreenParams", Vector4(screen_size.x, screen_size.y, 0, 0))
	mat.set_shader_parameter("_mousePoint", Vector4(mouse_pos.x, mouse_pos.y, 0, 0))
	mat.set_shader_parameter("Tme", Time.get_ticks_msec() / 1000.0)
	mat.set_shader_parameter("lightPosition",lightPosition)
	
	

	# NEW: Pass camera control parameters to shader
	# NEW: Pass camera control parameters to shader
	mat.set_shader_parameter("camera_mode1", int(camera_mode1))
	mat.set_shader_parameter("camera_mode2", int(camera_mode2))
	
	mat.set_shader_parameter("color_mode",int(color_mode))
	mat.set_shader_parameter("orbit_speed", orbit_speed)
	mat.set_shader_parameter("shake_intensity", shake_intensity)
	mat.set_shader_parameter("shake_speed", shake_speed)
	mat.set_shader_parameter("movement_speed",movement_speed)  
	mat.set_shader_parameter("orbit_axis",orbit_axis)

	mat.set_shader_parameter("terrain_mode", int(terrain_mode))  
	mat.set_shader_parameter("cycle_speed",cycle_speed)  
	mat.set_shader_parameter("wave_speed",wave_speed)  

	mat.set_shader_parameter("animation_mode",animation_mode)
	
	# Camera position setup based on mode
	var cam_pos: Vector3

	match camera_mode1:
		CameraMode1.MOUSE_CONTROL:
			# Mouse-controlled orbit camera
			var x_angle = (mouse_pos.x / screen_size.x - 0.5) * TAU
			var y_angle = clamp((mouse_pos.y / screen_size.y - 0.5) * PI, -PI * 0.4, PI * 0.4)
			var radius = 13.0
			var cam_x = radius * cos(y_angle) * sin(x_angle)
			var cam_y = radius * sin(y_angle)
			var cam_z = radius * cos(y_angle) * cos(x_angle)
			cam_pos = Vector3(cam_x, cam_y, cam_z)
			
		CameraMode1.AUTO_ORBIT:
			# Fixed camera position - let the shader handle rotation
			cam_pos = cameraPosition
			
		CameraMode1.STATIC_CAMERA:
			# Static camera position
			cam_pos = cameraPosition

		CameraMode1.BACKANDFORTH:
			# Fixed camera position - let the shader handle rotation
			cam_pos = cameraPosition

		CameraMode1.SHAKE:
			# Fixed camera position - let the shader handle rotation
			cam_pos = cameraPosition



	match camera_mode2:
		CameraMode2.MOUSE_CONTROL:
			# Mouse-controlled orbit camera
			var x_angle = (mouse_pos.x / screen_size.x - 0.5) * TAU
			var y_angle = clamp((mouse_pos.y / screen_size.y - 0.5) * PI, -PI * 0.4, PI * 0.4)
			var radius = 13.0
			var cam_x = radius * cos(y_angle) * sin(x_angle)
			var cam_y = radius * sin(y_angle)
			var cam_z = radius * cos(y_angle) * cos(x_angle)
			cam_pos = Vector3(cam_x, cam_y, cam_z)
			
		CameraMode2.AUTO_ORBIT:
			# Fixed camera position - let the shader handle rotation
			cam_pos = cameraPosition
			
		CameraMode2.STATIC_CAMERA:
			# Static camera position
			cam_pos = cameraPosition

		CameraMode2.BACKANDFORTH:
			# Fixed camera position - let the shader handle rotation
			cam_pos = cameraPosition

		CameraMode2.SHAKE:
			# Fixed camera position - let the shader handle rotation
			cam_pos = cameraPosition


	mat.set_shader_parameter("camera_position", cam_pos)

	mat.set_shader_parameter("look_at_position", get_scene_center())

func get_scene_center() -> Vector3:
	if shader_objects.is_empty():
		return Vector3.ZERO
	var center := Vector3.ZERO
	for obj in shader_objects:
		center += obj.position
	return center / shader_objects.size()
