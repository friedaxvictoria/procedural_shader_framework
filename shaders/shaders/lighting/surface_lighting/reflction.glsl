// ==========================================
// Module: Reflection Shader
// Category: Lighting
// Description: 
//   Computes environment reflection based on the reflected view 
//   direction and samples the result from a 2D environment map.
//   Intended for use as a surface lighting component in PBR-like
//   or stylized reflective materials.
// Input:
//   LightingContext ctx:
//      - vec3: normal: surface normal (unit vector)
//      - vec3: viewDir: view direction (from surface to camera, unit vector)
//   - sampler2D: envMap: Environment map used for reflection sampling
//   - float: reflectStrength: Scalar multiplier for reflection intensity, typically in [0.0, 1.0]
// Output:
//   - vec4: 
//      RGB: Sampled reflection color from the environment map
//      A  : reflectStrength (used as a blending weight in compositing)
// ==========================================

vec4 computeReflection(LightingContext ctx, sampler2D envMap, float reflectStrength) {
    vec3 R = reflect(-ctx.viewDir, ctx.normal);
    vec2 uv = clamp(R.xy * 0.5 + 0.5, 0.0, 1.0); // Simple planar projection
    vec3 reflection = texture(envMap, uv).rgb;
    return vec4(reflection * reflectStrength, reflectStrength);
}
