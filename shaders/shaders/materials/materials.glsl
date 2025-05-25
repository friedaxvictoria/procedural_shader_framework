// ==========================================
// Module: Material Color Shader
// Category: Material
// Description: 
//   Returns the base surface color modulated by background texture (refraction).
// Screenshot: screenshots/materials/materials.png
// ==========================================

/**
 * Function: computeMaterialColor
 * Description: 
 *   Computes the base material color for the surface using refraction.
 *   The view direction is refracted through the surface normal and used 
 *   to sample a background texture, simulating a translucent material.
 * Input:
 *   - dir (vec3): View direction from the camera to the surface.
 *   - N (vec3): Surface normal vector at the shading point.
 * Output:
 *   - vec4: Final base color after modulating background with surface color.
 */
vec4 computeMaterialColor(vec3 dir, vec3 N) {
    vec3 refr = refract(dir, N, 0.7);
    vec2 uv_refr = refr.xy * 0.5 + 0.5;
    vec4 baseColor = vec4(1.0, 0.8, 0.0, 1.0) * 0.75;
    return texture(iChannel1, uv_refr) * baseColor;
}

// ==========================================
// Module: Surface Shader
// Category: Material / Final Composition
// Description: 
//   Combines material color, lighting, and procedural overlays 
//   into the final fragment color.
// ==========================================

/**
 * Function: computeMaterial
 * Description:
 *   Assembles the final surface appearance by summing up:
 *     - base material color (via refraction),
 *     - lighting effects (reflection and rim light),
 *     - procedural effects (glow and star pattern).
 * Input:
 *   - dir (vec3): View direction from camera to surface.
 *   - N (vec3): Surface normal at the shading point.
 *   - pos (vec3): World-space hit position (not used here).
 *   - uv (vec2): Normalized screen-space UV coordinates.
 * Output:
 *   - vec4: Final color of the shaded surface fragment.
 */
vec4 computeMaterial(vec3 dir, vec3 N, vec3 pos, vec2 uv) {
    vec4 materialColor = computeMaterialColor(dir, N);
    vec4 lighting = computeLighting(dir, N);
    vec4 overlay = computeNoiseOverlay(uv);
    return materialColor + lighting + overlay;
}

// Simple constant ambient lighting
vec4 computeLighting(vec3 dir, vec3 N) {
    return vec4(0.2, 0.2, 0.2, 1.0);
}

// Flat overlay with slight blue tint
vec4 computeNoiseOverlay(vec2 uv) {
    return vec4(0.05, 0.05, 0.1, 1.0);
}

// Main image entry point (Shadertoy)
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;

    // Screen space to NDC (Normalized Device Coordinates)
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    vec3 dir = normalize(vec3(p, -1.0)); // View direction
    vec3 N = normalize(vec3(0.0, 0.0, 1.0)); // Surface normal
    vec3 pos = vec3(0.0); // Not used

    fragColor = computeMaterial(dir, N, pos, uv);
}
