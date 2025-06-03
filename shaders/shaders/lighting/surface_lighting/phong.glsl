// ==========================================
// Module: Phong Lighting Shader
// Category: Lighting
// Description: 
//   Implements the Phong lighting model, combining ambient,
//   Lambertian diffuse, and specular reflection components.
//   Commonly used in rasterization and raymarching to simulate
//   basic surface shading with highlight effects.
// Input:
//   LightingContext ctx:
//      - vec3: normal: surface normal (unit vector)
//      - vec3: lightDir: direction from surface to light source (unit vector)
//      - vec3: viewDir: direction from surface to camera (unit vector)
//      - vec3: lightColor: RGB color and intensity of the light
//      - vec3: ambient: RGB ambient lighting contribution
//   MaterialParams mat:
//      - vec3: baseColor: RGB diffuse material color
//      - vec3: specularColor: RGB specular material color
//      - float: specularStrength: strength multiplier for specular highlight
//      - float: shininess: exponent controlling specular sharpness
// Output:
//   - vec3: Combined RGB shading result (ambient + diffuse + specular)
// ==========================================

vec3 applyPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); // Lambertian diffuse

    vec3 R = reflect(-ctx.lightDir, ctx.normal);          // Reflected light direction
    float spec = pow(max(dot(R, ctx.viewDir), 0.0), mat.shininess); // Phong specular

    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
}
