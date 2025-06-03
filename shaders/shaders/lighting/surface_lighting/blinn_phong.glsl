// ==========================================
// Module: Blinn-Phong Lighting Shader
// Category: Lighting
// Description: 
//   Implements the Blinn-Phong lighting model, combining ambient,
//   Lambertian diffuse, and specular components. Unlike Phong, it 
//   uses the halfway vector between light and view direction for
//   more efficient and stable highlight computation.
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

vec3 applyBlinnPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); // Lambertian diffuse

    vec3 H = normalize(ctx.lightDir + ctx.viewDir);       // Halfway vector
    float spec = pow(max(dot(ctx.normal, H), 0.0), mat.shininess); // Specular term

    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
}
