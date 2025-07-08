# 🧩 Noise Shader

<img src="../../static/images/noise_preview.png" alt="Noise Shader Output" width="400" height="225">

---

- **Category:** Noise  
- **Author:** Xunyu Zhang
- **Shader Type:** Noise Function
- **Input Requirements:** `float`, `vec2`, `vec3`, `time`

---

## 🧠 Algorithm

### 🔷 Core Concept

`noise.glsl` is a compact, self-contained procedural noise utility file built on top of `hash.glsl`.  
It includes multiple noise styles useful for shading, texturing, and animation:

- **1D Value Noise** — Interpolated between hashed float values
- **2D Value Noise** — Grid-based hashing with smooth interpolation
- **Pseudo 3D Gradient Noise** — Perlin-like behavior over 2D using time as Z
- **n31()** — 3D-to-1D smoothed value noise (by Shane)
- **Voronoi Noise** — 2D cellular pattern with distortion control

All functions depend on `hash()` and `rand2()` from `hash.glsl`.

---

## 🎛️ Parameters

| Name     | Description                         | Range         | Default |
|----------|-------------------------------------|---------------|---------|
| `pos`    | Position to sample                  | `vec2`, `vec3`| —       |
| `distortion` | Voronoi cell jitter distortion | `[0.0, 1.0]`  | `0.5`   |
| `time`   | Used as `z` in pseudo3d noise       | float         | dynamic |

---

## 💻 Shader Code & Includes

```glsl
#include "shaders/noise/noise.glsl"

float n1 = noise(vec2(uv));             // 2D value noise
float n2 = noise(time);                 // 1D noise over time
float f  = Pseudo3dNoise(vec3(uv, t));  // animated pseudo 3D noise
float d  = n31(vec3(x, y, z));          // 3D hash-based noise
vec2 v   = voronoi(uv, 0.8);            // cell index and distance
