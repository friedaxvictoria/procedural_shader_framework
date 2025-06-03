// ==========================================
// Module: Lambertian Diffuse Shader
// Category: Lighting
// Description: 
//   Computes Lambertian diffuse reflection, a simple and widely-used
//   BRDF model for matte surfaces. The reflected intensity depends on
//   the angle between the surface normal and the direction to the light.
//   This model assumes light is scattered equally in all directions.
// Input:
//   LightingInput input:
//      - vec3: normal: surface normal (unit vector)
//      - vec3: lightDir: direction from surface to light source (unit vector)
//      - vec3: lightColor: RGB color and intensity of the light
//   MaterialParams mat:
//      - vec3: baseColor: RGB surface color of the object
// Output:
//   - vec3: RGB diffuse lighting contribution to be added to the final shading result
// ==========================================

vec3 lambertDiffuse(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0);
    return mat.baseColor * ctx.lightColor * diff;
}
