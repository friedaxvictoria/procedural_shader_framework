@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	# Register visual shader nodes
	var icon = get_editor_interface().get_base_control().get_theme_icon("ShaderMaterial", "EditorIcons")

	add_custom_type("PerlinNoise3DD", "VisualShaderNodeCustom", preload("res://addons/visual_shader_nodes/noise/perlin_noise/perlin_noise_3d.gd"), icon)
	# Add more nodes here as needed


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("PerlinNoise3D")
