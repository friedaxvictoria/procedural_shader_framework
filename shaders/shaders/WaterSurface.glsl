// ==========================================
// Shader: Procedural Water Surface Shader
// Category: Surface Rendering & Reflections
// Description: Generates a time-evolving water surface with procedural waves, SDF raymarching, and specular lighting. Adapted from "Dante's natty vessel" by evvvvil on ShaderToy
// URL: https://www.shadertoy.com/view/Nds3W7
// Screenshot: screenshots/WaterSurface.png
// ==========================================

/*
 * This shader simulates an animated water surface using signed distance field (SDF) raymarching.
 * Procedural waves are generated using multi-octave hash-based noise, and visual features include:
 *
 * - computeWave(): Computes layered wave height field with time-based distortion.
 * - evaluateDistanceField(): Encodes the wave surface as an SDF for raymarching.
 * - traceWater(): Traces rays against the SDF surface to find intersection points.
 * - estimateNormal(): Approximates normals from SDF gradient for shading.
 * - sampleNoiseTexture(): Adds texture-based detail to enhance realism.
 * - Fresnel-based highlight + fog = pseudo-lighting and depth fading.
 *
 * Inputs:
 *   iTime        - float: animation time
 *   iMouse       - vec2 : camera yaw/pitch control
 *   iChannel0    - sampler2D: noise texture for wave detail modulation
 *   iResolution  - vec2 : screen resolution
 *
 * Output:
 *   vec4 : RGBA pixel color with animated wave surface and visual depth cues
 */

// ---------- Global Configuration ----------
#define CAMERA_POSITION vec3(0.0, 2.5, 8.0)

// ---------- Global State ----------
vec2 offsetA, offsetB = vec2(0.00035, -0.00035), dummyVec = vec2(-1.7, 1.7);
float waveTime, globalTimeWrapped, noiseBias = 0.0, waveStrength = 0.0, globalAccum = 0.0;
vec3 controlPoint, rotatedPos, wavePoint, surfacePos, surfaceNormal, texSamplePos;

// ---------- Utilities ----------

/**
 * Computes a 2D rotation matrix.
 */
mat2 computeRotationMatrix(float angle) {
    float c = cos(angle), s = sin(angle);
    return mat2(c, s, -s, c);
}

/**
 * Legacy rotation matrix from original shader (unused).
 */
const mat2 rotationMatrixSlow = mat2(cos(0.023), sin(0.023), -cos(0.023), sin(0.023));

/**
 * Hash-based procedural 3D noise.
 * Returns: float in [0,1]
 */
float hashNoise(vec3 p) {
    vec3 f = floor(p), magic = vec3(7, 157, 113);
    p -= f;
    vec4 h = vec4(0, magic.yz, magic.y + magic.z) + dot(f, magic);
    p *= p * (3.0 - 2.0 * p);
    h = mix(fract(sin(h) * 43785.5), fract(sin(h + magic.x) * 43785.5), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

// ---------- Wave Generation ----------

/**
 * Computes wave height using multi-octave sine-noise accumulation.
 *
 * Inputs:
 *   pos         - vec3 : world-space position
 *   iterationCount - int : number of noise layers
 *   writeOut    - float: whether to export internal wave variables
 *
 * Returns:
 *   float : signed height field
 */
float computeWave(vec3 pos, int iterationCount, float writeOut) {
    vec3 warped = pos - vec3(0, 0, globalTimeWrapped * 3.0);

    float direction = sin(iTime * 0.15);
    float angle = 0.001 * direction;
    mat2 rotation = computeRotationMatrix(angle);

    float accum = 0.0, amplitude = 3.0;
    for (int i = 0; i < iterationCount; i++) {
        accum += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * (amplitude *= 0.51);
        warped.xy *= rotation;
        warped *= 1.75;
    }

    if (writeOut > 0.0) {
        controlPoint = warped;
        waveStrength = accum;
    }

    float height = pos.y + accum;
    height *= 0.5;
    height += 0.3 * sin(iTime + pos.x * 0.3);  // slight bobbing

    return height;
}

/**
 * Maps a point to distance field for raymarching.
 */
vec2 evaluateDistanceField(vec3 pos, float writeOut) {
    return vec2(computeWave(pos, 7, writeOut), 5.0);
}

/**
 * Performs raymarching against the wave surface SDF.
 */
vec2 traceWater(vec3 rayOrigin, vec3 rayDir) {
    vec2 d, hit = vec2(0.1);
    for (int i = 0; i < 128; i++) {
        d = evaluateDistanceField(rayOrigin + rayDir * hit.x, 1.0);
        if (d.x < 0.0001 || hit.x > 43.0) break;
        hit.x += d.x;
        hit.y = d.y;
    }
    if (hit.x > 43.0) hit.y = 0.0;
    return hit;
}

/**
 * Constructs camera basis from forward and up vectors.
 */
mat3 computeCameraBasis(vec3 forward, vec3 up) {
    vec3 right = normalize(cross(forward, up));
    vec3 camUp = cross(right, forward);
    return mat3(right, camUp, forward);
}

/**
 * Samples layered noise from texture for detail enhancement.
 */
vec4 sampleNoiseTexture(vec2 uv, sampler2D tex) {
    float f = 0.0;
    f += texture(tex, uv * 0.125).r * 0.5;
    f += texture(tex, uv * 0.25).r * 0.25;
    f += texture(tex, uv * 0.5).r * 0.125;
    f += texture(tex, uv * 1.0).r * 0.125;
    f = pow(f, 1.2);
    return vec4(f * 0.45 + 0.05);
}

// ---------- Main Entry ----------

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord.xy / iResolution.xy - 0.5) / vec2(iResolution.y / iResolution.x, 1.0);
    globalTimeWrapped = mod(iTime, 62.83);

    // Orbit camera: yaw/pitch from mouse
    vec2 m = (iMouse.xy == vec2(0.0)) ? vec2(0.0) : iMouse.xy / iResolution.xy;
    float yaw = 6.2831 * (m.x - 0.5);
    float pitch = 1.5 * 3.1416 * (m.y - 0.5);
    float cosPitch = cos(pitch);

    vec3 viewDir = normalize(vec3(
        sin(yaw) * cosPitch,
        sin(pitch),
        cos(yaw) * cosPitch
    ));

    vec3 rayOrigin = CAMERA_POSITION;
    mat3 cameraBasis = computeCameraBasis(viewDir, vec3(0, 1, 0));
    vec3 rayDir = cameraBasis * normalize(vec3(uv, 1.0));

    // Default background color
    vec3 baseColor = vec3(0.05, 0.07, 0.1);
    vec3 color = baseColor;

    // Raymarching
    vec2 hit = traceWater(rayOrigin, rayDir);
    if (hit.y > 0.0) {
        surfacePos = rayOrigin + rayDir * hit.x;

        // Gradient-based normal estimation
        vec3 grad = normalize(vec3(
            computeWave(surfacePos + vec3(0.01, 0.0, 0.0), 7, 0.0) -
            computeWave(surfacePos - vec3(0.01, 0.0, 0.0), 7, 0.0),
            0.02,
            computeWave(surfacePos + vec3(0.0, 0.0, 0.01), 7, 0.0) -
            computeWave(surfacePos - vec3(0.0, 0.0, 0.01), 7, 0.0)
        ));

        // Fresnel-style highlight
        float fresnel = pow(1.0 - dot(grad, -rayDir), 5.0);
        float highlight = clamp(fresnel * 1.5, 0.0, 1.0);

        // Texture detail sampling
        float texNoiseVal = sampleNoiseTexture(controlPoint.xz * 0.0005, iChannel0).r +
                            sampleNoiseTexture(controlPoint.xz * 0.005, iChannel0).r * 0.5;

        // Water shading: deep vs bright
        vec3 deepColor = vec3(0.05, 0.1, 0.2);
        vec3 brightColor = vec3(0.1, 0.3, 0.9);
        float shading = clamp(waveStrength * 0.1 + texNoiseVal * 0.8, 0.0, 1.0);
        vec3 waterColor = mix(deepColor, brightColor, shading);

        // Add highlight
        waterColor += vec3(1.0) * highlight * 0.4;

        // Depth-based fog
        float fog = exp(-0.00005 * hit.x * hit.x * hit.x);
        color = mix(baseColor, waterColor, fog);
    }

    // Gamma correction
    fragColor = vec4(pow(color + globalAccum * 0.2 * vec3(0.7, 0.2, 0.1), vec3(0.55)), 1.0);
}
