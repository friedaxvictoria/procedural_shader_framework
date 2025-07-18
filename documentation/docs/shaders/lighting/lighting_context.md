#  🧩 Lighting Context Header

<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added -->

- **Category:** Lighting
- **Author:** Xuetong Fu
- **Shader Type:** Utility header (struct + helper)
- **Input Requirements:** N/A (header only)
---

## 🧠 Algorithm

### 🔷 Core Concept

`LightingContext` is a small struct that stores everything a lighting‑routine usually needs: `position`, `normal`, `viewDir`, `lightDir`, `lightColor`, and `ambient`.
The helper `createLightingContext()` fills these fields, so later code can pass one struct instead of six separate vectors.

Usage: `#include "lighting/surface_lighting/lighting_context.glsl"`

---
## 🎛️ Parameters

| Name         | Type | Description                              |
|--------------|------|------------------------------------------|
| `position`   | vec3 | World‑space fragment position            |
| `normal`     | vec3 | Unit surface normal                      |
| `viewDir`    | vec3 | Unit direction **from** surface **to** camera |
| `lightDir`   | vec3 | Unit direction **from** surface **to** light  |
| `lightColor` | vec3 | RGB intensity / colour of the light      |
| `ambient`    | vec3 | Ambient‑light contribution               |

---

## 💻 Shader Code & Includes
<!--
if you want to put small code snippet
-->
```glsl
#ifndef LIGHTING_CONTEXT_GLSL
#define LIGHTING_CONTEXT_GLSL

struct LightingContext {
    vec3 position;    // World-space fragment position
    vec3 normal;      // Normal at the surface point (normalized)
    vec3 viewDir;     // Direction from surface to camera (normalized)
    vec3 lightDir;    // Direction from surface to light (normalized)
    vec3 lightColor;  // RGB intensity of the light source
    vec3 ambient;     // Ambient light contribution
};

LightingContext createLightingContext(
    vec3 position,
    vec3 normal,
    vec3 viewDir,
    vec3 lightDir,
    vec3 lightColor,
    vec3 ambient
) {
    LightingContext ctx;
    ctx.position = position;
    ctx.normal = normal;
    ctx.viewDir = viewDir;
    ctx.lightDir = lightDir;
    ctx.lightColor = lightColor;
    ctx.ambient = ambient;
    return ctx;
}

#endif
```

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/surface_lighting/lighting_context.glsl)

---
