// Camera Input Utility - Provides all camera data from CameraShaderController
// Universal camera interface for all visual shader nodes

// Standard camera uniforms (provided by CameraShaderController)
uniform vec3 u_camera_position;
uniform vec3 u_camera_direction;

// Helper functions to access camera data
vec3 get_camera_position() {
    return u_camera_position;
}

vec3 get_camera_direction() {
    return u_camera_direction;
}

vec3 get_camera_forward() {
    return u_camera_direction;
}

// Camera-based calculations
float get_distance_to_camera(vec3 world_pos) {
    return distance(world_pos, u_camera_position);
}

vec3 get_direction_to_camera(vec3 world_pos) {
    return normalize(u_camera_position - world_pos);
}

vec3 get_direction_from_camera(vec3 world_pos) {
    return normalize(world_pos - u_camera_position);
}

// Camera-relative position
vec3 get_camera_relative_position(vec3 world_pos) {
    return world_pos - u_camera_position;
}

// Distance-based effects
float get_distance_fade(vec3 world_pos, float near_distance, float far_distance) {
    float dist = get_distance_to_camera(world_pos);
    return 1.0 - smoothstep(near_distance, far_distance, dist);
}