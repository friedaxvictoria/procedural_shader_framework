<div class="container">
    <h1 class="main-heading">Rim Reflection Lighting Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/RimReflectionLighting_black.png" alt="Rim Lighting on Black Background" width="400" height="225">
<img src="../../../static/images/images4Shaders/RimReflectionLighting_Bayer.png" alt="Reflection Highlight with Bayer Background" width="400" height="225">

- **Category:** Lighting  
- **Shader Type:** Surface lighting effect (rim + reflection)  
- **Input Requirements:** `fragCoord`, `iResolution`, `iChannel1`  
- **Output:** Fragment color with rim light and environment reflection

---

## 📌 Notes

- This shader computes **rim lighting** (highlighting object edges facing away from the viewer) and **reflection** (sampling environment from `iChannel1`).
- Useful for **toon shading**, **highlight effects**, or **reflective surfaces** like plastic, glass, and wet materials.
- Uses a fake 3D sphere generated from 2D UVs to simulate surface normals.

---

## 🧠 Algorithm

### 🔷 Core Concept

- **Rim Lighting:**  
  A soft glow appears near edges (when `dot(N, viewDir)` is small). It is computed as:  
  `rim = max(0.0, 0.7 + dot(N, viewDir))`

- **Reflection:**  
  Computes reflection vector `reflect(dir, N)` and samples `iChannel1` to simulate environment reflection.

- Final color is a combination: `rimColor + reflection`

---

## 🎛️ Parameters

| Name          | Description                             | Type        | Example       |
|---------------|-----------------------------------------|-------------|----------------|
| `fragCoord`   | Fragment/pixel coordinate               | `vec2`      | Built-in       |
| `iResolution` | Viewport resolution                     | `vec2`      | uniform        |
| `iChannel1`   | Environment texture for reflection       | `sampler2D` | Bayer or HDRI  |

---

## 💻 Shader Code

```glsl
vec4 computeRimReflectionLighting(vec3 dir, vec3 N) {
    vec3 ref = reflect(dir, N);
    vec2 uv_ref = ref.xy * 0.5 + 0.5;

    float rim = max(0.0, 0.7 + dot(N, dir));
    vec4 rimColor = vec4(rim, rim * 0.5, 0.0, 1.0);
    vec4 reflection = texture(iChannel1, uv_ref) * 0.3;

    return rimColor + reflection;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord / iResolution.xy) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    float r = length(uv);
    if (r > 0.8) {
        fragColor = vec4(0.0);
        return;
    }

    vec3 N = normalize(vec3(uv, sqrt(1.0 - clamp(dot(uv, uv), 0.0, 1.0))));
    vec3 dir = normalize(vec3(uv, -1.0));

    vec4 lighting = computeRimReflectionLighting(dir, N);
    fragColor = lighting;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/Rim_lighting_and_reflection.glsl)


#### Engine Integrations

<div class="button-row">
  <a class="md-button" href="../../../../engines/unreal/lighting/rimLight">Unreal</a>
</div>