# 🧩 3D Noise Shader Functions

---

<img src="https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/screenshots/noise/3D_noise.png" alt="3D Noise Example" width="400" height="225">

- **Category:** Noise  
- **Author:** Xuetong Fu  
- **Shader Type:** 3D procedural noise + texture sampling  
- **Input Requirements:** `vec3`, `sampler3D`, `sampler2D`, `scales[]`, `iTime`

---

## 🧠 Algorithm

### 🔷 Core Concept

This module defines several **3D noise generation methods** using both 3D textures and simulated 3D sampling from 2D textures. These techniques are foundational for:

- Volumetric cloud rendering  
- Terrain and density field generation  
- Procedural texture effects  

It also provides an **FBM-based noise** method that allows for **octave scaling** and **temporal evolution**.

---

## 🎛️ Parameters

| Name            | Description                                  | Type        | Example                  |
|-----------------|----------------------------------------------|-------------|--------------------------|
| `x`, `p`        | 3D sampling position                         | `vec3`      | `vec3(x, y, z)`          |
| `texture3DInput`| Input 3D texture                             | `sampler3D` | `texture3DInput`         |
| `texture2DInput`| Input 2D texture                             | `sampler2D` | `texture2DInput`         |
| `oct`           | Number of FBM octaves                        | `int`       | `5`                      |
| `scales[]`      | Frequency scaling per octave                 | `float[8]`  | `[2.0, 2.3, 2.7, ...]`   |
| `iTime`         | Animation time (for dynamic FBM)             | `float`     | `3.14`                   |

---

## 💻 Shader Code

```glsl
uniform sampler3D texture3DInput;
uniform sampler2D texture2DInput;
uniform float scales[8];
uniform float iTime;

// Sample noise from a 3D texture (trilinear interpolation)
float texture3DInterNoise(in vec3 x, sampler3D texture3DInput) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    x = p + f;
    return textureLod(texture3DInput, (x + 0.5) / 32.0, 0.0).x * 2.0 - 1.0;
}

// Simulated 3D noise by sampling 2D texture, using layered offsets
float dis3DSampling2DNoise(in vec3 x, sampler2D texture2DInput) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    vec2 uv = (p.xy + vec2(37.0, 239.0) * p.z) + f.xy;
    vec2 rg = textureLod(texture2DInput, (uv + 0.5) / 256.0, 0.0).yx;
    return mix(rg.x, rg.y, f.z) * 2.0 - 1.0;
}

// Bilinear fetch and Z interpolation from texelFetch on 2D
float sample3Dfrom2DNoise(in vec3 x, sampler2D texture2DInput) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    ivec3 q = ivec3(p);
    ivec2 uv = q.xy + ivec2(37, 239) * q.z;
    vec2 rg = mix(
        mix(texelFetch(texture2DInput, (uv) & 255, 0),
            texelFetch(texture2DInput, (uv + ivec2(1, 0)) & 255, 0), f.x),
        mix(texelFetch(texture2DInput, (uv + ivec2(0, 1)) & 255, 0),
            texelFetch(texture2DInput, (uv + ivec2(1, 1)) & 255, 0), f.x),
        f.y).yx;
    return mix(rg.x, rg.y, f.z) * 2.0 - 1.0;  
}

// Time-varying FBM with octave scaling (uses external noise())
float fbm3D(in vec3 p, int oct) {
    if (oct > 8) return 0.0;

    vec3 q = p - vec3(0.0, 0.1, 1.0) * iTime; 
    float g = 0.5 + 0.5 * noise(q * 0.3);
    float f = 0.5 * noise(q);
    float amp = 0.5;

    for (int i = 1; i < oct; i++) {
        f += amp * noise(q);
        q *= scales[i - 1];
        amp *= 0.5;
    }

    f += amp * noise(q);
    f = mix(f * 0.1 - 0.5, f, g * g);
    return 1.5 * f - 0.5 - p.y;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/3D_noise.glsl)
