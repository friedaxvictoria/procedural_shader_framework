// ==========================================
// Module: Rim lighting and reflection Shader
// Category: Lighting
// Description: 
//   Computes rim lighting and reflection contributions.
// Screenshot: 
//   (1) Black background to isolate rim light behavior.
//       screenshots/lighting/RimReflectionLighting_black.png
//   (2) Bayer background to highlight reflection contribution.
//       screenshots/lighting/RimReflectionLighting_Bayer.png
// ==========================================

/**
 * Function: computeRimReflectionLighting
 * Description: 
 *   Computes reflection and rim lighting contributions based on view direction
 *   and surface normal. Reflection uses environment texture; rim light depends 
 *   on the viewing angle to emphasize edges.
 * Input:
 *   - dir (vec3): View direction from camera to surface.
 *   - N (vec3): Normal vector at the surface point.
 * Output:
 *   - vec4: Combined lighting contribution including reflection and rim light.
 */
vec4 computeRimReflectionLighting(vec3 dir, vec3 N) {
    vec3 ref = reflect(dir, N);
    vec2 uv_ref = ref.xy * 0.5 + 0.5;

    float rim = max(0.0, 0.7 + dot(N, dir));
    vec4 rimColor = vec4(rim, rim * 0.5, 0.0, 1.0);
    vec4 reflection = texture(iChannel1, uv_ref) * 0.3;

    return rimColor + reflection;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // 1. Normalize coordinates to [-1, 1] with aspect ratio correction
    vec2 uv = (fragCoord / iResolution.xy) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    // 2. Simulate a sphere by using the circle shape mask
    float r = length(uv);
    if (r > 0.8) {
        fragColor = vec4(0.0); // Outside of sphere: transparent / black
        return;
    }

    // 3. Fake a normal from the UV coordinates to simulate a spherical surface
    vec3 N = normalize(vec3(uv, sqrt(1.0 - clamp(dot(uv, uv), 0.0, 1.0))));
    
    // 4. View direction: from camera toward pixel (camera at z = +1 looking toward -Z)
    vec3 dir = normalize(vec3(uv, -1.0));

    // 5. Compute rim + reflection lighting
    vec4 lighting = computeRimReflectionLighting(dir, N);

    // 6. Output final color
    fragColor = lighting;
}
