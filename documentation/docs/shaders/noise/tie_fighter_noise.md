# 🧩 TIE Fighter Noise Shader


- **Category:** Noise  
- **Author:** Ruimin Ma  
- **Shader Type:** utility / hash / value noise  
- **Input Requirements:** `vec3`, `vec4`

---

## 🧠 Algorithm

### 🔷 Core Concept

This shader module provides compact, high-performance hash and noise utilities used in the **TIE‑Fighter shader suite**.

It includes two core components:

- `hash44(vec4)` — a 4D hash function by Dave Hoskins  
- `n31(vec3)` — a 3D-to-1D value noise by Shane  

These functions are **standalone**, **trig-free**, and optimized for efficiency and quality in GPU procedural generation.

---

## 🎛️ Parameters

| Name   | Description                      | Type    | Range      | Example         |
|--------|----------------------------------|---------|------------|-----------------|
| `p`    | Input vector (vec3 or vec4)      | `vec3` / `vec4` | any     | `vec3(x,y,z)` / `vec4(x,y,z,w)` |

---

## 💻 Shader Code & Explanation

```glsl
#ifndef TF_NOISE_UTILS_GLSL
#define TF_NOISE_UTILS_GLSL

// 1. 4‑D Hash – Dave Hoskins
vec4 hash44(vec4 p)
{
    p = fract(p * vec4(0.1031, 0.1030, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    return fract((p.xxyz + p.yzzw) * p.zywx);
}

// 2. 3‑D → 1‑D Value Noise – Shane
float n31(vec3 p)
{
    const vec3 S = vec3(7.0, 157.0, 113.0); // pairwise-prime steps
    vec3 ip = floor(p);     // lattice cell
    p = fract(p);           // local position

    // Hermite interpolation
    p = p * p * (3.0 - 2.0 * p);

    // Hash 4 cube corners and interpolate
    vec4 h = vec4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    h = mix(hash44(h), hash44(h + S.x), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

#endif // TF_NOISE_UTILS_GLSL
```
