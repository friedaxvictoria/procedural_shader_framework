@tool
extends EditorPlugin


func _enter_tree() -> void:
	## Initialization of the plugin goes here.
	## Register visual shader nodes
	var icon = EditorInterface.get_base_control().get_theme_icon("ShaderMaterial", "EditorIcons")
	#add_custom_type("PerlinNoise3DD", "VisualShaderNodeCustom", preload("res://addons/visual_shader_nodes/noise/perlin_noise/perlin_noise_3d.gd"), icon)
	## Add more nodes here as needed
    add_custom_type("SetMaterialParams", "VisualShaderNodeCustom", preload("res://addons/NodesOfVisualShader/SDFs/SDFNodes.gd"), icon)
	add_custom_type(
	"AddSphere", "VisualShaderNodeCustom",
	preload("res://addons/NodesOfVisualShader/SDFs/AddSphereNode.gd"),
	icon
	)
	add_custom_type("ApplyPhongLighting", "VisualShaderNodeCustom", preload("res://addons/NodesOfVisualShader/PhongLighting.gd"), icon)
	add_custom_type("SDFRaymarch", "VisualShaderNodeCustom", preload("res://addons/NodesOfVisualShader/SDFRaymarch.gd"), icon)
	#++++++++++++++++++++++++++++++++++
	#add_custom_type(
      
	   # "CameraShaderController", 
       # "Camera3D",
       # preload("res://addons/utility_nodes/camera/camera_shader_controller.gd"), icon)

	#CameraInput visual shader node
   # add_custom_type("CameraInput", "VisualShaderNodeCustom", 
	#	preload("res://addons/visual_shader_nodes/camera/camera_input.gd"), icon)

	##TimeInput node
   # add_custom_type("TimeInput", "VisualShaderNodeCustom", 
	#	preload("res://addons/visual_shader_nodes/time/time_input.gd"), icon)

	## Add this line in _enter_tree():
	#add_custom_type("SDFSphere", "VisualShaderNodeCustom", 
   # preload("res://addons/visual_shader_nodes/raymarching/sphereSDF.gd"), icon)

	#add_custom_type("SDFTorus", "VisualShaderNodeCustom", 
   # preload("res://addons/visual_shader_nodes/raymarching/torusSDF.gd"), icon)

	#add_custom_type("SDFBox", "VisualShaderNodeCustom", 
   # preload("res://addons/visual_shader_nodes/raymarching/boxSDF.gd"), icon)

	#add_custom_type("Raymarch1", "VisualShaderNodeCustom", 
   #preload("res://addons/visual_shader_nodes/raymarching/raymarch1.gd"), icon)

	#add_custom_type("Raymarch2", "VisualShaderNodeCustom", 
   #preload("res://addons/visual_shader_nodes/raymarching/raymarch2.gd"), icon)

	#add_custom_type("RaymarchFinalized", "VisualShaderNodeCustom", 
    #preload("res://addons/visual_shader_nodes/raymarching/raymarchfinalized.gd"), icon)




func _exit_tree() -> void:
	# #Clean-up of the plugin goes here.
	#remove_custom_type("PerlinNoise3D")
	#remove_custom_type("CameraShaderController")
	#remove_custom_type("CameraInput")
	#remove_custom_type("TimeInput")
	#remove_custom_type("SDFSphere")
	#remove_custom_type("SDFTorus")
	#remove_custom_type("SDFBox")
	#remove_custom_type("Raymarch1")
	#remove_custom_type("Raymarch2")
	#remove_custom_type("RaymarchFinalized")

