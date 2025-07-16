#  🧩 Lighting Function Collection

- **Category:** Lighting
- **Author:** Xuetong Fu
- **Shader Type:** Lighting functions
- **Input Requirements:** LightingContext, MaterialParams
---

## 🧠 Algorithm

### 🔷 Core Concept

Explain the logic used in this shader.

- Movement logic (e.g., `cos(t)`, `sin(t * speed)`)
- Procedural math (e.g., FBM, noise)
- Camera path, lighting, deformation, etc.

---
## 🎛️ Parameters

| Name | Description | Range | Default |
|------|-------------|-------|---------|
| `T`  | Looping time | 0–40  | —       |
| ...  | ...          | ...   | ...     |

---

## 💻 Shader Code & Includes

```
#include "lighting/surface_lighting/lighting_context.glsl"
#include "lighting/surface_lighting/material_params.glsl"
```

### 1. Blinn Phong
<!--
if you want to put small code snippet
-->
```glsl
vec3 applyBlinnPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); 
    vec3 H = normalize(ctx.lightDir + ctx.viewDir); 
    float spec = pow(max(dot(ctx.normal, H), 0.0), mat.shininess); 
    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/surface_lightingblinn_phong.glsl)

### 2. Phong
<!--
if you want to put small code snippet
-->
```glsl
 vec3 applyPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0);
    vec3 R = reflect(-ctx.lightDir, ctx.normal);
    float spec = pow(max(dot(R, ctx.viewDir), 0.0), mat.shininess); 
    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/phong.glsl)

### 3. Lambert
<!--
if you want to put small code snippet
-->
```glsl
vec3 lambertDiffuse(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0);
    return mat.baseColor * ctx.lightColor * diff;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/lambert.glsl)

### 4. PRB
<!--
if you want to put small code snippet
-->
```glsl
vec3 applyPBRLighting(LightingContext ctx, MaterialParams mat) {
    vec3 N = normalize(ctx.normal);
    vec3 V = normalize(ctx.viewDir);
    vec3 L = normalize(ctx.lightDir);
    vec3 H = normalize(L + V);
    vec3 F0 = mix(vec3(0.04), mat.baseColor, mat.metallic);

    float NDF = pow(mat.roughness + 1.0, 2.0);
    float a = NDF * NDF;
    float a2 = a * a;

    float NdotH = max(dot(N, H), 0.0);
    float D = a2 / (PI * pow((NdotH * NdotH) * (a2 - 1.0) + 1.0, 2.0));

    float HdotV = max(dot(H, V), 0.0);
    vec3 F = F0 + (1.0 - F0) * pow(1.0 - HdotV, 5.0);

    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float k = pow(mat.roughness + 1.0, 2.0) / 8.0;
    float G_V = NdotV / (NdotV * (1.0 - k) + k);
    float G_L = NdotL / (NdotL * (1.0 - k) + k);
    float G = G_V * G_L;

    vec3 specular = (D * F * G) / (4.0 * NdotL * NdotV + 0.001);

    vec3 kd = (1.0 - F) * (1.0 - mat.metallic);
    vec3 diffuse = kd * mat.baseColor / PI;

    vec3 lighting = (diffuse + specular) * ctx.lightColor * NdotL;
    return lighting;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/prb.glsl)

### 5. Rim Lighting
<!--
if you want to put small code snippet
-->
```glsl
vec3 computeRimLighting(LightingContext ctx, MaterialParams mat, vec3 rimColor) {
    float rim = pow(1.0 - max(dot(ctx.normal, ctx.viewDir), 0.0), mat.rimPower);
    return rim * rimColor;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/rim_lighting.glsl)

### 6. Fake Specular
<!--
if you want to put small code snippet
-->
```glsl
vec3 computeFakeSpecular(LightingContext ctx, MaterialParams mat) {
    vec3 H = normalize(ctx.lightDir + ctx.viewDir);
    float highlight = pow(max(dot(ctx.normal, H), 0.0), mat.fakeSpecularPower);
    return highlight * mat.fakeSpecularColor * ctx.lightColor;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/fack_specular.glsl)
