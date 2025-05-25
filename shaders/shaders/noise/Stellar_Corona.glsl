// ==========================================
// Module: Procedural Overlay Effects Shader
// Category: Noise / Emissive / Decorative
// Description: 
//   Adds stylized glow and star shape over the center.
// ==========================================
/**
 * Function: computeNoiseOverlay
 * Description: 
 *   Produces procedural visual effects over the center of the screen, 
 *   including a glowing radial gradient and a 5-pointed star pattern.
 *   These are purely screen-space decorations based on UV distance and angle.
 * Input:
 *   - uv (vec2): Normalized screen-space coordinates centered at (0,0),
 *                where (0,0) is the image center and range is roughly [-1,1].
 * Output:
 *   - vec4: Combined overlay effect color (glow + star pattern).
 */
vec4 computeNoiseOverlay(vec2 uv) {
    float P = PI / 5.0;
    float starVal = (1.0 / P) * (P - abs(mod(atan(uv.x, uv.y) + PI, 2.0 * P) - P)));
    vec4 starColor = (distance(uv, vec2(0.0)) < 0.06 - (starVal * 0.03))
        ? vec4(2.8, 1.0, 0.0, 1.0)
        : vec4(0.0);

    float glowFactor = max(0.0, 1.0 - distance(uv * 4.0, vec2(0.0)));
    vec4 glow = vec4(0.6, 0.2, 0.0, 1.0) * glowFactor * 4.0 * (0.2 + abs(sin(iTime)) * 0.8);

    return glow + starColor;
}