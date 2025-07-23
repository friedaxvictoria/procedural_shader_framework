# 🧩 Volumetric FBM Cloud Shader

<img src="https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/screenshots/cloud_fbm.png?raw=true" alt="Volumetric FBM Cloud Output" width="400" height="225">

- **Category:** Scene  
- **Author:** Wanzhang He  
- **Shader Type:** Procedural cloud via raymarching and 3D FBM  
- **Input Requirements:** `fragCoord`, `iResolution`, `iTime`  
- **Output:** Volumetric soft cloud rendered with 3D hash-based FBM

---

## 📌 Notes

- This shader renders **realistic volumetric clouds** using **hash-based 3D noise** with **fractal Brownian motion (FBM)**.
- Clouds are raymarched through a **procedural density field**, with height-dependent fade and soft edges.
- No textures are used — all detail is **generated algorithmically**.
- Ideal for **sky rendering**, **backgrounds**, or **atmospheric simulations**.

---

## 🧠 Algorithm

### 🔷 Core Concept

The clouds are modeled via:

- **Noise Field:** Hash-based 3D value noise used for FBM
- **FBM Perturbation:** Time-driven offset and rotation of noise layers
- **Height Fade:** Density fades in a band between `MIN_HEIGHT` and `MAX_HEIGHT`
- **Raymarching:** Iteratively samples along the ray to accumulate density
- **Gamma Correction:** Final color is tone-adjusted for display

---

## 🎛️ Parameters

| Name          | Description                              | Type     | Example            |
|---------------|------------------------------------------|----------|---------------------|
| `fragCoord`   | Fragment/pixel coordinate                | `vec2`   | Built-in            |
| `iResolution` | Viewport resolution                      | `vec2`   | uniform             |
| `iTime`       | Global time for animation                | `float`  | uniform             |
| `MIN_HEIGHT`  | Cloud base height                        | `float`  | `5000.0`            |
| `MAX_HEIGHT`  | Cloud top height                         | `float`  | `8000.0`            |
| `CLOUD_STEPS` | Steps taken during raymarching           | `int`    | `24`                |

---

## 💻 Shader Code

```glsl
float hash(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise3(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float n000 = hash(i + vec3(0.0, 0.0, 0.0));
    float n001 = hash(i + vec3(0.0, 0.0, 1.0));
    float n010 = hash(i + vec3(0.0, 1.0, 0.0));
    float n011 = hash(i + vec3(0.0, 1.0, 1.0));
    float n100 = hash(i + vec3(1.0, 0.0, 0.0));
    float n101 = hash(i + vec3(1.0, 0.0, 1.0));
    float n110 = hash(i + vec3(1.0, 1.0, 0.0));
    float n111 = hash(i + vec3(1.0, 1.0, 1.0));

    return mix(
        mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
        mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y),
        f.z);
}

float fnoise(vec3 p, float t) {
    p.xy += 3.0 * sin(t * 0.002 + p.z * 0.001);
    p.zx += 3.0 * cos(t * 0.002 + p.y * 0.001);

    float a = t * 0.002;
    float ca = cos(a), sa = sin(a);
    mat3 rotY = mat3(ca,0,-sa, 0,1,0, sa,0,ca);
    p = rotY * p;

    float f = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 6; i++) {
        f += amp * noise3(p);
        p *= 2.02 + 0.02 * sin(float(i) + t * 0.005);
        amp *= 0.5;
    }
    return f;
}

float cloud(vec3 p, float t) {
    float h = p.y;
    float heightFade = smoothstep(5000.0, 8000.0, h)
                     * (1.0 - smoothstep(8000.0, 10000.0, h));
    float d = fnoise(p * 0.0003, t);
    d = smoothstep(0.4, 0.65, d);
    return d * heightFade;
}

vec3 sampleCloudColor(vec3 rayOrigin, vec3 rayDir, float t) {
    vec3 col = vec3(0.0);
    for (int i = 0; i < 24; ++i) {
        float d = float(i) * 800.0;
        vec3 p = rayOrigin + rayDir * d;
        if (p.y < 5000.0 || p.y > 10000.0) continue;
        float dens = cloud(p, t);
        col += vec3(dens);
    }
    return col * 0.06;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float AR = iResolution.x / iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= AR;

    vec3 rayOrigin = vec3(0.0, 100.0, 0.0);
    vec3 rayDir = normalize(vec3(uv, -1.5));

    vec3 cloudColor = sampleCloudColor(rayOrigin, rayDir, iTime);
    vec3 color = cloudColor;

    fragColor = vec4(pow(color, vec3(1.0 / 2.2)), 1.0);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/scenes/cloud_fbm.glsl)
