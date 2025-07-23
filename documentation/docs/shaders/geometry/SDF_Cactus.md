<div class="container">
    <h1 class="main-heading">SDF Cactus Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/SDF_Cactus.png" alt="Cactus Shader Output" width="400" height="225">

- **Category:** Geometry  
- **Input Requirements:** `fragCoord`, `iResolution`  
- **Output:** Procedural cactus with branches and spines using capsule-based SDF  

---

## 📌 Notes

- This shader renders a **3D cactus** using **Signed Distance Fields (SDF)** and **capsule primitives**.  
- Includes a vertical stem and two horizontal arms.  
- Adds **simplex noise** to deform the cactus surface.  
- Also adds **spiky decorations (spines)** using small sphere SDFs.  
- Basic **Lambert shading** is applied based on estimated normals.

---

## 🧠 Algorithm

### 🌵 Core Concept

- Main body and arms are constructed from **capsule shapes**.  
- Shape is rotated using **axis-angle to matrix conversion**.  
- **Noise-based perturbation** adds realism to the surface.  
- **Spines** are placed as small spheres distributed along the stem.  
- Raymarching is used to find surface hits, and **central difference** computes normals.

---

## 🎛️ Parameters

| Name                   | Description                              | Type     | Example Value           |
|------------------------|------------------------------------------|----------|--------------------------|
| `fragCoord`            | Fragment/pixel coordinate                | `vec2`   | Built-in                 |
| `iResolution`          | Screen resolution                        | `vec2`   | uniform                  |
| `position`             | Base world-space position of cactus      | `vec3`   | `vec3(0.0, -0.2, -2.2)`  |
| `height`               | Vertical height of the cactus stem       | `float`  | `0.8`                    |
| `radius`               | Radius of cactus body and arms           | `float`  | `0.1`                    |
| `axis`, `angle`        | Rotation axis and angle (degrees)        | `vec3`, `float` | `vec3(1,0,0)`, `0.0`  |
| `baseColor`            | Surface color of the cactus              | `vec3`   | `vec3(0.2, 0.5, 0.2)`    |
| `specularColor`        | Specular highlight color                 | `vec3`   | `vec3(0.05)`             |
| `specularStrength`     | Strength of specular lighting            | `float`  | `0.2`                    |
| `shininess`            | Phong shininess value                    | `float`  | `32.0`                   |
| `noiseAmount`          | Amplitude of surface noise               | `float`  | `0.25`                   |

---

## 💻 Shader Code

```glsl
float sdCapsule(vec3 p, float h, float r) {
  p.y -= clamp(p.y, 0.0, h);
  return length(p) - r;
}

float evalCactusSDF(int i, vec3 p) {
  vec3 probePt = transpose(_sdfRotation[i]) * (p - _sdfPositionFloat[i]);
  float dMain = sdCapsule(probePt, height, radius);

  vec3 pBranch1 = probePt - vec3(0.2, 0.4, 0.0);
  pBranch1 = vec3(pBranch1.y, pBranch1.x, pBranch1.z);
  float dBranch1 = sdCapsule(pBranch1, 0.5, radius * 0.6);

  vec3 pBranch2 = probePt - vec3(-0.2, 0.4, 0.0);
  pBranch2 = vec3(pBranch2.y, pBranch2.x, pBranch2.z);
  float dBranch2 = sdCapsule(pBranch2, 0.5, radius * 0.6);

  float base = min(dMain, min(dBranch1, dBranch2));
  float noise = snoise(probePt * 5.0) * 0.1;
  float baseWithNoise = base - noise * _sdfNoise[i];

  vec3 decoColor;
  float deco = addCactusDecorations(probePt, radius, decoColor);
  return min(baseWithNoise, deco);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalized screen coordinates
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float index = 0.0;

    // Add a cactus to the scene
    addCactus_float(
        vec3(0.0, -0.2, -2.2),   // position
        0.8,                     // height
        0.1,                     // radius
        index,
        vec3(1.0, 0.0, 0.0),     // rotation axis
        0.0,                     // rotation angle
        vec3(0.2, 0.5, 0.2),     // base color (green)
        vec3(0.05),              // specular color
        0.2,                     // specular strength
        32.0,                    // shininess
        0.25,                    // noise intensity
        index
    );

    // Ray origin and direction
    vec3 rayOrigin = vec3(0.0, 0.0, 2.0);
    vec3 rayDir = normalize(vec3(uv, -1.0));

    float t = 0.0;
    float dist;
    int hitID = -1;

    // Sphere tracing loop
    for (int step = 0; step < 100; step++) {
        vec3 p = rayOrigin + t * rayDir;
        dist = 1e5;

        for (int i = 0; i < 10; i++) {
            if (_sdfTypeFloat[i] == 8) {
                float d = evalSDF(i, p);
                if (d < dist) {
                    dist = d;
                    hitID = i;
                }
            }
        }

        if (dist < 0.001) break;
        t += dist;
        if (t > 10.0) break;
    }

    // Shading
    if (t < 10.0) {
        vec3 hitPoint = rayOrigin + t * rayDir;

        // Estimate normal by central differences
        float eps = 0.001;
        vec3 n;
        vec2 e = vec2(1.0, -1.0) * 0.5773;
        n = normalize(
            e.xyy * evalSDF(hitID, hitPoint + e.xyy * eps) +
            e.yyx * evalSDF(hitID, hitPoint + e.yyx * eps) +
            e.yxy * evalSDF(hitID, hitPoint + e.yxy * eps) +
            e.xxx * evalSDF(hitID, hitPoint + e.xxx * eps)
        );

        // Light and shading
        vec3 lightDir = normalize(vec3(0.6, 1.0, 0.5));
        float diff = max(dot(n, lightDir), 0.0);

        vec3 color = _baseColorFloat[hitID] * diff;
        fragColor = vec4(color, 1.0);
    } else {
        fragColor = vec4(0.0); // Background black
    }
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/geometry/SDF_Cactus.glsl)
