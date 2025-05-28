// === Struct Definitions ===
struct MaterialParams {
    vec3 baseColor;           // Diffuse/albedo base color
    vec3 specularColor;       // Specular reflection color
    float specularStrength;   // Specular intensity multiplier
    float shininess;          // Phong/Blinn specular exponent

    // Optional for PBR/stylized models
    float roughness;          // Surface microfacet roughness (PBR)
    float metallic;           // Degree of metallic reflection
    float rimPower;           // Exponent for rim lighting
    float fakeSpecularPower;  // Stylized highlight sharpness
    vec3 fakeSpecularColor;   // Stylized highlight color

    // Optional for refractive/translucent materials
    float ior;                // Index of Refraction (used in refraction)
    float refractionStrength; // Blending factor for refracted background
    vec3 refractionTint;     // Tint color applied to refracted background
};

struct LightingContext {
    vec3 position;
    vec3 normal;
    vec3 viewDir;
    vec3 lightDir;
    vec3 lightColor;
    vec3 ambient;
};

// === Material Creation ===
MaterialParams createDefaultMaterialParams() {
    MaterialParams mat;
    mat.baseColor = vec3(1.0);
    mat.specularColor = vec3(1.0);
    mat.specularStrength = 1.0;
    mat.shininess = 32.0;

    mat.roughness = 0.5;
    mat.metallic = 0.0;
    mat.rimPower = 2.0;
    mat.fakeSpecularPower = 32.0;
    mat.fakeSpecularColor = vec3(1.0);

    mat.ior = 1.45;                    // Typical plastic/glass
    mat.refractionStrength = 0.0;     // No refraction by default
    mat.refractionTint = vec3(1.0);
    return mat;
}

MaterialParams makePlastic(vec3 color) {
    MaterialParams mat = createDefaultMaterialParams();
    mat.baseColor = color;
    mat.specularColor = vec3(1.0);
    mat.specularStrength = 0.5;
    mat.shininess = 32.0;
    return mat;
}

// === Lighting Creation ===
LightingContext createLightingContext(
    vec3 position,
    vec3 normal,
    vec3 viewDir,
    vec3 lightDir,
    vec3 lightColor,
    vec3 ambient
) {
    LightingContext ctx;
    ctx.position = position;
    ctx.normal = normal;
    ctx.viewDir = viewDir;
    ctx.lightDir = lightDir;
    ctx.lightColor = lightColor;
    ctx.ambient = ambient;
    return ctx;
}

// === Using Phong Lighting As an Example ===
vec3 applyPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); // Lambert diffuse
    vec3 R = reflect(-ctx.lightDir, ctx.normal); // reflected direction
    float spec = pow(max(dot(R, ctx.viewDir), 0.0), mat.shininess); // Phong specular

    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;
    return ctx.ambient + diffuse + specular;
}

// === SDF: Sphere at origin ===
float map(vec3 p) {
    return length(p) - 1.0;
}

// === Estimate normal using finite differences ===
vec3 getNormal(vec3 p) {
    float eps = 0.001;
    vec2 e = vec2(1.0, -1.0) * 0.5773 * eps;
    return normalize(vec3(
        map(p + e.xyy) - map(p + e.yyy),
        map(p + e.yxy) - map(p + e.yyy),
        map(p + e.yyx) - map(p + e.yyy)
    ));
}

// === Raymarching ===
bool raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + rd * t;
        float d = map(p);
        if (d < 0.001) {
            hitPos = p;
            return true;
        }
        t += d;
        if (t > 10.0) break;
    }
    return false;
}

// === Main Image ===
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    vec3 ro = vec3(0.0, 0.0, 3.0);  // Camera origin
    vec3 rd = normalize(vec3(uv, -1.5)); // Camera direction

    vec3 color = vec3(0.0); // Background color
    vec3 hitpos;

    if (raymarch(ro, rd, hitpos)) {
        vec3 normal = getNormal(hitpos);
        vec3 viewDir = normalize(ro - hitpos);
        vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));
        vec3 lightColor = vec3(1.0);
        vec3 ambient = vec3(0.1);

        // Assemble lighting-related geometric and light information for shading
        LightingContext ctx = createLightingContext(hitpos, normal, viewDir, lightDir, lightColor, ambient);

        // Create a material with plastic-like properties using specified base color
        MaterialParams mat = makePlastic(vec3(0.4, 0.6, 1.0));

        // Compute final shading color using Phong lighting model
        color = applyPhongLighting(ctx, mat);
    }

    fragColor = vec4(color, 1.0);
}
