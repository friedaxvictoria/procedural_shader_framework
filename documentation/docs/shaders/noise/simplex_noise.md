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

### 1. Overview & Includes

This module provides efficient 2D and 3D implementations of **Simplex Noise**,  a gradient-based noise algorithm that improves on classic Perlin noise by offering:

- Better visual coherence (less directional artifacts)
- Improved computational efficiency
- Gradient-based natural randomness
  
```glsl
#include "shaders/noise/simplex_noise.glsl"

float s2 = simplexNoise(uv);        // 2D simplex noise
float s3 = simplexNoise(pos3);      // 3D simplex noise
```

### 2. 2D Simplex noise

Generates smooth 2D Simplex noise using a skewed triangle grid.

- `v`: Input 2D coordinates  
- Returns: Float in roughly `[-1.0, 1.0]`  
- Uses a permutation scheme and gradient vectors for smooth randomness  
- Applications: Procedural textures, terrain, UV distortion

```glsl
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}

float snoise(vec2 v)
{
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0

    vec2 i = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    i = mod289(i); 
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
        + i.x + vec3(0.0, i1.x, 1.0));

    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}
```

### 3. 3D Simplex noise

Generates 3D Simplex noise using tetrahedral cells and gradient vectors.

- `v`: Input 3D coordinate  
- Returns: Float in roughly `[-1.0, 1.0]`  
- Optimized for coherent volumetric noise  
- Applications: Volumetric fog, clouds, organic distortion
  
```glsl
vec4 mod289(vec4 x) { 
    return x - floor(x * (1.0 / 289.0)) * 289.0; 
}

vec3 mod289(vec3 x) { 
    return x - floor(x * (1.0 / 289.0)) * 289.0; 
}

vec4 permute(vec4 x) { 
    return mod289(((x * 34.0) + 1.0) * x); 
}

float snoise(vec3 v) {
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    vec3 i = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);

    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    i = mod289(i);
    vec4 p = permute(permute(permute(
        i.z + vec4(0.0, i1.z, i2.z, 1.0))
        + i.y + vec4(0.0, i1.y, i2.y, 1.0))
        + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);

    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);

    vec4 norm = 1.79284291400159 - 0.85373472095314 *
        vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    vec4 m = max(0.6 - vec4(
        dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m * m, vec4(
        dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/simplex_noise.glsl)
