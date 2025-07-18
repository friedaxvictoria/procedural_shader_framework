# 🧩 1D Noise Shader (with 1D FBM)

<img src="https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/screenshots/noise/1d%20noise.png?raw=true" alt="1D FBM Noise Output" width="400" height="225">

---

- **Category:** Noise  
- **Author:** Morgan McGuire ([morgan3d](http://graphicscodex.com))  
- **License:** BSD License — reuse permitted  
- **Shader Type:** 1D Value Noise + Fractal FBM  
- **Input Requirements:** `fragCoord`, `iTime`, `iResolution`

---

## 🧠 Algorithm

### 🔷 Core Concept

This shader implements 1D interpolated value noise and FBM (Fractal Brownian Motion) using a classic hash-based method from Morgan McGuire. It is optimized to reduce periodicity and works well for both positive and negative domains.

It includes:

- `hash(float)` — precision-adjusted float hash function  
- `noise(float)` — classic 1D value noise  
- `fbm(float)` — layered 1D noise over multiple octaves  
- `mainImage()` — renders a horizontal waveform based on `fbm(x)`, animated over time

---

## 🎛️ Parameters

| Name            | Description                   | Type    | Example     |
|-----------------|-------------------------------|---------|-------------|
| `NUM_NOISE_OCTAVES` | Number of FBM octaves       | `#define` | `5`         |
| `iTime`         | Time input for animation       | `float` | uniform     |
| `iResolution`   | Screen resolution              | `vec2`  | uniform     |

---

## 💻 Full Shader Code

```glsl
// 1D noise
// By Morgan McGuire @morgan3d, http://graphicscodex.com
// Reuse permitted under the BSD license.

// All noise functions are designed for values on integer scale.
// They are tuned to avoid visible periodicity for both positive and
// negative coordinates within a few orders of magnitude.

#define NOISE fbm
#define NUM_NOISE_OCTAVES 5

float hash(float p) {
    p = fract(p * 0.011);
    p *= p + 7.5;
    p *= p + p;
    return fract(p);
}

float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
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

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float v = 0.0;
    float coord = fragCoord.x * 0.05 + iTime * 5.0 - 10.0;
    float height = NOISE(coord) * iResolution.y / 2.0;
    v = clamp((height - fragCoord.y + iResolution.y / 2.0) / (iResolution.y * 0.02), 0.0, 1.0);
    fragColor.rgb = pow(v, 0.35) * 1.3 * normalize(vec3(0.5, fragCoord.xy / iResolution.xy)) + vec3(v * 0.25);
}
