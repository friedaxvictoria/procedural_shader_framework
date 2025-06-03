// ==========================================
// Module: PBR Lighting Shader (Cook-Torrance GGX)
// Category: Lighting
// Description: 
//   Physically Based Rendering using Cook-Torrance BRDF with GGX distribution,
//   Schlick's Fresnel approximation, and Smith's geometry term (separable shadowing).
//   Supports roughness-metallic workflow for real-time applications.
// Input:
//   LightingContext ctx:
//      - vec3: normal: surface normal (unit vector)
//      - vec3: lightDir: direction vector from the surface point toward the light source (unit vector).
//      - vec3: viewDir: direction vector from the surface point toward the camera or viewer (unit vector).
//      - vec3: lightColor: RGB intensity of the incoming light.
//   MaterialParams mat:
//      - vec3: baseColor: base reflectance color of the surface. 
//      - float: roughness: surface microfacet roughness, in range [0.0, 1.0]. 
//      - float: metallic: material metallicity, in range [0.0, 1.0]. Non-metals use diffuse + specular,
// Output:
//   - vec3: Final physically-based RGB lighting contribution
// ==========================================

vec3 applyPBRLighting(LightingContext ctx, MaterialParams mat) {
    vec3 N = normalize(ctx.normal);
    vec3 V = normalize(ctx.viewDir);
    vec3 L = normalize(ctx.lightDir);
    vec3 H = normalize(L + V);
    vec3 F0 = mix(vec3(0.04), mat.baseColor, mat.metallic);

    float NDF = pow(mat.roughness + 1.0, 2.0);
    float a = NDF * NDF;
    float a2 = a * a;

    // GGX Normal Distribution Function (D)
    float NdotH = max(dot(N, H), 0.0);
    float D = a2 / (PI * pow((NdotH * NdotH) * (a2 - 1.0) + 1.0, 2.0));

    // Fresnel Schlick approximation (F)
    float HdotV = max(dot(H, V), 0.0);
    vec3 F = F0 + (1.0 - F0) * pow(1.0 - HdotV, 5.0);

    // Smith's Geometry Function (G)
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float k = pow(mat.roughness + 1.0, 2.0) / 8.0;
    float G_V = NdotV / (NdotV * (1.0 - k) + k);
    float G_L = NdotL / (NdotL * (1.0 - k) + k);
    float G = G_V * G_L;

    // Cook-Torrance BRDF
    vec3 specular = (D * F * G) / (4.0 * NdotL * NdotV + 0.001);

    // Diffuse (non-metallic only)
    vec3 kd = (1.0 - F) * (1.0 - mat.metallic);
    vec3 diffuse = kd * mat.baseColor / PI;

    // Final
    vec3 lighting = (diffuse + specular) * ctx.lightColor * NdotL;
    return lighting;
}
