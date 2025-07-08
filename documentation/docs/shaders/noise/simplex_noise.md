# 🧩 Simplex Noise Shader

<img src="https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/screenshots/noise/simplex2d_noise.png" alt="Simplex Noise Example" width="400" height="225">

---

- **Category:** Noise  
- **Author:** Xunyu Zhang  
- **Shader Type:** simplex noise functions  
- **Input Requirements:** `vec2`, `vec3`

---

## 🧠 Algorithm

### 🔷 Core Concept

This module implements **2D and 3D Simplex noise**, a gradient noise technique developed by Ken Perlin.  
Compared to classic value noise, Simplex noise has:

- Better visual isotropy  
- Lower computational cost for higher dimensions  
- Fewer directional artifacts

This implementation is **periodic**, **tileable**, and suitable for both surface texturing and procedural animation.

---

## 🎛️ Parameters

| Name      | Description                        | Type    | Range        | Example        |
|-----------|------------------------------------|---------|--------------|----------------|
| `uv`      | Input position for 2D noise        | `vec2`  | UV space     | `vec2(0.3)`    |
| `pos3`    | Input position for 3D noise        | `vec3`  | 3D space     | `vec3(x,y,z)`  |

---

## 💻 Shader Code & Includes

```glsl
#include "shaders/noise/simplex_noise.glsl"

float s2 = simplexNoise(uv);        // 2D simplex noise
float s3 = simplexNoise(pos3);      // 3D simplex noise
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/simplex_noise.glsl)
