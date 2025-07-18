#include "res://addons/includes/global_variables/global_variables.gdshaderinc"


void lightingContext(vec3 hitPos, vec3 cameraPos, out vec3 viewDir, out vec3 lightDir, out vec3 lightColor, out vec3 ambientColor)
{
    viewDir = normalize(cameraPos - hitPos); // Use the actual camera position
    lightDir = normalize(lightPosition - hitPos);
    lightColor = vec3(1.0, 1.0, 1.0);
    ambientColor = vec3(0.1, 0.1, 0.1);
}
void desertLightingContext(vec3 hitPos,  vec3 cameraPos, out vec3 viewDir, out vec3 lightDir, out vec3 lightColor, out vec3 ambientColor)
{
    viewDir = normalize(cameraPos - hitPos);
    lightDir = normalize(lightPosition - hitPos);
    lightColor = vec3(1.1, 1.05, 0.95);
    ambientColor = vec3(0.6, 0.7, 0.8);
}
//void computeUV_float(vec2 INuv, out vec2 uv)
//{
///
//    vec2 fragCoord = INuv * screen_resolution;
//    uv = fragCoord / screen_resolution.xy * 2. - 1.;
//    uv.x *= screen_resolution.x / screen_resolution.y;
//
//}

void computeUV_float(vec2 INuv, out vec2 uv) {
    vec2 fragCoord = INuv * screen_resolution;
    uv = fragCoord / screen_resolution.xy * 2. - 1.;
    uv.y = -uv.y; // Flip Y axis
    uv.x *= screen_resolution.x / screen_resolution.y;
}

mat3 compute_rotation_matrix(vec3 axis, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    float one_minus_c = 1.0 - c;

    vec3 col0 = vec3(
        c + axis.x * axis.x * one_minus_c,
        axis.y * axis.x * one_minus_c + axis.z * s,
        axis.z * axis.x * one_minus_c - axis.y * s
    );

    vec3 col1 = vec3(
        axis.x * axis.y * one_minus_c - axis.z * s,
        c + axis.y * axis.y * one_minus_c,
        axis.z * axis.y * one_minus_c + axis.x * s
    );

    vec3 col2 = vec3(
        axis.x * axis.z * one_minus_c + axis.y * s,
        axis.y * axis.z * one_minus_c - axis.x * s,
        c + axis.z * axis.z * one_minus_c
    );

    return mat3(col0, col1, col2); // Column-major
}
// Computes a camera basis matrix (right, up, -forward) given eye and target position
mat3 compute_camera_basis(vec3 look_at_pos, vec3 eye, mat3 mat) {
    vec3 f = normalize(look_at_pos - eye);            // Forward
    vec3 r = normalize(cross(f, vec3(0.0, 1.0, 0.0))); // Right
    vec3 u = cross(r, f);                              // Up
    return mat3(r, u, -f); // Column-major matrix for camera orientation
}

// cam related
void move_via_mouse_float(out mat3 mat) {
    vec2 mouse = _mousePoint.xy / _ScreenParams.xy;

    float angle_y = mix(-PI, PI, mouse.x);
    float angle_x = -PI * mouse.y;

    mat3 rot_y = compute_rotation_matrix(vec3(0.0, 1.0, 0.0), angle_y);
    mat3 rot_x = compute_rotation_matrix(vec3(1.0, 0.0, 0.0), angle_x);

    mat = rot_y * rot_x;
}
// rotateCamera_float, cam related
void orbitY_float(vec3 axis, float speed, out mat3 mat)
 {
    float angle = Tme * speed;
    mat = compute_rotation_matrix(normalize(axis), angle);
}

void backAndForth_scale_float(float speed, out mat3 animationMatrix) {
    float t = Tme * speed;
    float scale = abs(sin(t)) * 1.5 + 0.5; // Scale between 0.7 and 1.3

    animationMatrix = mat3(
        vec3(scale, 0.0,   0.0),
       vec3( 0.0,   scale, 0.0),
        vec3(0.0,   0.0,   scale)
    );
}

void backAndForth_translate_float(float speed, out vec3 offset) {
    float t = Tme * speed;
    offset = vec3(0.0, 0.0, sin(t) * 3.0); // Move ±5 units along Z
}

// Hash function to generate pseudo-random noise
float hash11(float p) {
    return fract(sin(p * 17.23) * 43758.5453);
}
// Shake function for jittery motion
void shake_matrix_float(float intensity, float speed, out mat3 shakeMatrix, out vec3 positionOffset) {
    float t = Tme * speed;

    // Position shake
    float px = hash11(t + 1.1) - 0.5;
    float py = hash11(t + 2.3) - 0.5;
    float pz = hash11(t + 3.7) - 0.5;

    // shake without rotation
    shakeMatrix = mat3(1.0); // Identity matrix

     positionOffset  = vec3(px, py, pz) * intensity;
}

void getCameraMatrix_float(mat3 matrix1, mat3 matrix2, float distance, vec3 lookAtPos,  out mat3 camMatrix, out vec3 rayOrigin) {
    mat3 combinedMat = matrix1 * matrix2;
    rayOrigin = (vec3(0.0, 0.0, distance) * combinedMat);
    camMatrix = compute_camera_basis(lookAtPos, rayOrigin, combinedMat);
}

void cycleColor_float(float speed,inout vec3 color) {
    float t = Tme * speed;
    float hue = fract(t);
    vec3 hsv = vec3(hue, 1.0, 1.0);
    // Inline HSV to RGB conversion
    vec3 rgb = clamp(abs(fract(hsv.x + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
    vec3 cycleRGB = hsv.z * mix(vec3(1.0), rgb, hsv.y);
    color = color * cycleRGB;
}
// Time mode application function
float applyTimeMode(float t, int mode) {
    if (mode == 1)
        return sin(t);
    else if (mode == 2)
        return abs(sin(t));
    return t; // mode 0 or default - linear time
}
void pulseObject_float(vec3 seedSize, float seedRadius, float freq, float amp, int mode, out vec3 size, out float radius)
{
    float t = applyTimeMode(Tme, mode);
    float scale = 1.0 + sin(t * freq) * amp;

    size = seedSize * scale;
    radius = seedRadius * scale;
}
// inspired by: https://www.shadertoy.com/view/fl3fRf
void changingColorSin_float(float speed,inout vec3 color)
{
    vec3 rootColor = asin(2.0 * color - 1.0);
    color = 0.5 + 0.5 * sin(Tme * speed * rootColor);
}