#  🧩Boat and Flag Shader

<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added -->

<!-- this is for locally stored images -->
<img src="https://raw.githubusercontent.com/friedaxvictoria/procedural_shader_framework/main/shaders/screenshots/BoatAndFlag.png" alt="Boat and Flag" width="400" height="225">

- **Category:** Scene
- **Author:** Xuetong Fu
- **Shader Type:** raymarch (SDF-based geometry)
- **Input Requirements:** `fragCoord`, `iTime`, `iMouse`, `iResolution`
- **Output:**  `fragColor` RGBA color

---

## 🧠 Algorithm

### 🔷 Core Concept
This shader renders a signed distance field (SDF) scene featuring a boat hull and flagpole using sphere tracing. The model is visualized with orbit camera controls and shaded using pseudo diffuse and rim lighting techniques.

| Stage | Function / Code | Purpose |
|-------|-----------------|---------|
| **Geometry SDF** | `evaluateShip()` | Defines boat hull, pole, and flag via SDF primitives. |
| **Raymarcher** | `raymarch()` | Traces view rays through SDF until a hit or max distance. |
| **Normal Estimate** | `estimateNormal()` | Approximates surface normals using central differences. |
| **Shading Model** | inline in `mainImage()` | Combines base color, pseudo diffuse, and rim lighting for stylized shading. |
| **Output** | `fragColor = sum` |  |

Result:  a clear SDF-based preview of a stylized boat with orbit camera control and emphasis on silhouette contours.

---
## 🎛️ Parameters

| Name | Description | Range / Unit | Default |
|------|-------------|--------------|---------|
| `iTime` | Global time | seconds | — |
| `iMouse.xy` | Orbit camera yaw / pitch | pixels (0 – `iResolution`) | (0, 0) |
| `iResolution` | Viewport resolution | pixels | — |
| `CAMERA_DIST` | Camera radius from center | float | 7.0 |
| `MODEL_ROT` | Axis remapping for boat orientation | mat3 | rotates boat to +Z |

To use this shader outside ShaderToy (e.g., in **Unity** or  **Godot**):

- `iTime` → `_Time.y` in Unity / `TIME` in Godot
- `iResolution` → screen resolution vector
- `iChannel1` → supply your own blue-noise texture
- `iMouse` → remap to your camera controller input

Make sure to adjust the entry point from `mainImage(out vec4 fragColor, in vec2 fragCoord)` to match your rendering pipeline.

---

## 💻 Shader Code & Includes
<!--
if you want to put small code snippet
-->
### 1. Boat and Flag SDF Construction

```glsl

```

### 2. Raymarch and Normal Estimation

```glsl

```

### 3. Orbit Camera and Shading

```glsl

```

<!--
if you want to put small code snippet and make it appereable and dissapear
-->
??? note "📄 WaterSurface.glsl"
    ```glsl
    
    ```
<!--
if we want to link the github repo
-->
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/BoatAndFlag.glsl)

---
