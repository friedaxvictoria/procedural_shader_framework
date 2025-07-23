
<div class="container">
    <h1 class="main-heading">Glowing Star Overlay Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/GlowingStarOverlay.png" alt="Glowing Star Overlay Example" width="500" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

- **Category:** Noise 
- **Shader Type:** screen-space overlay  
- **Input Requirements:** `vec2 uv`, `iTime`, `iResolution`

---

## 🧠 Algorithm

### 🔷 Core Concept

This shader creates a **stylized center-based overlay**, combining:

- A soft **glowing radial gradient**
- A **5-pointed star** pattern based on angular modulation  
- Dynamic animation using `iTime`

It operates purely in **screen space** using normalized coordinates, making it suitable for HUDs, intros, or visual highlights.

---

## 🎛️ Parameters

| Name         | Description                             | Type     | Range         | Example         |
|--------------|-----------------------------------------|----------|---------------|-----------------|
| `uv`         | Normalized screen coordinates centered at (0,0) | `vec2`   | `[-1, 1]`     | `vec2(0.1, -0.2)` |
| `iTime`      | Global animation timer (Shadertoy style) | `float`  | `≥ 0.0`       | `1.57`          |
| `iResolution`| Output resolution                        | `vec2`   | screen size   | `vec2(800,600)` |

---

## 💻 Shader Code & Explanation

```glsl
#define PI 3.14159265359

vec4 computeNoiseOverlay(vec2 uv) {
    float P = PI / 5.0;

    // Angular star shape function (5-pointed)
    float starVal = (1.0 / P) * (P - abs(mod(atan(uv.x, uv.y) + PI, 2.0 * P) - P)));

    // Star color region
    vec4 starColor = (distance(uv, vec2(0.0)) < 0.06 - (starVal * 0.03))
        ? vec4(2.8, 1.0, 0.0, 1.0)
        : vec4(0.0);

    // Time-modulated glowing ring
    float glowFactor = max(0.0, 1.0 - distance(uv * 4.0, vec2(0.0)));
    vec4 glow = vec4(0.6, 0.2, 0.0, 1.0) * glowFactor * 4.0 * (0.2 + abs(sin(iTime)) * 0.8);

    return glow + starColor;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord / iResolution.xy) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;  // maintain aspect ratio

    vec4 overlay = computeNoiseOverlay(uv);
    fragColor = overlay;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/stylized_glow_and_star_shape.glsl)
