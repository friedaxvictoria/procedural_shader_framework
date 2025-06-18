/*
 * Example Shader: Volumetric Clouds, Fog, and Height-Field Water
 *
 * Author: Fu Xuetong
 * Date: 2025-06-17
 * Source: 
 *   - Volumetric Cloud: Based on "Clouds" by Inigo Quilez (https://www.shadertoy.com/view/XslGRr)
 *   - Water Surface: Based on "Dante's natty vessel" by evvvvil (https://www.shadertoy.com/view/Nds3W7)
 *
 * Description:
 *   This example combines three major components into a unified scene:
 *     - Volumetric cloud rendering with noise-based density
 *     - Ground-level volumetric fog with distance and height attenuation
 *     - Procedural height-field water surface using hash-based noise
 */

// === CONFIGURATION ===
const float planetRadius = 6360.0;
const float atmosphereTop = 6420.0;
const float mieScaleHeight = 1.2;
const float rayleighScaleHeight = 8.0;
const float cloudBase = 3.0;
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

// === Density ===
// Constructed volumetric density by calling functions from the noise module
float CloudDensity(in vec3 p, int oct) {
    // Adapted from `example_vol.glsl`: original `map` function
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

float FogDensity(vec3 p, vec3 camPos) {
    float height = p.y - planetRadius;
    float heightFalloff = exp(-height * 0.2);
    float dist = length(p - camPos);
    float distFalloff = smoothstep(10.0, 80.0, dist);
    
    float noise = 0.8 + 0.2 * snoise(p * 0.05);
    return distFalloff * heightFalloff * noise;
}
// === Density End ===

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

VolMaterialParams makeFog(vec3 baseColor) {
    VolMaterialParams mat = makeDefault();
    mat.baseColor = baseColor;
    mat.densityScale = 0.5;

    mat.scatteringCoeff = 0.4;
    mat.absorptionCoeff = 0.05;
    mat.anisotropy = 0.0;

    mat.noiseStrength = 0.1;
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
    float phase = computePhaseIsotropic(); 

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

vec4 applyVolLitFog(
    VolumeSample s,
    VolCtxLocal ctx,
    VolMaterialParams mat
) {
    // === Phase Function Selection ===
    float cosTheta = dot(ctx.viewDir, ctx.lightDir);
    float phase = computePhaseIsotropic();

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
    vec3 ambient = mat.baseColor * ctx.ambient * (0.1 + 0.3 * s.density); 

    // === Absorption / Alpha ===
    float alpha = 1.0 - exp(-s.density * mat.absorptionCoeff * ctx.stepSize * 10.0);

    // === Final Color Composition ===
    vec3 color = scatter + emission + ambient;

    return vec4(color * (1.2 - alpha), alpha);
}

// Reference implementation from repo "shaders/lighting/volume_lighting/vol_integration.glsl"
vec4 integrateCloud(vec3 rayOrigin, vec3 rayDir, float rayLength,
                    float stepCount, vec3 lightDir, vec3 lightColor,
                    vec3 ambient, VolMaterialParams mat) {
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

        float density = CloudDensity(p, 5);
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

vec4 integrateFog(vec3 rayOrigin, vec3 rayDir, float rayLength,
                  float stepCount, vec3 lightDir, vec3 lightColor, 
                  vec3 ambient, VolMaterialParams mat) {
    vec4 accum = vec4(0.0);

    float jitter = fract(sin(dot(rayOrigin.xz, vec2(12.9898, 78.233))) * 43758.5453 + iTime);
    float t = 0.1 + 0.2 * jitter;

    for (int i = 0; i < int(stepCount); ++i) {
        float dt = 0.2;
        vec3 p = rayOrigin + t * rayDir;

        float density = FogDensity(p, rayOrigin);
        if (density > 0.001) {
            VolumeSample s;
            s.density = density * mat.densityScale;
            s.emission = 0.0;

            VolCtxLocal ctx = createVolCtxLocal(
                p, -rayDir, lightDir, lightColor, ambient, dt
            );

            vec4 local = applyVolLitFog(s, ctx, mat);

            accum.rgb += (1.0 - accum.a) * local.a * local.rgb;
            accum.a += (1.0 - accum.a) * local.a;
        }

        t += dt;
        if (t > rayLength || accum.a > 0.99) break;
    }

    return clamp(accum, 0.0, 1.0);
}
// === Volumetric Lighting Computations End ===

// === Volumetric Occlusion Computations ===
// Reference implementation from repo "shaders/lighting/volume_lighting/vol_occlusion.glsl"
float computeCloudOcclusion(vec3 startPos, vec3 lightDir) {
    const float maxDistance = 10.0;  
    const float stepSize = 0.3;  
    const float extinctionScale = 2.0;

    float t = 0.1;                 
    float accumulatedDensity = 0.0;

    for (int i = 0; i < 32; ++i) {
        vec3 samplePos = startPos + t * lightDir;
        float density = CloudDensity(samplePos, 5); 
        accumulatedDensity += density * stepSize;

        t += stepSize;
        if (t > maxDistance) break;
    }

    float occlusion = 1.0 - exp(-accumulatedDensity * extinctionScale);
    return clamp(occlusion, 0.0, 1.0);
}

float computeFogOcclusion(vec3 startPos, vec3 lightDir, vec3 rayOrigin) {
    const float maxDistance = 8.0; 
    const float stepSize = 0.25;
    const float extinctionScale = 1.2;

    float t = 0.1;
    float accumulatedDensity = 0.0;

    for (int i = 0; i < 32; ++i) {
        vec3 samplePos = startPos + t * lightDir;
        float fogDensity = FogDensity(samplePos, rayOrigin);
        accumulatedDensity += fogDensity * stepSize;

        t += stepSize;
        if (t > maxDistance) break;
    }

    float occlusion = 1.0 - exp(-accumulatedDensity * extinctionScale);
    return clamp(occlusion, 0.0, 1.0);
}
// === Volumetric Occlusion End ===

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

MaterialParams makeWater(vec3 color) {
    MaterialParams mat = createDefaultMaterialParams();
    mat.baseColor = color;
    mat.fakeSpecularColor = vec3(1.0);
    mat.fakeSpecularPower = 64.0;
    mat.specularColor = vec3(1.5);
    mat.specularStrength = 1.5; 
    mat.shininess = 64.0; 
    mat.ior = 1.333;
    mat.refractionStrength = 0.0;
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

// Reference implementation from repo "shaders/lighting/surface_lighting"
vec3 applyPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); 

    vec3 R = reflect(-ctx.lightDir, ctx.normal); 
    float spec = pow(max(dot(R, ctx.viewDir), 0.0), mat.shininess);

    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
}

vec3 computeFakeSpecular(LightingContext ctx, MaterialParams mat) {
    vec3 H = normalize(ctx.lightDir + ctx.viewDir); // Halfway vector
    float highlight = pow(max(dot(ctx.normal, H), 0.0), mat.fakeSpecularPower);
    return highlight * mat.fakeSpecularColor * ctx.lightColor;
}

// Adapted from repo "shaders/lighting/surface_lighting/blinn_phong.glsl"
vec3 applyBlinnPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0);
    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;

    vec3 H = normalize(ctx.lightDir + ctx.viewDir);
    float spec = pow(max(dot(ctx.normal, H), 0.0), mat.shininess);

    float fresnel = pow(1.0 - max(dot(ctx.normal, ctx.viewDir), 0.0), 3.0);

    vec3 specularColor = mix(mat.specularColor, vec3(1.0), fresnel);
    vec3 specular = spec * specularColor * mat.specularStrength * fresnel;

    diffuse = mix(diffuse, vec3(1.0), fresnel * 0.2);

    return ctx.ambient + diffuse + specular;
}

// === Surface Lighting Computations End ===

// === Water Surface ===
// Reference implementation from repo "shaders/WaterSurface.glsl"
float waveTime, globalTimeWrapped, noiseBias = 0.0, waveStrength = 0.0, globalAccum = 0.0;
vec3 controlPoint;

mat2 computeRotationMatrix(float angle) {
    float c = cos(angle), s = sin(angle);
    return mat2(c, s, -s, c);
}

float hashNoise(vec3 p) {
    vec3 f = floor(p), magic = vec3(7, 157, 113);
    p -= f;
    vec4 h = vec4(0, magic.yz, magic.y + magic.z) + dot(f, magic);
    p = p * p * (3.0 - 2.0 * p);
    h = mix(fract(sin(h) * 43785.5), fract(sin(h + magic.x) * 43785.5), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

float computeWave(vec3 pos, int iterationCount, float writeOut) {
    vec3 localPos = pos - vec3(0.0, planetRadius, 0.0);
    vec3 warped = localPos - vec3(0, 0, globalTimeWrapped * 3.0);

    float direction = sin(iTime * 0.15);
    float angle = 0.001 * direction;
    mat2 rotation = computeRotationMatrix(angle);

    float accum = 0.0, amplitude = 3.0;
    for (int i = 0; i < iterationCount; i++) {
        float n = hashNoise(warped * 0.3);
        // === Add ridge + sharpening control ===
        float ridge = 1.0 - abs(n - 0.5) * 2.0; 
        ridge = pow(ridge, 1.5);

        accum += ridge * (amplitude *= 0.51);
        warped.xy *= rotation;
        warped *= 1.75;
    }

    if (writeOut > 0.0) {
        controlPoint = warped;
        waveStrength = accum;
    }

    float height = localPos.y + accum;
    height *= 0.3;

    // Add up-down wave motion
    height += 0.3 * sin(iTime + pos.x * 0.3);

    return height + planetRadius;
}

vec4 sampleNoiseTexture(vec2 uv, sampler2D tex) {
    float f = 0.0;
    f += texture(tex, uv * 0.125).r * 0.5;
    f += texture(tex, uv * 0.25).r * 0.25;
    f += texture(tex, uv * 0.5).r * 0.125;
    f += texture(tex, uv * 1.0).r * 0.125;
    f = pow(f, 1.2);
    return vec4(f * 0.45 + 0.05);
}

vec2 evaluateDistanceField(vec3 pos, float writeOut) {
    float surfaceHeight = computeWave(pos, 7, writeOut);
    float dist = pos.y - surfaceHeight; // signed distance
    return vec2(dist, 5.0);
}

vec2 traceWater(vec3 rayOrigin, vec3 rayDir) {
    vec2 d, hit = vec2(0.1);
    for (int i = 0; i < 256; i++) {
        d = evaluateDistanceField(rayOrigin + rayDir * hit.x, 1.0);
        if (d.x < 0.0001 || hit.x > 200.0) break;
        hit.x += d.x;
        hit.y = d.y;
    }
    if (hit.x > 200.0) hit.y = 0.0;
    return hit;
}
// === Water Surface End ===

// === mainImage ===
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // === Time ===
    globalTimeWrapped = mod(iTime, 62.83);
    
    // === Camera Position ===
    vec3 camPos = vec3(0.0, planetRadius + 2.5, 0.0);

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
    
    // === Water Surface Intersect ===
    vec2 waterHit = traceWater(camPos, rayDir);
    bool hitWater = waterHit.y > 0.0;
    vec3 baseWater;
    vec3 lighting;
    
    if (hitWater) {
        vec3 hitPos = camPos + rayDir * waterHit.x;
        
     // === Fake normal from gradient ===
        float delta = 0.05;
        vec3 grad = normalize(vec3(computeWave(hitPos + vec3(delta, 0.0, 0.0), 7, 0.0) - computeWave(hitPos - vec3(delta, 0.0, 0.0), 7, 0.0), 
                                   0.5,
                                   computeWave(hitPos + vec3(0.0, 0.0, delta), 7, 0.0) - computeWave(hitPos - vec3(0.0, 0.0, delta), 7, 0.0)
                                   ));
        
        // === Occlusion ===
        float occCloud = computeCloudOcclusion(hitPos + grad * 0.1, lightDir);
        // float occFog = computeFogOcclusion(hitPos + grad * 0.1, lightDir, camPos);
        // float occ = clamp(occCloud + occFog, 0.0, 0.5); 
        
        // === Construct LightingContext ===
        LightingContext waterCtx = createLightingContext(hitPos, grad, -rayDir, normalize(lightDir), lightColor, vec3(0.05));

        // === Construct MaterialParams for Water ===
        MaterialParams waterMat = makeWater(vec3(0.05, 0.1, 0.2));

        // === Sample texture-based detail noise ===
        float texNoiseVal = sampleNoiseTexture(controlPoint.xz * 0.005, iChannel0).r +
                            sampleNoiseTexture(controlPoint.xz * 0.05, iChannel0).r * 0.5;

        // === Compute color from geometry + noise ===
        float shadingFactor = clamp(waveStrength * 0.1 + texNoiseVal * 0.8, 0.0, 1.0);
        vec3 baseColor = mix(waterMat.baseColor, vec3(0.1, 0.3, 0.9), shadingFactor);

        // === Compute Lighting ===
        // vec3 specular = computeFakeSpecular(waterCtx, waterMat);
        // baseWater = baseColor + specular;
        baseWater = applyBlinnPhongLighting(waterCtx, waterMat);
        
        // === Mix with occlusion shadow ===
        vec3 shadowColor = vec3(0.22, 0.28, 0.35);
        baseWater = mix(baseWater, shadowColor, occCloud * 0.3);
    }
    
    // === Cloud Volume Rendering ===
    VolMaterialParams cloudMat = makeCloud(vec3(1.0));
    vec4 cloudCol = integrateCloud(camPos, rayDir, 80.0, 96.0, lightDir, lightColor, ambient, cloudMat);

    // === Fog Volume Rendering ===
    VolMaterialParams fogMat = makeFog(vec3(0.95, 0.94, 0.90));
    vec4 fogCol = integrateFog(camPos, rayDir, 60.0, 72.0, lightDir, lightColor, ambient, fogMat);

    // === Final Color Blending ===
    vec3 finalColor = vec3(0.0);
    if (hitWater) {
        finalColor = baseWater;
        finalColor = mix(baseWater, fogCol.rgb, fogCol.a * 0.2);
        if (cloudCol.a > 0.01) {
            finalColor = mix(finalColor, cloudCol.rgb, cloudCol.a * 0.3);
        }
    }
    else {
        finalColor = baseSky;
        if (cloudCol.a> 0.01) {
            finalColor = mix(finalColor, cloudCol.rgb, cloudCol.a);
        }
        finalColor = mix(finalColor, fogCol.rgb, fogCol.a);
    }

    fragColor = vec4(clamp(finalColor, 0.0, 1.0), 1.0);
}