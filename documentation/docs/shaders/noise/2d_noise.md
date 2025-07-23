# 🧩 2D Noise Shader with FBM

<img src="https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/screenshots/noise/2d%20noise.png?raw=true" alt="2D FBM Noise Output" width="400" height="225">

- **Category:** Noise
- **Author:** Wanzhang He 
- **Shader Type:** 2D Value Noise + Fractal Brownian Motion  
- **Input Requirements:** `fragCoord`, `iTime`, `iResolution`

---
## 📌 Notes

- FBM with rotation helps eliminate visible tiling and axis-aligned artifacts.  
- `NOISE` macro allows easy switching between single-octave and multi-octave variants.  
- Useful for cloud textures, stylized terrain, fire, or organic materials.
  
## 🧠 Algorithm

### 🔷 Core Concept

This shader visualizes smooth procedural textures using **hash-based value noise** and **FBM** (Fractal Brownian Motion).  

Key features:

- `hash(float)` / `hash(vec2)` — pseudo-random value generation  
- `noise(float)` / `noise(vec2)` — smooth interpolated value noise  
- `fbm(float)` / `fbm(vec2)` — multi-octave fractal accumulation  
- Time-based offsetting + rotation to animate and decorrelate patterns

The result is a vibrant, evolving noise field rendered in color.

---

## 🎛️ Parameters

| Name               | Description                     | Type     | Example        |
|--------------------|---------------------------------|----------|----------------|
| `iTime`            | Time for animation              | `float`  | uniform        |
| `iResolution`      | Screen resolution               | `vec2`   | uniform        |
| `fragCoord`        | Pixel coordinate                | `vec2`   | from mainImage |
| `NUM_NOISE_OCTAVES`| Octave count for FBM            | `int`    | 5              |
| `NOISE`            | Macro to toggle FBM vs base noise | macro  | `#define NOISE fbm` |

---

## 💻 Full Shader Code

```glsl
// ==========================================
// Shader: Procedural Noise with FBM
// Category: Noise Generation
// Description: Generates smooth procedural textures using hash-based noise and fractal Brownian motion (FBM).
// Screenshot: screenshots/noise/2d noise.png
// ==========================================

#define NOISE fbm
#define NUM_NOISE_OCTAVES 5

float hash(float p) {
    p = fract(p * 0.011);
    p *= p + 7.5;
    p *= p + p;
    return fract(p);
}

float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.13);
    p3 += dot(p3, p3.yzx + 3.333);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(float x) {
    float v = 0.0;
    float a = 0.5;
    float shift = float(100);
    for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
        v += a * noise(x);
        x = x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

float fbm(vec2 x) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 coord = fragCoord.xy * 0.1 - vec2(iTime * 5.0, iResolution.y / 2.0);
    float v = NOISE(coord);
    fragColor.rgb = pow(v, 0.35) * 1.3 * normalize(vec3(0.5, fragCoord.xy / iResolution.xy)) + vec3(v * 0.25);
}

```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/2D_noise.glsl)
