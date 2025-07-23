<div class="container">
    <h1 class="main-heading">Volume Lighting Context Header</h1>
    <blockquote class="author">by Xuetong Fu</blockquote>
</div>

---
- **Category:** Lighting
- **Shader Type:** Utility header (struct + helper)
- **Input Requirements:** N/A (header only)
---

## 🧠 Algorithm

### 🔷 Core Concept

`VolCtxLocal` is a small struct that stores everything a lighting‑routine usually needs: `position`,`viewDir`, `lightDir`, `lightColor`, and `ambient`, `stepSize`.
The helper `createVolCtxLocal()` fills these fields, so later code can pass one struct instead of six separate vectors.

Usage: `#include "lighting/volume_lighting/vol_lit_context.glsl"`

---
## 🎛️ Parameters

| Name         | Type | Description                              |
|--------------|------|------------------------------------------|
| `position`   | vec3 | World‑space fragment position            |
| `viewDir`    | vec3 | Unit direction **from** surface **to** camera |
| `lightDir`   | vec3 | Unit direction **from** surface **to** light  |
| `lightColor` | vec3 | RGB intensity / colour of the light      |
| `ambient`    | vec3 | Ambient‑light contribution               |
| `stepSize`   | float| Raymarch step size at this sample  |
---

## 💻 Shader Code & Includes
<!--
if you want to put small code snippet
-->
```glsl
#ifndef VOL_LIT_CONTEXT_GLSL
#define VOL_LIT_CONTEXT_GLSL

struct VolCtxLocal {
    vec3 position;
    vec3 viewDir;
    vec3 lightDir;
    vec3 lightColor;
    vec3 ambient;
    float stepSize;
};

VolCtxLocal createVolCtxLocal(
    vec3 position,
    vec3 viewDir,
    vec3 lightDir,
    vec3 lightColor,
    vec3 ambient,
    float stepSize
) {
    VolCtxLocal ctx;
    ctx.position = position;
    ctx.viewDir = viewDir;
    ctx.lightDir = lightDir;
    ctx.lightColor = lightColor;
    ctx.ambient = ambient;
    ctx.stepSize = stepSize;
    return ctx;
}

#endif
```

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/volume_lighting/vol_lit_context.glsl)

---
