// ==========================================
// Module: Refraction Color Shader
// Category: Material
// Description: 
//   Computes the refracted background color by tracing the view direction
//   through the surface using Snell¡¯s law (via GLSL's `refract()` function).
//   The result is sampled from a background texture and modulated by the
//   material¡¯s refraction tint and strength, simulating translucent materials
//   like glass or liquid.
// Input:
//   LightingContext ctx:
//      - vec3: normal: surface normal (unit vector)
//      - vec3: viewDir: view direction from surface to camera (unit vector)
//   MaterialParams mat:
//      - float: ior: index of refraction (e.g., 1.45 for glass)
//      - float: refractionStrength: blending factor in [0.0, 1.0]
//      - vec3: refractionTint: color tint applied to the background sample
//   sampler2D backgroundTex:
//      - Background texture to sample the refracted color from
// Output:
//   - vec3: Refracted RGB color contribution for surface compositing
// ==========================================

vec3 computeRefractionColor(LightingContext ctx, MaterialParams mat, sampler2D backgroundTex) {
    // Compute refracted direction (Snell's Law: eta = air / material ior)
    vec3 refr = refract(ctx.viewDir, ctx.normal, 1.0 / mat.ior);

    // Project refracted direction to screen-space UV
    vec2 uv = refr.xy * 0.5 + 0.5;

    // Sample background and modulate with tint and strength
    vec3 sampled = texture(backgroundTex, uv).rgb;
    return sampled * mat.refractionTint * mat.refractionStrength;
}
