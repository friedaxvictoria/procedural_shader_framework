<div class="container">
    <h1 class="main-heading">SDF Rock Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/SDF_Rock.png" alt="Rock Shader Output" width="400" height="225">

- **Category:** Geometry  
- **Input Requirements:** `fragCoord`, `iResolution`  
- **Output:** Noisy procedural rock rendered via SDF and raymarching  

---

## 📌 Notes

- This shader renders a **3D rock** using **Signed Distance Field (SDF)** with **noise distortion**.  
- Supports object **rotation**, **surface normal estimation**, and **diffuse shading**.  
- Uses a **box primitive** perturbed by **simplex noise** to create irregular rock forms.  
- A useful module for building procedural terrain or object libraries.

---

## 🧠 Algorithm

### 🪨 Core Concept

- The base rock is a rotated box (`sdBox`) in local space.  
- To add realism, **3D simplex noise** displaces the surface, creating bumpy detail.  
- Raymarching is used to detect the surface hit point.  
- Surface normal is estimated by **central difference** and shaded using **Lambert lighting**.

---

## 🎛️ Parameters

| Name                   | Description                                | Type     | Example Value           |
|------------------------|--------------------------------------------|----------|--------------------------|
| `fragCoord`            | Fragment/pixel coordinate                  | `vec2`   | Built-in                 |
| `iResolution`          | Screen resolution                          | `vec2`   | uniform                  |
| `position`             | World-space position of the rock           | `vec3`   | `vec3(0.0, 0.0, -2.5)`   |
| `size`                 | Half-size of the rock (box)                | `vec3`   | `vec3(0.4, 0.3, 0.5)`    |
| `axis`, `angle`        | Rotation axis and angle (degrees)          | `vec3`, `float` | `vec3(0,1,0)`, `30.0` |
| `baseColor`            | Rock surface color                         | `vec3`   | `vec3(0.67, 0.52, 0.35)` |
| `specularColor`        | Specular highlight color                   | `vec3`   | `vec3(0.1)`              |
| `specularStrength`     | Specular coefficient                       | `float`  | `0.2`                    |
| `shininess`            | Phong shininess factor                     | `float`  | `16.0`                   |
| `noiseAmount`          | Strength of surface bump noise             | `float`  | `0.3`                    |

---

## 💻 Shader Code 

```glsl
float sdBox(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

void addRock_float(...) {
  _sdfTypeFloat[i] = 7;
  _sdfPositionFloat[i] = position;
  _sdfSizeFloat[i] = size;
  _sdfRotation[i] = rotationMatrixFromAxisAngle(axis, angle);
  _baseColorFloat[i] = baseColor;
  _sdfNoise[i] = noiseAmount;
}

float evalSDF(int i, vec3 p) {
  vec3 localP = transpose(_sdfRotation[i]) * (p - _sdfPositionFloat[i]);
  float base = sdBox(localP, _sdfSizeFloat[i]);
  float noise = snoise(localP * 5.0) * 0.1;
  return base - noise * _sdfNoise[i];
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float index = 0.0;

    addRock_float(
        vec3(0.0, 0.0, -2.5),      // position
        vec3(0.4, 0.3, 0.5),       // size
        index,
        vec3(0.0, 1.0, 0.0),       // rotation axis
        30.0,                      // angle in degrees
        vec3(0.67, 0.52, 0.35),       // base color
        vec3(0.1),                 // specular color
        0.2,                       // specular strength
        16.0,                      // shininess
        0.3,                       // noise amount
        index                      // output new index
    );

    // Just visualize as distance field:
    vec3 rayOrigin = vec3(0.0, 0.0, 2.0);
    vec3 rayDir = normalize(vec3(uv, -1.0));

    float t = 0.0;
    float dist;
    int hitID = -1;

    for (int step = 0; step < 100; step++) {
        vec3 p = rayOrigin + t * rayDir;
        dist = 1e5;

        for (int i = 0; i < 10; i++) {
            if (_sdfTypeFloat[i] == 7) {
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

    if (t < 10.0) {
        vec3 hitPoint = rayOrigin + t * rayDir;

        // Normal estimation by central difference
        float eps = 0.001;
        vec3 n;
        vec2 e = vec2(1.0, -1.0) * 0.5773;
        n = normalize(
            e.xyy * evalSDF(hitID, hitPoint + e.xyy * eps) +
            e.yyx * evalSDF(hitID, hitPoint + e.yyx * eps) +
            e.yxy * evalSDF(hitID, hitPoint + e.yxy * eps) +
            e.xxx * evalSDF(hitID, hitPoint + e.xxx * eps)
        );

        // Lambert lighting from one direction
        vec3 lightDir = normalize(vec3(0.6, 1.0, 0.5));
        float diff = max(dot(n, lightDir), 0.0);

        // Apply diffuse light to base color
        vec3 color = _baseColorFloat[hitID] * diff;

        fragColor = vec4(color, 1.0);
    } else {
        fragColor = vec4(0.0); // background
    }
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/geometry/SDF_Rock.glsl)
