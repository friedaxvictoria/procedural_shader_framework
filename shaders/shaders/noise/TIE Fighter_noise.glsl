// Shader: TIE Fighter Noise
// Category: Noise
// Description:
//   Stand‑alone module holding lightweight hash / noise functions shared by
//   the TIE‑Fighter shader suite.
//
//   It includes:
//     – hash44 : 4‑D hash by Dave Hoskins (no trig)
//     – n31    : 3‑D → 1‑D value noise by Shane
// From Ruimin Ma

#ifndef TF_NOISE_UTILS_GLSL
#define TF_NOISE_UTILS_GLSL

//------------------------------------------------------------
// 1. 4‑D Hash – Dave Hoskins (no trig, high quality)
//------------------------------------------------------------
vec4 hash44(vec4 p)
{
    p = fract(p * vec4(0.1031, 0.1030, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    return fract((p.xxyz + p.yzzw) * p.zywx);
}

//------------------------------------------------------------
// 2. 3‑D → 1‑D Value Noise – Shane
//------------------------------------------------------------
float n31(vec3 p)
{
    // Large, pair‑wise‑prime step vector
    const vec3 S = vec3(7.0, 157.0, 113.0);

    // Integer lattice cell & local position
    vec3 ip = floor(p);
    p       = fract(p);

    // Hermite cubic smoother
    p = p * p * (3.0 - 2.0 * p);

    // Hash four corners of the cube, then trilinear blend
    vec4 h = vec4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    h = mix(hash44(h), hash44(h + S.x), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

#endif // TF_NOISE_UTILS_GLSL