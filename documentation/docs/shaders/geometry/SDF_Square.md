# 🧩 SDF Square Shader

<img src="https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/screenshots/geometry/square.png?raw=true" alt="Square Shader Output" width="400" height="225">


- **Category:** Geometry
- **Author:** Wanzhang He
- **Shader Type:** 2D Primitive (SDF)  
- **Input Requirements:** `fragCoord`, `iResolution`  
- **Output:** Red square in white background using SDF logic

---

## 📌 Notes

- This shader draws a **centered red square** using a **Signed Distance Function (SDF)**.
- It normalizes and aspect-corrects the UV coordinates for pixel-perfect squares.
- Fragments inside the square are red, outside are white.
- Useful as a **basic primitive test**, SDF intro, or 2D shape module.

---

## 🧠 Algorithm

### 🔷 Core Concept

The shader computes the **signed distance to an axis-aligned square**, then uses that distance to choose color:

- Distance ≤ 0 → **inside square** → red
- Distance > 0 → **outside square** → white

It also corrects for **non-square screen aspect ratio** to avoid stretching.

---

## 🎛️ Parameters

| Name         | Description                          | Type     | Example       |
|--------------|--------------------------------------|----------|----------------|
| `fragCoord`  | Fragment/pixel coordinate            | `vec2`   | Built-in       |
| `iResolution`| Screen resolution                    | `vec2`   | uniform        |
| `size`       | Half the square’s side length        | `float`  | `0.2`          |
| `offset`     | UV center position of the square     | `vec2`   | `vec2(0.0)`    |

---

## 💻 Shader Code

```glsl
vec3 sdfSquare(vec2 uv, float size, vec2 offset) {
  float x = uv.x - offset.x;
  float y = uv.y - offset.y;
  float d = max(abs(x), abs(y)) - size;
  return d > 0. ? vec3(1.) : vec3(1., 0., 0.);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;
  uv -= 0.5;
  uv.x *= iResolution.x / iResolution.y;
  vec2 offset = vec2(0.0, 0.0);
  vec3 col = sdfSquare(uv, 0.2, offset);
  fragColor = vec4(col, 1.0);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/geometry/Square.glsl)
