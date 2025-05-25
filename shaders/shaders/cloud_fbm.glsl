// ==========================================
// Module: Procedural Volumetric Cloud Renderer Shader
// Category: Sky Rendering / Pure Function-Based Cloud
// Description: Raymarches soft FBM clouds using hash-based 3D noise.
// Screenshot: screenshots/cloud_fbm.png
// ==========================================

#define MIN_HEIGHT 5000.0
#define MAX_HEIGHT 8000.0
#define STEP_LENGTH 800.0
#define CLOUD_STEPS 24
#define PI 3.1415926

// 1. Hash-based 3D value noise (no texture needed)
float hash(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise3(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float n000 = hash(i + vec3(0.0, 0.0, 0.0));
    float n001 = hash(i + vec3(0.0, 0.0, 1.0));
    float n010 = hash(i + vec3(0.0, 1.0, 0.0));
    float n011 = hash(i + vec3(0.0, 1.0, 1.0));
    float n100 = hash(i + vec3(1.0, 0.0, 0.0));
    float n101 = hash(i + vec3(1.0, 0.0, 1.0));
    float n110 = hash(i + vec3(1.0, 1.0, 0.0));
    float n111 = hash(i + vec3(1.0, 1.0, 1.0));

    return mix(
        mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
        mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y),
        f.z);
}

// 2. FBM noise with perturbation and slow rotation
float fnoise(vec3 p, float t) {
    // slow perturbation
    p.xy += 3.0 * sin(t * 0.002 + p.z * 0.001);
    p.zx += 3.0 * cos(t * 0.002 + p.y * 0.001);

    // slow rotation
    float a = t * 0.002;
    float ca = cos(a), sa = sin(a);
    mat3 rotY = mat3(ca,0,-sa, 0,1,0, sa,0,ca);
    p = rotY * p;

    // FBM
    float f = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 6; i++) {
        f += amp * noise3(p);
        p *= 2.02 + 0.02 * sin(float(i) + t * 0.005);
        amp *= 0.5;
    }
    return f;
}

// 3. Cloud density
float cloud(vec3 p, float t) {
    float h = p.y;
    float heightFade = smoothstep(MIN_HEIGHT, MAX_HEIGHT, h)
                     * (1.0 - smoothstep(MAX_HEIGHT, MAX_HEIGHT + 2000.0, h));
    float d = fnoise(p * 0.0003, t);
    d = smoothstep(0.4, 0.65, d); // sharpen edge
    return d * heightFade;
}

// 4. Cloud sampling (raymarching)
vec3 sampleCloudColor(vec3 rayOrigin, vec3 rayDir, float t) {
    vec3 col = vec3(0.0);
    for (int i = 0; i < CLOUD_STEPS; ++i) {
        float d = float(i) * STEP_LENGTH;
        vec3 p = rayOrigin + rayDir * d;
        if (p.y < MIN_HEIGHT || p.y > MAX_HEIGHT + 2000.0) continue;
        float dens = cloud(p, t);
        col += vec3(dens);
    }
    return col * 0.06;
}

// 5. Main rendering
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float AR = iResolution.x / iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= AR;

    vec3 rayOrigin = vec3(0.0, 100.0, 0.0);  // camera position
    vec3 rayDir = normalize(vec3(uv, -1.5)); // looking slightly down

    vec3 cloudColor = sampleCloudColor(rayOrigin, rayDir, iTime);
    vec3 color = cloudColor; // background is black

    fragColor = vec4(pow(color, vec3(1.0 / 2.2)), 1.0); // gamma correction
}
