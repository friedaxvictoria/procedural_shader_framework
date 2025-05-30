// hash.glsl
// Provides pseudo-random hash functions for use in noise algorithms.

#ifndef HASH_GLSL
#define HASH_GLSL

// Hash function for float values
// Input: 
//   p - float : input value
// Output:
//   float : pseudo-random value in range [0, 1]
float hash(float p) {
    p = fract(p * 0.011);
    p *= p + 7.5;
    p *= p + p;
    return fract(p);
}

// Hash function for 2D vectors
// Input:
//   p - vec2 : input position
// Output:
//   float : pseudo-random value in range [0, 1]
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.13);
    p3 += dot(p3, p3.yzx + 3.333);
    return fract((p3.x + p3.y) * p3.z);
}

// ------------------------------------------------------------
// 4D Hash by Dave Hoskins – High-quality, no trig
// Source: Ruimin Ma / Shane / Dave Hoskins
// ------------------------------------------------------------
vec4 hash44(vec4 p) {
    p = fract(p * vec4(0.1031, 0.1030, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    return fract((p.xxyz + p.yzzw) * p.zywx);
}

vec2 hash22(vec2 p) {
    p = fract(p * vec2(5.3983, 5.4427));
    p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
    return fract(vec2(p.x * p.y * 95.4337, p.x + p.y));
}

// 2D → 1D pseudo-random scalar
// Input: vec2 p — grid position
// Output: float — random scalar in [0,1]
float rand(vec2 p) {
    return fract(sin(dot(p, vec2(445.5, 360.535))) * 812787.111);
}

// 2D → 2D pseudo-random vector generator
// Input: vec2 p — grid position
// Output: vec2 — random vector in [0,1]^2
vec2 rand2(vec2 p) {
    vec2 q = vec2(dot(p, vec2(120.0, 300.0)), dot(p, vec2(270.0, 401.0)));
    return fract(sin(q) * 46111.1111);
}


#endif
