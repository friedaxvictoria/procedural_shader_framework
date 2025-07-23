<div class="container">
    <h1 class="main-heading">Simplex Noise Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/simplex2d_noise.png" alt="Simplex Noise Example" width="500" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

- **Category:** Noise  
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
