// fbm.glsl
// Provides Fractal Brownian Motion (FBM) based on interpolated noise.

#ifndef FBM_GLSL
#define FBM_GLSL

#include "noise.glsl"

// 1D FBM
// Input:
//   x        - float : input coordinate
//   octaves  - int   : number of noise layers (octaves)
// Output:
//   float : combined FBM value in range [0, 1] (not clamped)
float fbm(float x, int octaves) {
    float v = 0.0;
    float a = 0.5;
    float shift = 100.0;
    for (int i = 0; i < octaves; ++i) {
        v += a * noise(x);
        x = x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// 2D FBM
// Input:
//   x        - vec2 : input 2D coordinates
//   octaves  - int  : number of noise layers (octaves)
// Output:
//   float : combined 2D FBM value (typically in [0, 1], not clamped)
float fbm(vec2 x, int octaves) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5)); // Rotation to reduce axis-aligned artifacts
    for (int i = 0; i < octaves; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// ------------------------------------------
// Function: fbmPseudo3D
// Input:
//    - p: vec3 — position (xy), time as z
//    - octaves: int — number of noise layers
// Output:
//    - float — FBM result using Pseudo3dNoise
// ------------------------------------------
float fbmPseudo3D(vec3 p, int octaves) {
    float result = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; ++i) {
        result += amplitude * Pseudo3dNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return result;
}

// ------------------------------------------------------------
// FBM based on n31 3D noise (Shane's value noise)
// ------------------------------------------------------------
float fbm_n31(vec3 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < octaves; ++i) {
        value += amplitude * n31(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}



#endif
