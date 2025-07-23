
<div class="container">
    <h1 class="main-heading">Noise Shader Collection</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

- **Category:** Noise
- **Shader Type:** noise functions
- **Input Requirements:** `float`, `vec2`, `vec3`, `time`

---

## 🧠 Algorithm

### 🔷 Core Concept

This shader module combines multiple fundamental noise generation methods into a single file.  
It depends on `hash.glsl` and provides both classic and advanced procedural noise techniques:

- `noise(float)` — 1D interpolated value noise  
- `noise(vec2)` — 2D grid-based value noise  
- `Pseudo3dNoise(vec3)` — 2D gradient noise animated over time (pseudo-3D)  
- `n31(vec3)` — 3D → 1D value noise using Shane’s hash44 technique  
- `voronoi(vec2, float)` — 2D Voronoi cell noise with adjustable distortion

These functions support animation, spatial structure, and fractal combination.

---

## 🎛️ Parameters

| Name         | Description                           | Type     | Range         | Example     |
|--------------|---------------------------------------|----------|---------------|-------------|
| `x`          | Input for 1D value noise              | `float`  | –             | `0.5`       |
| `uv`         | Input for 2D value noise or voronoi   | `vec2`   | UV range      | `vec2(0.3)` |
| `pos`        | Input for 3D value or pseudo noise    | `vec3`   | –             | `vec3(x,y,t)`|
| `distortion` | Voronoi distortion factor             | `float`  | `[0.0, 1.0]`  | `0.8`       |

---

## 💻 Shader Code & Includes

```glsl
#include "shaders/noise/noise.glsl"

float n1 = noise(uv);                    // 2D value noise
float n2 = Pseudo3dNoise(vec3(uv, t));   // animated pseudo-3D noise
float n3 = n31(vec3(x, y, z));           // 3D-to-1D value noise
vec2 v  = voronoi(uv, 0.5);              // Voronoi result: (colorID, borderDist)
```

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/noise.glsl)
