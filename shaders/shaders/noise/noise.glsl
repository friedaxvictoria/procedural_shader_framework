// noise.glsl
// Provides interpolated 1D and 2D value noise based on hash functions.

#ifndef NOISE_GLSL
#define NOISE_GLSL

#include "hash.glsl"

// 1D Value Noise
// Input:
//   x - float : input coordinate
// Output:
//   float : interpolated pseudo-random noise in range [0, 1]
float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

// 2D Value Noise
// Input:
//   x - vec2 : input 2D coordinates
// Output:
//   float : interpolated 2D pseudo-random noise in range [0, 1]
float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// ------------------------------------------
// Function: GetGradient
// Input:
//    - intPos: vec2 — grid cell integer coordinate
//    - t: float — time variable for dynamic animation
// Output:
//    - vec2 — a rotated gradient vector based on position and time
// ------------------------------------------
vec2 GetGradient(vec2 intPos, float t) {
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return vec2(cos(angle), sin(angle));
}

// ------------------------------------------
// Function: Pseudo3dNoise
// Input:
//    - pos: vec3 — 2D position with time as z for pseudo-3D noise
// Output:
//    - float — noise value in [-1.0, 1.0] range
// Description:
//    Implements a Perlin-style gradient noise by interpolating
//    time-varying 2D gradient contributions.
// ------------------------------------------
float Pseudo3dNoise(vec3 pos) {
    vec2 i = floor(pos.xy);
    vec2 f = fract(pos.xy);
    vec2 blend = f * f * (3.0 - 2.0 * f);

    float a = dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0.0, 0.0));
    float b = dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1.0, 0.0));
    float c = dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0.0, 1.0));
    float d = dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1.0, 1.0));

    float xMix = mix(a, b, blend.x);
    float yMix = mix(c, d, blend.x);
    return mix(xMix, yMix, blend.y) / 0.7; // Normalize
}

// ------------------------------------------------------------
// 3D → 1D Value Noise by Shane – based on hash44
// ------------------------------------------------------------
float n31(vec3 p) {
    const vec3 S = vec3(7.0, 157.0, 113.0); // step vector: pairwise-prime
    vec3 ip = floor(p);
    p = fract(p);
    p = p * p * (3.0 - 2.0 * p); // Hermite smoother

    vec4 h = vec4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    h = mix(hash44(h), hash44(h + S.x), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

/**
 * Function: voronoi
 * Description:
 *   Generates Voronoi-style cell noise pattern from 2D position.
 *   Distortion value determines regularity of cells.
 * Input:
 *   - pos (vec2): Position to sample noise at.
 *   - distortion (float): Range [0..1], higher is more organic.
 * Output:
 *   - vec2: (color index, distance to border)
 */
vec2 voronoi(in vec2 pos, float distortion) {
    vec2 cell = floor(pos);
    vec2 cellOffset = fract(pos);
    float borderDist = 8.0;
    float color;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 samplePos = vec2(float(y), float(x));
            vec2 center = rand2(cell + samplePos) * distortion;
            vec2 r = samplePos - cellOffset + center;
            float d = dot(r, r);
            float col = rand(cell + samplePos);

            if (d < borderDist) {
                borderDist = d;
                color = col;
            }
        }
    }

    borderDist = 8.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 samplePos = vec2(float(i), float(j));
            vec2 center = rand2(cell + samplePos) * distortion;
            vec2 r = samplePos + center - cellOffset;

            if (dot(r, r) > 0.000001) {
                borderDist = min(borderDist, dot(0.5 * r, normalize(r)));
            }
        }
    }

    return vec2(color, borderDist);
}


#endif
