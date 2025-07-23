# 🧩 Fractal Brownian Motion (FBM) Shader

<img src="https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/screenshots/noise/2d_FBM_effect.png?raw=true" alt="2D FBM Effect" width="400" height="225">

- **Category:** Noise  
- **Author:** Wanzhang He 
- **Shader Type:** Fractal / Multi-octave noise  
- **Input Requirements:** `float`, `vec2`, `vec3`, `noise()`, `Pseudo3dNoise()`, `n31()`

---

## 🧠 Algorithm

### 🔷 Core Concept

**Fractal Brownian Motion (FBM)** combines multiple layers (*octaves*) of noise to produce rich, natural-looking patterns.

This module provides several FBM variants:

- `fbm(float, int)` – 1D FBM using scalar value noise  
- `fbm(vec2, int)` – 2D FBM with rotation to reduce artifacts  
- `fbmPseudo3D(vec3, int)` – animated pseudo-3D FBM (e.g., for time-evolving textures)  
- `fbm_n31(vec3, int)` – FBM built from Shane’s `n31()` 3D value noise

---

## 🎛️ Parameters

| Name       | Description                             | Type     | Example             |
|------------|-----------------------------------------|----------|---------------------|
| `x`        | 1D input coordinate                     | `float`  | `fbm(0.5, 4)`       |
| `x`        | 2D input coordinate                     | `vec2`   | `fbm(uv, 5)`        |
| `p`        | 3D position + time (for animation)      | `vec3`   | `fbmPseudo3D(vec3(x,y,t), 5)` |
| `octaves`  | Number of layers to blend               | `int`    | `4`, `6`, etc.      |

---

## 💻 Shader Code
```glsl
#ifndef FBM_GLSL
#define FBM_GLSL

#include "noise.glsl"

// 1D FBM
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
float fbm(vec2 x, int octaves) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
    for (int i = 0; i < octaves; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// 3D FBM using Pseudo3dNoise
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

// 3D FBM using n31 value noise
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
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/fbm.glsl)
### Example Use
```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalize pixel coordinates to [0,1]
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Center and scale UV coordinates for better detail visibility
    vec2 pos = (uv - 0.5) * 4.0;

    // Add time-based animation offset
    pos += vec2(iTime * 0.1, 0.0);

    // Compute 2D fractal Brownian motion (FBM) noise
    float f = fbm(pos, 6);

    // Map FBM value to grayscale color
    vec3 color = vec3(f);

    fragColor = vec4(color, 1.0);
}
```
