// ==========================================
// Shader: Camera Orientation Setup Shader
// Category: Animation / Camera
// Description: 
//   Defines a dynamic camera system using a "look at" matrix with support 
//   for orbital motion around the origin and optional roll. This allows 
//   the camera to animate smoothly around the scene.
// Screenshot: screenshots/animation/RollingRefraction.gif
// ==========================================

/**
 * Function: calcLookAtMatrix
 * Description: Computes a camera basis matrix from eye position, target, and roll.
 * Input:
 *   - ro (vec3): Camera (eye) position.
 *   - ta (vec3): Target position to look at.
 *   - roll (float): Roll angle in radians for camera rotation.
 * Output:
 *   - mat3: Camera rotation matrix (right, up, forward).
 */
mat3 calcLookAtMatrix(vec3 ro, vec3 ta, float roll) {
    vec3 forward = normalize(ta - ro);
    vec3 right = normalize(cross(forward, vec3(sin(roll), cos(roll), 0.0)));
    vec3 up = normalize(cross(right, forward));
    return mat3(right, up, forward);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalized device coordinates ([-1, 1]), aspect corrected
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    // Time-based camera animation
    float t = iTime * 0.5;  // control speed
    vec3 ta = vec3(0.0);    // Look-at target
    vec3 ro = vec3(2.0 * cos(t), 1.0, 2.0 * sin(t)); // Orbiting camera
    float roll = sin(iTime * 0.3) * 0.3; // Slight rolling tilt

    // Compute camera matrix
    mat3 camMat = calcLookAtMatrix(ro, ta, roll);

    // Ray direction from screen into world space
    vec3 rayDir = normalize(camMat * vec3(p, -1.0));

    // Sample environment using direction (flat projection here)
    vec2 envUV = rayDir.xy * 0.5 + 0.5;
    vec3 col = texture(iChannel0, envUV).rgb;

    fragColor = vec4(col, 1.0);
}
