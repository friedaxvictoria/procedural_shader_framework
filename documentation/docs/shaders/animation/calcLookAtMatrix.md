# 🧩 Camera Orientation Setup Shader

<img src="../../../../shaders/screenshots/animation/RollingRefraction.gif" alt="Rolling Camera Preview" width="400" height="225">

- **Category:** Animation / Camera  
- **Author:** Wanzhang He  
- **Shader Type:** Dynamic camera matrix computation  
- **Input Requirements:** `fragCoord`, `iResolution`, `iTime`, `iChannel0`  
- **Output:** Animated environment sample using orbiting camera

---

## 📌 Notes

- Defines a **time-varying camera system** using a `look-at` matrix with optional roll.
- Simulates **orbiting motion** around the scene origin, with adjustable speed and tilt.
- Can be reused in raymarchers, reflections, or scene viewers for dynamic camera control.
- Texture sample is done via flat projection for visualization.

---

## 🧠 Algorithm

### 🔷 Core Concept

- Uses `calcLookAtMatrix()` to create a **camera basis matrix** from:
  - Eye position `ro`
  - Target position `ta`
  - Roll angle (optional tilt)
- The ray direction is transformed from screen space to world space using this basis.
- Final color is sampled from a texture (`iChannel0`) using the view direction.

---

## 🎛️ Parameters

| Name         | Description                          | Type     | Example              |
|--------------|--------------------------------------|----------|-----------------------|
| `fragCoord`  | Fragment/pixel coordinate            | `vec2`   | Built-in              |
| `iResolution`| Viewport resolution                  | `vec2`   | uniform               |
| `iTime`      | Global time for animation            | `float`  | uniform               |
| `iChannel0`  | Environment texture for visualization| `sampler2D` | loaded externally  |

---

## 💻 Shader Code

```glsl
mat3 calcLookAtMatrix(vec3 ro, vec3 ta, float roll) {
    vec3 forward = normalize(ta - ro);
    vec3 right = normalize(cross(forward, vec3(sin(roll), cos(roll), 0.0)));
    vec3 up = normalize(cross(right, forward));
    return mat3(right, up, forward);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    float t = iTime * 0.5;
    vec3 ta = vec3(0.0);
    vec3 ro = vec3(2.0 * cos(t), 1.0, 2.0 * sin(t));
    float roll = sin(iTime * 0.3) * 0.3;

    mat3 camMat = calcLookAtMatrix(ro, ta, roll);
    vec3 rayDir = normalize(camMat * vec3(p, -1.0));

    vec2 envUV = rayDir.xy * 0.5 + 0.5;
    vec3 col = texture(iChannel0, envUV).rgb;

    fragColor = vec4(col, 1.0);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/animation/calcLookAtMatrix.glsl)
