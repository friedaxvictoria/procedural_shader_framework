// File: sdf_sphere_camera.gdshader
// SDF Sphere Shader with Camera Integration
// Works with camera_shader_controller.gd from your existing project

shader_type canvas_item;

// Include the adapted SDF sphere functions
#include "res://addons/includes/camera/sdf_sphere_adapted.gdshaderinc"

// ===== UNIFORMS =====

// Camera uniforms (automatically provided by camera_shader_controller.gd)
uniform vec3 u_camera_position;
uniform vec3 u_camera_direction;

// Screen properties
uniform vec2 u_resolution = vec2(1024.0, 768.0);

// Animation controls
uniform bool u_enable_rotation = true;
uniform bool u_enable_camera_rotation = false;
uniform float u_animation_speed = 1.0;

// Visual properties
uniform vec3 u_background_color : source_color = vec3(0.25, 0.25, 0.25);
uniform int u_primitive_type : hint_range(0, 1) = 0; // 0=sphere, 1=box

// Lighting controls
uniform vec3 u_ambient_color : source_color = vec3(0.2, 0.2, 0.2);
uniform vec3 u_diffuse_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 u_specular_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float u_shininess : hint_range(1.0, 200.0) = 100.0;

// Advanced controls
uniform vec3 u_light_position = vec3(10.0, 10.0, 10.0);
uniform float u_fresnel_strength : hint_range(0.0, 1.0) = 0.2;

// ===== FRAGMENT SHADER =====

void fragment() {
    // Calculate time factor for animations
    float time_factor = TIME * u_animation_speed;

    // Choose rendering method based on settings
    if (u_enable_camera_rotation) {
        // Use camera rotation like original shader
        COLOR = renderAdvancedSDFWithCameraRotation(
            FRAGCOORD.xy,
            u_resolution,
            u_camera_position,
            u_camera_direction,
            time_factor
        );
    } else {
        // Use your camera controller (recommended)
        COLOR = renderAdvancedSDF(
            FRAGCOORD.xy,
            u_resolution,
            u_camera_position,
            u_camera_direction,
            time_factor,
            u_enable_rotation,
            false, // Don't override camera controller
            u_background_color
        );
    }
}
