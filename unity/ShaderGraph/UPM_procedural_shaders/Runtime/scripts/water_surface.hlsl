#ifndef WATER_SURFACE_FILE
#define WATER_SURFACE_FILE

// ==========================================
// Shader: Procedural Water Surface Shader
// Category: Surface Rendering & Reflections
// Description: Generates a time-evolving water surface with procedural waves, SDF raymarching, and specular lighting. Adapted from "Dante's natty vessel" by evvvvil on ShaderToy
// URL: https://www.shadertoy.com/view/Nds3W7
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
 *   iMouse       - float2 : camera yaw/pitch control
 *   iChannel0    - sampler2D: noise texture for wave detail modulation
 *   iResolution  - float2 : screen resolution
 *
 * Output:
 *   float4 : RGBA pixel color with animated wave surface and visual depth cues
 */

// ---------- Global Configuration ----------
#include "global_variables.hlsl"

// ---------- Global State ----------
float waveStrength = 0.0;
// ---------- Utilities ----------

/**
 * Computes a 2D rotation matrix.
 */
float2x2 computeRotationMatrix(float angle)
{
    float c = cos(angle), s = sin(angle);
    return float2x2(c, s, -s, c);
}

/**
 * Hash-based procedural 3D noise.
 * Returns: float in [0,1]
 */
float hashNoise(float3 p)
{
    float3 f = floor(p), magic = float3(7, 157, 113);
    p -= f;
    float4 h = float4(0, magic.yz, magic.y + magic.z) + dot(f, magic);
    p *= p * (3.0 - 2.0 * p);
    h = lerp(frac(sin(h) * 43785.5), frac(sin(h + magic.x) * 43785.5), p.x);
    h.xy = lerp(h.xz, h.yw, p.y);
    return lerp(h.x, h.y, p.z);
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
float computeWave(float3 pos, int iterationCount)
{
    float3 warped = pos - float3(0, 0, _Time.y % 62.83 * 3.0);

    float direction = sin(_Time.y * 0.15);
    float angle = 0.001 * direction;
    float2x2 rotation = computeRotationMatrix(angle);

    float accum = 0.0, amplitude = 3.0;
    for (int i = 0; i < iterationCount; i++)
    {
        accum += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * (amplitude *= 0.51);
        warped.xy = mul(warped.xy, rotation);
        warped *= 1.75;
    }

    
    waveStrength = accum;

    float height = pos.y + accum;
    height *= 0.5;
    height += 0.3 * sin(_Time.y + pos.x * 0.3); // slight bobbing

    return height;
}

/**
 * Maps a point to distance field for raymarching.
 */
float2 evaluateDistanceField(float3 pos)
{
    return float2(computeWave(pos, 7), 5.0);
}

/**
 * Performs raymarching against the wave surface SDF.
 */
float2 traceWater(float3 rayOrigin, float3 rayDir)
{
    float2 d = float2(0.1, 0.1);
    float2 hit = float2(0.1, 0.1);
    for (int i = 0; i < 128; i++)
    {
        d = evaluateDistanceField(rayOrigin + rayDir * hit.x);
        if (d.x < 0.0001 || hit.x > 43.0)
            break;
        hit.x += d.x;
        hit.y = d.y;
    }
    if (hit.x > 43.0)
        hit.y = 0.0;
    return hit;
}

// ---------- Main Entry ----------

void computeWater_float(float2 uv, float3x3 camMatrix, out float3 fragColor, out float3 hitPos)
{
    float3 rayDirection = normalize(mul(float3(uv, -1), camMatrix));

    // Default background color
    float3 baseColor = float3(0.05, 0.07, 0.1);
    float3 color = baseColor;

    // Raymarching
    float2 hit = traceWater(_rayOrigin, rayDirection);
    
    if (hit.y > 0.0)
    {
        hitPos = _rayOrigin + rayDirection * hit.x;

        // Gradient-based normal estimation
        float3 grad = normalize(float3(
            computeWave(hitPos + float3(0.01, 0.0, 0.0), 7) -
            computeWave(hitPos - float3(0.01, 0.0, 0.0), 7),
            0.02,
            computeWave(hitPos + float3(0.0, 0.0, 0.01), 7) -
            computeWave(hitPos - float3(0.0, 0.0, 0.01), 7)
        ));

        // Fresnel-style highlight
        float fresnel = pow(1.0 - dot(grad, -rayDirection), 5.0);
        float highlight = clamp(fresnel * 1.5, 0.0, 1.0);

        // Water shading: deep vs bright
        float3 deepColor = float3(0.05, 0.1, 0.6);
        float3 brightColor = float3(0.1, 0.3, 0.9);
        float shading = clamp(waveStrength * 0.1, 0.0, 1.0);
        float3 waterColor = lerp(deepColor, brightColor, shading);

        // Add highlight
        waterColor += float3(1.0, 1, 1) * highlight * 0.4;

        // Depth-based fog
        float fog = exp(-0.00005 * hit.x * hit.x * hit.x);
        color = lerp(baseColor, waterColor, fog);
    }

    // Gamma correction
    fragColor = float3(pow(color, float3(0.55, 0.55, 0.55)));

}

#endif