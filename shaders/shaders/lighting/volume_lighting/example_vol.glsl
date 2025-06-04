// === CONFIGURATION ===
const float planetRadius = 6360.0;
const float atmosphereTop = 6420.0;
const float mieScaleHeight = 1.2;
const float rayleighScaleHeight = 8.0;
const float cloudBase = 2.0;
const float cloudThickness = 8.0;
const vec3 boxMin = vec3(-10.0, 0.0, -10.0);
const vec3 boxMax = vec3(10.0, 5.0, 10.0);
const float PI = 3.14159265359;

#define CLOUD_BASE (planetRadius + cloudBase)
#define CLOUD_TOP  (planetRadius + cloudBase + cloudThickness)

// === Simplex Noise === 
// Reference implementation from repo "shaders/noise/simplex_noise.glsl"
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }

float snoise(vec3 v) {
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    vec3 i = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);

    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    i = mod289(i);
    vec4 p = permute(permute(permute(
        i.z + vec4(0.0, i1.z, i2.z, 1.0))
        + i.y + vec4(0.0, i1.y, i2.y, 1.0))
        + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);

    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);

    vec4 norm = 1.79284291400159 - 0.85373472095314 *
        vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    vec4 m = max(0.6 - vec4(
        dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)
    ), 0.0);
    m = m * m;
    return 42.0 * dot(m * m, vec4(
        dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}
// === Simplex Noise End === 

// === FBM Density Map ===
float map(in vec3 p, int oct) {
    vec3 q = p - vec3(0.0, 0.1, 1.0) * iTime;

    float g = 0.5 + 0.5 * snoise(q * 0.3);

    float f;
    f = 0.5 * snoise(q); q *= 2.02;
    if (oct >= 2) f += 0.25 * snoise(q); q *= 2.23;
    if (oct >= 3) f += 0.125 * snoise(q); q *= 2.41;
    if (oct >= 4) f += 0.0625 * snoise(q); q *= 2.62;
    if (oct >= 5) f += 0.03125 * snoise(q);

    float h = clamp((p.y - CLOUD_BASE) / (CLOUD_TOP - CLOUD_BASE), 0.0, 1.0);
    float heightFalloff = smoothstep(0.0, 0.5, h) * (1.0 - smoothstep(0.3, 1.0, h));
    f = mix(f * 0.1 - 0.5, f, g * g);
    return clamp(f * heightFalloff + 0.1, 0.0, 1.0); 
}

// === Volume Sample ===
// Reference implementation from repo "shaders/lighting/volume_lighting/vol_integration.glsl"
struct VolumeSample {
    float density;
    float emission;
};
// === Volume Sample End ===

// === Volume Lighting ===
// Reference implementation from repo "shaders/lighting/volume_lighting/vol_lit_context.glsl"
struct VolCtxLocal {
    vec3 position;
    vec3 viewDir;
    vec3 lightDir;
    vec3 lightColor;
    vec3 ambient;
    float stepSize;
};

VolCtxLocal createVolCtxLocal(
    vec3 position,
    vec3 viewDir,
    vec3 lightDir,
    vec3 lightColor,
    vec3 ambient,
    float stepSize
) {
    VolCtxLocal ctx;
    ctx.position = position;
    ctx.viewDir = viewDir;
    ctx.lightDir = lightDir;
    ctx.lightColor = lightColor;
    ctx.ambient = ambient;
    ctx.stepSize = stepSize;
    return ctx;
}
// === Volume Lighting End ===

// === Volume Material ===
// Reference implementation from repo "shaders/material/volume_material/vol_mat_params.glsl"
struct VolMaterialParams {
    vec3 baseColor;         
    float densityScale;   
    float emissionStrength;   
    vec3 emissionColor;     
    float scatteringCoeff;   
    float absorptionCoeff;  
    float anisotropy;    
    float temperature;   
    float noiseStrength;  
};

// Reference implementation from repo "shaders/material/volume_material/vol_mat_presets.glsl"
VolMaterialParams makeDefault() {
    VolMaterialParams mat;
    mat.baseColor = vec3(1.5);
    mat.densityScale = 2.5;

    mat.emissionStrength = 0.0;
    mat.emissionColor = vec3(0.0);

    mat.scatteringCoeff = 3.0;
    mat.absorptionCoeff = 0.25;
    mat.anisotropy = 0.6;

    mat.temperature = 0.0;
    mat.noiseStrength = 0.3;
    return mat;
}

VolMaterialParams makeCloud(vec3 baseColor) {
    VolMaterialParams mat = makeDefault();
    mat.baseColor = baseColor;
    mat.densityScale = 1.0;

    mat.scatteringCoeff = 1.0;
    mat.absorptionCoeff = 0.2;
    mat.anisotropy = 0.6;

    mat.noiseStrength = 0.3;
    return mat;
}
// === Volume Material End ===

// === Phase Computations ===
// Reference implementation from repo "shaders/lighting/volume_lighting/phase.glsl"
float computePhaseIsotropic() {
    return 1.0 / (4.0 * PI);
}
// === Phase Computations End ===

// === Volumetric Cloud Lighting Computations ===
// Reference implementation from repo "shaders/lighting/volume_lighting/vol_lit.glsl"
vec4 applyVolLitCloud(
    VolumeSample s,
    VolCtxLocal ctx,
    VolMaterialParams mat
) {

    float cosTheta = dot(ctx.viewDir, ctx.lightDir);
    float phase = computePhaseIsotropic();                  // e.g., fog

    // === Scattering ===
    vec3 scatter = vec3(0.0);
    if (mat.scatteringCoeff > 0.0 && s.density > 0.0) {
        scatter = mat.baseColor * ctx.lightColor * phase * mat.scatteringCoeff * s.density;
    }

    // === Emission ===
    vec3 emission = vec3(0.0);
    if (mat.emissionStrength > 0.0 && s.emission > 0.0) {
        emission = mat.emissionColor * mat.emissionStrength * s.emission;
    }

    // === Ambient ===
    vec3 ambient = mat.baseColor * ctx.ambient * (0.2 + 0.8 * s.density);

    // === Absorption / Alpha ===
    float alpha = 1.0 - exp(-s.density * mat.absorptionCoeff * ctx.stepSize * 30.0);

    return vec4((scatter + emission + ambient) * (1.8 - alpha), alpha);
}

// Reference implementation from repo "shaders/lighting/volume_lighting/vol_integration.glsl"
vec4 integrateCloud(
    vec3 rayOrigin,
    vec3 rayDir,
    float rayLength,
    float stepCount,
    vec3 lightDir,
    vec3 lightColor,
    vec3 ambient,
    VolMaterialParams mat
) {
    const float yb = CLOUD_BASE;
    const float yt = CLOUD_TOP;
    float tb = (yb - rayOrigin.y) / rayDir.y;
    float tt = (yt - rayOrigin.y) / rayDir.y;

    float tmin, tmax;
    if (rayOrigin.y > yt) {
        if (tt < 0.0) return vec4(0.0);
        tmin = tt; tmax = tb;
    }
    else if (rayOrigin.y < yb) {
        if (tb < 0.0) return vec4(0.0);
        tmin = tb; tmax = tt;
    }
    else {
        tmin = 0.0;
        tmax = rayLength;
        if (tt > 0.0) tmax = min(tmax, tt);
        if (tb > 0.0) tmax = min(tmax, tb);
    }

    vec4 accum = vec4(0.0);

    float t = tmin + 0.1 * texelFetch(iChannel0, ivec2(gl_FragCoord.xy) & 1023, 0).x;

    for (int i = 0; i < int(stepCount); ++i) {
        float dt = max(0.05, 0.02 * t);
        vec3 p = rayOrigin + t * rayDir;

        float density = map(p, 5);
        if (density > 0.01) {
            VolumeSample s;
            s.density = density * mat.densityScale;
            s.emission = 0.0;

            VolCtxLocal ctx = createVolCtxLocal(
                p, -rayDir, lightDir, lightColor, ambient, dt
            );

            vec4 local = applyVolLitCloud(s, ctx, mat);       
            
            accum.rgb += (1.0 - accum.a) * local.a * local.rgb;
            accum.a += (1.0 - accum.a) * local.a;
        }

        t += dt;
        if (t > tmax || accum.a > 0.99) break;
    }

    return clamp(accum, 0.0, 1.0);
}
// === Volumetric Cloud Lighting Computations End ===

// === Volumetric Cloud Occlusion Computations ===
// Reference implementation from repo "shaders/lighting/volume_lighting/vol_occlusion.glsl"
float computeCloudOcclusion(vec3 startPos, vec3 lightDir) {
    const float maxDistance = 10.0;  
    const float stepSize = 0.3;  
    const float extinctionScale = 2.0;

    float t = 0.1;                 
    float accumulatedDensity = 0.0;

    for (int i = 0; i < 32; ++i) {
        vec3 samplePos = startPos + t * lightDir;
        float density = map(samplePos, 5); 
        accumulatedDensity += density * stepSize;

        t += stepSize;
        if (t > maxDistance) break;
    }

    float occlusion = 1.0 - exp(-accumulatedDensity * extinctionScale);
    return clamp(occlusion, 0.0, 1.0);
}

// === Material Construction ===
// Reference implementation from repo "shaders/material/material/material_params.glsl"
struct MaterialParams {
    vec3 baseColor;
    vec3 specularColor; 
    float specularStrength;
    float shininess;

    // Optional for PBR/stylized models
    float roughness;
    float metallic; 
    float rimPower;
    float fakeSpecularPower;
    vec3 fakeSpecularColor;

    // Optional for refractive/translucent materials
    float ior; 
    float refractionStrength; 
    vec3 refractionTint;
};

// Reference implementation from repo "shaders/material/material/material_presets.glsl"
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

    mat.ior = 1.45; 
    mat.refractionStrength = 0.0;
    mat.refractionTint = vec3(1.0);
    return mat;
}

MaterialParams makePlastic(vec3 color) {
    MaterialParams mat = createDefaultMaterialParams();
    mat.baseColor = color;
    mat.metallic = 0.0;
    mat.roughness = 0.4;
    mat.specularStrength = 0.5;
    return mat;
}
// === Material Construction End ===

// === Surface Lighting Computations ===
// Reference implementation from repo "shaders/lighting/surface_lighting/lighting_context.glsl"
struct LightingContext {
    vec3 position;
    vec3 normal;
    vec3 viewDir;
    vec3 lightDir;
    vec3 lightColor; 
    vec3 ambient; 
};

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

// Reference implementation from repo "shaders/lighting/surface_lighting/phong.glsl"
vec3 applyPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); 

    vec3 R = reflect(-ctx.lightDir, ctx.normal); 
    float spec = pow(max(dot(R, ctx.viewDir), 0.0), mat.shininess);

    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
}
// === Surface Lighting Computations End ===

// === mainImage ===
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // === Camera Position ===
    vec3 camPos = vec3(0.0, CLOUD_BASE -0.8, 0.0);

    // === Camera Orientation from Mouse ===
    vec2 m = (iMouse.xy == vec2(0.0)) ? vec2(0.5, 0.1) : iMouse.xy / iResolution.xy;
    float yaw = 6.2831 * (m.x - 0.5);
    float pitch = 1.5 * 3.1416 * (m.y - 0.5);

    float cosPitch = cos(pitch);
    vec3 forward = vec3(
        cosPitch * sin(yaw),
        sin(pitch),
        cosPitch * cos(yaw)
    );
    vec3 right = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
    vec3 up = normalize(cross(right, forward));
    mat3 camMat = mat3(right, up, forward);

    // === Ray Setup ===
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec3 rayDir = normalize(camMat * vec3(uv, 1.5));

    // === Light & Ambient Settings ===
    vec3 lightDir = normalize(vec3(0.3, 0.5, 0.2));
    vec3 lightColor = vec3(2.0, 2.2, 2.8);
    vec3 ambient = lightColor;

    // === Sky Background ===
    vec3 baseSky = mix(vec3(0.690, 0.878, 0.902), vec3(0.529, 0.808, 0.922), smoothstep(0.0, 0.5, rayDir.y));

    // === Ground Intersection and Lighting ===
    float groundHeight = planetRadius;
    float tGround = (groundHeight - camPos.y) / rayDir.y;
    bool hitGround = rayDir.y < -0.01 && tGround > 0.0;

    vec3 groundColor = vec3(0.08, 0.35, 0.05);
    if (hitGround) {
        vec3 hitPos = camPos + tGround * rayDir;
        vec3 normal = vec3(0.0, 1.0, 0.0);
         // === Cloud Occlusion ===
        float occlusion = computeCloudOcclusion(hitPos + normal * 0.1, lightDir);

        // === Apply Shading ===
        LightingContext ctx = createLightingContext(hitPos, normal, -rayDir, lightDir, lightColor, ambient);
        MaterialParams mat = makePlastic(groundColor);
        vec3 litColor = applyPhongLighting(ctx, mat);

        // === Mix with occlusion shadow ===
        vec3 shadowColor = vec3(0.05, 0.12, 0.04);
        groundColor = mix(litColor, shadowColor, occlusion);

        // === Optional: Tone Map ===
        groundColor = groundColor / (groundColor + vec3(2.3, 1.5, 2.3));
    }

    // === Cloud Volume Rendering ===
    VolMaterialParams cloudMat = makeCloud(vec3(1.0));
    vec4 cloudCol = integrateCloud(camPos, rayDir, 80.0, 96.0, lightDir, lightColor, ambient, cloudMat);

    // === Final Color Blending ===
    vec3 finalColor = vec3(0.0);
    
    bool toGround = rayDir.y < -0.01;
    bool toSky = rayDir.y > 0.01;
    bool hasCloud = (rayDir.y > 0.01 && camPos.y < CLOUD_BASE && camPos.y + rayDir.y * 1e4 > CLOUD_BASE) || 
                    (rayDir.y < -0.01 && camPos.y > CLOUD_TOP  && camPos.y + rayDir.y * 1e4 < CLOUD_TOP)  ||
                    (camPos.y >= CLOUD_BASE && camPos.y <= CLOUD_TOP); 
    
    if (toGround && !hasCloud) {
        finalColor = groundColor;
    }
    else if (toGround && hasCloud) {
        finalColor = mix(groundColor, cloudCol.rgb, cloudCol.a);
    }
    else if (toSky && hasCloud) {
        finalColor = mix(baseSky, cloudCol.rgb, cloudCol.a);
    }
    else {
        finalColor = baseSky; 
    }

    fragColor = vec4(clamp(finalColor, 0.0, 1.0), 1.0);
}
