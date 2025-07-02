shader_type canvas_item;

#include "res://addons/includes/modular_sdf_scene.gdshaderinc"

// Uniforms for interactive control
uniform float u_time : hint_range(0.0, 100.0) = 0.0;
uniform vec2 u_resolution = vec2(1024.0, 768.0);

void fragment() {
    // Get fragment coordinates in screen space
    vec2 fragCoord = UV * u_resolution;

    // Call the render function from the include file
    COLOR = renderRayMarchingScene(fragCoord, u_resolution);
}