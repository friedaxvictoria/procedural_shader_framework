// ==========================================
// Shader: SDF Sphere Raymarch Shader
// Category: Geometry
// Description: 
//   Provides geometric primitives and operations for raymarching-based rendering.
//   Implements a scene defined by a signed distance field (a sphere), normal 
//   estimation via central differences, and raymarching to detect surface hits.
// screenshots/geometry/SDF_Sphere.png
// ==========================================

/**
 * Function: scene
 * Description: Defines the distance field of the scene. In this case, a single sphere.
 * Input:
 *   - position (vec3): The point in space to evaluate.
 * Output:
 *   - float: Signed distance from the point to the closest surface.
 */
float scene(vec3 position) {
    float radius = 0.3;
    return length(position) - radius;
}

/**
 * Function: getNormal
 * Description: Approximates the surface normal at a point using central differences.
 * Input:
 *   - pos (vec3): Surface point where the normal is evaluated.
 *   - smoothness (float): Step size for the numerical gradient.
 * Output:
 *   - vec3: Estimated normal vector at the given point.
 */
vec3 getNormal(vec3 pos, float smoothness) {
    vec3 n;
    vec2 dn = vec2(smoothness, 0.0);
    n.x = scene(pos + dn.xyy) - scene(pos - dn.xyy);
    n.y = scene(pos + dn.yxy) - scene(pos - dn.yxy);
    n.z = scene(pos + dn.yyx) - scene(pos - dn.yyx);
    return normalize(n);
}

/**
 * Function: raymarch
 * Description: Performs sphere tracing to find the intersection with the scene.
 * Input:
 *   - position (vec3): Ray origin.
 *   - direction (vec3): Ray direction (normalized).
 * Output:
 *   - float: Distance to the first intersection; -1.0 if no hit.
 */
float raymarch(vec3 position, vec3 direction) {
    float total_distance = 0.0;
    for (int i = 0; i < 32; ++i) {
        float d = scene(position + direction * total_distance);
        if (d < 0.005) {
            return total_distance;
        }
        total_distance += d;
    }
    return -1.0;
}

// Displays a 3D red sphere using raymarching and diffuse lighting.
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // 1. Normalize coordinates to range [-1, 1], aspect corrected
    vec2 uv = (fragCoord / iResolution.xy) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    // 2. Define camera
    vec3 camera_pos = vec3(0.0, 0.0, 1.5);      // Camera at z = 1.5
    vec3 target = vec3(0.0);                    // Looking at origin
    vec3 forward = normalize(target - camera_pos);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
    vec3 up = cross(forward, right);
    
    // 3. Build ray direction through pixel
    vec3 ray_dir = normalize(uv.x * right + uv.y * up + 1.0 * forward);

    // 4. Perform raymarching
    float dist = raymarch(camera_pos, ray_dir);

    // 5. If hit, compute normal and shading
    vec3 color;
    if (dist > 0.0) {
        vec3 hit_pos = camera_pos + ray_dir * dist;
        vec3 normal = getNormal(hit_pos, 0.001);

        // Simple diffuse shading with fixed light direction
        vec3 light_dir = normalize(vec3(0.8, 0.6, 1.0));
        float diffuse = max(dot(normal, light_dir), 0.0);
        color = vec3(1.0, 0.3, 0.2) * diffuse;  // Red-ish color shaded by light
    } else {
        color = vec3(0.9); // Background color
    }

    fragColor = vec4(color, 1.0);
}
