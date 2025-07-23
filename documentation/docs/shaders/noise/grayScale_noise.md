<div class="container">
    <h1 class="main-heading">Grayscale Noise Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/grayScale_noise.png" alt="Grayscale Noise Example" width="500" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

- **Category:** Noise  
- **Shader Type:** 2D static noise  
- **Input Requirements:** `vec2`, `iTime`, `iResolution`

---

## 🧠 Algorithm

### 🔷 Core Concept

This shader generates animated **grayscale noise** using a simple hash-based method.  
Each pixel value is calculated by hashing its UV position with a `sin + dot` based pseudorandom function.

By multiplying UV with `sin(iTime)`, the noise becomes time-varying and animated.

---

## 🎛️ Parameters

| Name         | Description                                  | Type     | Range      | Example            |
|--------------|----------------------------------------------|----------|------------|--------------------|
| `fragCoord`  | Fragment position in screen space            | `vec2`   | pixel size | `vec2(400, 300)`   |
| `iResolution`| Screen resolution                            | `vec2`   | any        | `vec2(800, 600)`   |
| `iTime`      | Global animation time                        | `float`  | `≥ 0.0`     | `3.14`             |

---

## 💻 Shader Code

```glsl
// Simple 2D noise function
float noise2d(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(1.0, 73.0))) * 43758.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalize UV coordinates to [0,1]
    vec2 uv = fragCoord / iResolution.xy;

    // Animate UV with time-based warping
    uv = uv * sin(iTime);

    // Convert noise value to grayscale
    vec3 col = vec3(noise2d(uv));

    fragColor = vec4(col, 1.0);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/grayScale_noise.glsl)
