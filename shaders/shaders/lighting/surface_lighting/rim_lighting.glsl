// ==========================================
// Module: Rim Lighting Shader
// Category: Lighting
// Description: 
//   Computes rim (edge) lighting contribution based on the viewing
//   angle between the surface normal and view direction. This effect
//   is often used to emphasize silhouettes and create a glow-like
//   appearance around object edges.
// Input:
//   LightingContext ctx:
//      - vec3: normal: surface normal (unit vector)
//      - vec3: viewDir: view direction (from surface to camera, unit vector)
//   MaterialParams mat:
//      - float: rimPower: Exponent that controls the sharpness of the rim edge
//   vec3 rimColor:
//      - RGB color of the rim light contribution
// Output:
//   - vec3: RGB rim lighting contribution to be added to the final shading result
// ==========================================

vec3 computeRimLighting(LightingContext ctx, MaterialParams mat, vec3 rimColor) {
    float rim = pow(1.0 - max(dot(ctx.normal, ctx.viewDir), 0.0), mat.rimPower);
    return rim * rimColor;
}
