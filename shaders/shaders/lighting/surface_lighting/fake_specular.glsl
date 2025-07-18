// ==========================================
// Module: Fake Specular Highlight Shader
// Category: Stylized Lighting
// Description: 
//   Generates a stylized non-physically-based specular highlight using
//   a controllable exponent. This effect is often used in toon shading,
//   stylized rendering, and procedural surfaces like water or plastic.
// Input:
//   LightingContext ctx:
//      - vec3: normal: surface normal (unit vector)
//      - vec3: viewDir: view direction (from surface to camera, unit vector)
//      - vec3: lightDir: direction from surface to light source (unit vector)
//      - vec3: lightColor: RGB light intensity
//   MaterialParams mat:
//      - vec3: fakeSpecularColor: RGB color of the fake highlight
//      - float: fakeSpecularPower: Exponent controlling highlight sharpness
// Output:
//   - vec3: RGB stylized specular highlight contribution
// ==========================================

vec3 computeFakeSpecular(LightingContext ctx, MaterialParams mat) {
    vec3 H = normalize(ctx.lightDir + ctx.viewDir); // Halfway vector
    float highlight = pow(max(dot(ctx.normal, H), 0.0), mat.fakeSpecularPower);
    return highlight * mat.fakeSpecularColor * ctx.lightColor;
}
