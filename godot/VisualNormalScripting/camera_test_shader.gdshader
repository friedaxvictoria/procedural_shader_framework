shader_type spatial;

uniform vec3 u_camera_position;
uniform vec3 u_camera_direction;

void fragment() {
    // Get UV coordinates for the quad
    vec2 uv = UV - 0.5;  // Center the coordinates

    // Camera position effects
    float camera_x = u_camera_position.x;
    float camera_z = u_camera_position.z;

    // Create animated waves based on camera position and time
    float wave1 = sin(uv.x * 10.0 + camera_x * 2.0 + TIME * 3.0) * 0.5 + 0.5;
    float wave2 = cos(uv.y * 8.0 + camera_z * 1.5 + TIME * 2.0) * 0.5 + 0.5;
    float ripple = sin(length(uv) * 15.0 - TIME * 4.0 + camera_x) * 0.5 + 0.5;

    // Combine waves for dynamic pattern
    float pattern = (wave1 * wave2 + ripple) * 0.5;

    // Camera-based color zones with smooth transitions
    vec3 base_color = vec3(0.1, 0.1, 0.2);  // Dark blue base

    if (camera_x > 0.5) {
        // RIGHT side - Animated RED with flowing patterns
        float red_intensity = clamp(camera_x * 0.3, 0.0, 1.0);
        vec3 red_color = vec3(1.0, 0.3, 0.1) * red_intensity;
        base_color = mix(base_color, red_color, pattern);
    }
    else if (camera_x < -0.5) {
        // LEFT side - Animated GREEN with flowing patterns
        float green_intensity = clamp(-camera_x * 0.3, 0.0, 1.0);
        vec3 green_color = vec3(0.1, 1.0, 0.3) * green_intensity;
        base_color = mix(base_color, green_color, pattern);
    }
    else {
        // CENTER - Animated BLUE/PURPLE waves
        vec3 center_color = vec3(0.2, 0.1, 0.8);
        base_color = mix(base_color, center_color, pattern * 0.7);
    }

    // Add camera-distance based brightness
    float distance_to_camera = length(u_camera_position);
    float brightness = 1.0 + sin(distance_to_camera * 0.5 + TIME) * 0.3;

    // Final color with dynamic brightness
    ALBEDO = base_color * brightness;

    // Add some emission for glow effect
    EMISSION = base_color * 0.2 * pattern;
}