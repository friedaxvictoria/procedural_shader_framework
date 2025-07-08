# 🧩 3D Perlin Gradient Noise Shader

<img src="https://github.com/saeedelsayed/Procedural-Shaders/blob/main/screenshots/noise/3d%20perlin%20noise.png?raw=true" alt="3D Perlin Noise Output" width="400" height="225">

---

- **Category:** Noise  
- **Shader Type:** Pseudo 3D Gradient Noise (Perlin-style)  
- **Input Requirements:** `vec3 pos (xy + time)`, `fragCoord`, `iTime`, `iResolution`  
- **Output:** Animated grayscale gradient noise

---

## 📌 Notes

- This is a **2D grid** gradient noise shader using **time as the Z dimension** (pseudo-3D).
- Gradient direction is randomized via `sin(dot(...))` without lookup textures.
- Good for dynamic flow fields, animated bump maps, stylized fluid noise.

---

## 🧠 Algorithm

### 🔷 Core Concept

This shader simulates **Perlin-style gradient noise** using:

- A **2D grid** of dynamically rotated gradient vectors  
- Time-dependent gradient rotation for pseudo-3D behavior  
- Smooth interpolation with Hermite blending (`f * f * (3 - 2f)`)

The result is a time-varying field of smooth noise between `[-1.0, 1.0]`, visualized as grayscale.

---

## 🎛️ Parameters

| Name         | Description                          | Type    | Example     |
|--------------|--------------------------------------|---------|-------------|
| `fragCoord`  | Fragment/pixel coordinate             | `vec2`  | Built-in    |
| `iTime`      | Global time (used as z in 3D input)   | `float` | uniform     |
| `iResolution`| Viewport resolution                   | `vec2`  | uniform     |

---

## 💻 Full Shader Code

```glsl
// ==========================================
// Shader: Perlin-3D Gradient Noise Shader
// Category: Noise
// Description: Generates time-varying 2D noise with pseudo-3D gradient noise using dynamic gradients.
// Uses Perlin-style gradient noise with time-animated gradients.
// Screenshot: screenshots/noise/3d perlin noise.png
// ==========================================

vec2 GetGradient(vec2 intPos, float t) {
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return vec2(cos(angle), sin(angle));
}

float Pseudo3dNoise(vec3 pos) {
    vec2 i = floor(pos.xy);
    vec2 f = pos.xy - i;
    vec2 blend = f * f * (3.0 - 2.0 * f);

    float noiseVal = 
        mix(
            mix(
                dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0, 0)),
                dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1, 0)),
                blend.x),
            mix(
                dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0, 1)),
                dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1, 1)),
                blend.x),
        blend.y
    );

    return noiseVal / 0.7; // normalize to [-1, 1]
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.y;
    float noiseVal = 0.5 + 0.5 * Pseudo3dNoise(vec3(uv * 10.0, iTime));
    fragColor.rgb = vec3(noiseVal);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/3D_Perlin_noise.glsl)
