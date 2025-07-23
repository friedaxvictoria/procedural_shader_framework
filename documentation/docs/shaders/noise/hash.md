
<div class="container">
    <h1 class="main-heading">Hash Utility Functions</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/hash_function_visualization.png" alt="Hash Function Visualization" width="500" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

- **Category:** Noise 
- **Shader Type:** Hash & Random Number Generators  
- **Used In:** All procedural noise functions (value, gradient, voronoi, FBM, etc.)

---

## 🧠 Description

This module provides **pseudo-random hash functions** used throughout the procedural noise system.  
The output is deterministic but appears random, suitable for:

- Value noise  
- Gradient direction selection  
- Voronoi jittering  
- Texture-based random field generation

All outputs are in **[0, 1]** or **[0, 1]^n** range. No global state or uniform random is required.

---

## 🔑 Provided Functions

| Function     | Input Type | Output Type | Description                                   |
|--------------|------------|-------------|-----------------------------------------------|
| `hash(float)`| `float`    | `float`     | Scalar hash for 1D noise                      |
| `hash(vec2)` | `vec2`     | `float`     | Grid-based scalar hash                        |
| `hash44`     | `vec4`     | `vec4`      | High-quality 4D hash (Dave Hoskins method)    |
| `hash22`     | `vec2`     | `vec2`      | 2D vector hash with less symmetry             |
| `rand`       | `vec2`     | `float`     | Sinusoidal-based pseudo-random scalar         |
| `rand2`      | `vec2`     | `vec2`      | 2D pseudo-random vector (used in Voronoi)     |

---

## 💻 Shader Code

```glsl
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
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/hash.glsl)
### Example Use
```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv *= 10.0;                  // tile to show cells

    vec2 cell = floor(uv);
    vec2 local = fract(uv);

    // random offset for current cell
    vec2 randOffset = rand2(cell);

    // distance to random center in current cell
    float d = distance(local, randOffset);

    // color = based on distance to random center (circle visual)
    float brightness = smoothstep(0.1, 0.0, d);

    // random color per cell via rand()
    float cellColor = rand(cell);

    fragColor = vec4(vec3(cellColor * brightness), 1.0);
}
```
