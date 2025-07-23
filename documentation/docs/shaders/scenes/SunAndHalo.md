<div class="container">
    <h1 class="main-heading">Sun and Halo Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/SunAndHalo.png" alt="Sun and Halo Shader Output" width="400" height="225">

- **Category:** Scene / Atmospheric Effect  
- **Input Requirements:** `fragCoord`, `iMouse`, `iResolution`  
- **Output:** HDR-tone-mapped sun disk and scattering halo over sky gradient

---

## 📌 Notes

- Renders a **realistic sun with halo** using physically inspired falloff, Mie scattering, and zenith-based atmospheric absorption.
- The sun position is **interactive via mouse input**, with fallback defaults.
- Suitable for **skyboxes**, **planet environments**, or **cinematic backgrounds**.
- Implements **Reinhard tone mapping** for HDR-to-LDR conversion.

---

## 🧠 Algorithm

### 🔷 Core Concept

This shader models the optical appearance of the sun with a glowing halo, combined with sky absorption effects. It is built around:

- A **sun disk intensity** model using `smoothstep` and distance
- **Mie scattering halo** with elevation-sensitive sharpness
- **Zenith-dependent atmospheric absorption**
- **HDR tone mapping** to compress values for final output
- Gradient-based sky background from dark blue at top to light at horizon

The result is a scene-level rendering of the sun and sky that reacts to camera view and sun height.

---

## 🎛️ Parameters

| Name         | Description                            | Type     | Example      |
|--------------|----------------------------------------|----------|--------------|
| `fragCoord`  | Fragment/pixel coordinate              | `vec2`   | Built-in     |
| `iMouse`     | Controls sun position (xy normalized)  | `vec4`   | uniform      |
| `iResolution`| Viewport resolution                    | `vec3`   | uniform      |
| `fov`        | Field of view (70° in radians)         | `float`  | tan(70°) ≈ 1.4 |

---

## 💻 Full Shader Code

```glsl
// ==========================================
// Shader: Sun and Halo Shader
// Category: Scene / Atmospheric Effect
// Description: Computes a realistic sun disk with halo and atmospheric absorption.
// Screenshot: screenshots/scenes/SunAndHalo.png
// ==========================================

const float PI = 3.14159265358979323846;
const float density = 0.5;
const float zenithOffset = 0.48;
const vec3 skyColor = vec3(0.37, 0.55, 1.0); // base sky color

#define zenithDensity(x) density / pow(max(x - zenithOffset, 0.0035), 0.75)
#define fov tan(radians(70.0))

float getSunPoint(vec2 p, vec2 lp) {
    return smoothstep(0.04 * (fov / 2.0), 0.026 * (fov / 2.0), distance(p, lp)) * 50.0;
}

float getMie(vec2 p, vec2 lp) {
    float sharpness = lp.y < 0.5 ? (lp.y + 0.5) * pow(0.05, 20.0) : 0.05;
    float disk = clamp(1.0 - pow(distance(p, lp), sharpness), 0.0, 1.0);
    return disk * disk * (3.0 - 2.0 * disk) * 0.25 * PI;
}

vec3 getSkyAbsorption(vec3 x, float y) {
    vec3 absorption = x * y;
    absorption = pow(absorption, 1.0 - (y + absorption) * 0.5) / x / y;
    return absorption;
}

vec3 jodieReinhardTonemap(vec3 c) {
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
    vec3 tc = c / (c + 1.0);
    return mix(c / (l + 1.0), tc, tc);
}

vec3 getAtmosphericSun(vec2 fragUV, vec2 lightUV) {
    float zenithFactor = zenithDensity(fragUV.y);
    float sunHeight = clamp(length(max(lightUV.y + 0.1 - zenithOffset, 0.0)), 0.0, 1.0);
    
    vec3 skyAbsorption = getSkyAbsorption(skyColor, zenithFactor);
    vec3 sunAbsorption = getSkyAbsorption(skyColor, zenithDensity(lightUV.y + 0.1));
    
    vec3 sunCore = getSunPoint(fragUV, lightUV) * skyAbsorption;
    vec3 mieHalo = getMie(fragUV, lightUV) * sunAbsorption;
    
    vec3 totalSky = sunCore + mieHalo;
    totalSky *= sunAbsorption * 0.5 + 0.5 * length(sunAbsorption);

    return jodieReinhardTonemap(totalSky);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float AR = iResolution.x / iResolution.y;
    vec2 uvMouse = iMouse.xy / iResolution.xy;
    uvMouse.x *= AR;
    if (uvMouse.y == 0.0) uvMouse.y = 0.7 - (0.05 * fov);
    if (uvMouse.x == 0.0) uvMouse.x = 1.0 - (0.05 * fov);

    vec2 uv = fragCoord.xy / iResolution.xy;
    uv.x *= AR;

    vec3 color = vec3(0.2, 0.3, 0.5) * (1.0 - uv.y);
    vec3 sunColor = getAtmosphericSun(uv, uvMouse);
    color += sunColor;

    fragColor = vec4(pow(color, vec3(1.0 / 2.2)), 1.0);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/scenes/SunAndHalo.glsl)
