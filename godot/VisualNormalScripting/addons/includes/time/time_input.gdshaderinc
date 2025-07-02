// Time Input Utility - Provides all time-related data
// Universal time interface for animations and effects

// Standard time uniforms (can be provided by engine or custom controller)
uniform float u_time;           // Engine time
uniform float u_delta_time;     // Frame delta time
uniform float u_time_scale;     // Custom time scaling
uniform float u_custom_time;    // User-controlled time

// Helper functions to access time data
float get_engine_time() {
    return u_time;
}

float get_delta_time() {
    return u_delta_time;
}

float get_scaled_time() {
    return u_time * u_time_scale;
}

float get_custom_time() {
    return u_custom_time;
}

// Animation utilities
float get_ping_pong_time(float duration) {
    float t = mod(get_scaled_time(), duration * 2.0);
    return t > duration ? duration * 2.0 - t : t;
}

float get_loop_time(float duration) {
    return mod(get_scaled_time(), duration);
}

float get_pulse(float frequency) {
    return sin(get_scaled_time() * frequency) * 0.5 + 0.5;
}

float get_triangle_wave(float frequency) {
    return abs(mod(get_scaled_time() * frequency, 2.0) - 1.0);
}

float get_sawtooth_wave(float frequency) {
    return mod(get_scaled_time() * frequency, 1.0);
}