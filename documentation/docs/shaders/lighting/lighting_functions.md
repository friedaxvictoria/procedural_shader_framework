<div class="container">
    <h1 class="main-heading">Lighting Function Collection</h1>
    <blockquote class="author">by Xuetong Fu</blockquote>
</div>

---

- **Category:** Lighting
- **Shader Type:** Lighting function library
- **Input Requirements:** LightingContext, MaterialParams
---

## 🧠 Algorithm

### 🔷 Core Concept

This module defines multiple lighting models for shading surfaces based on their physical or stylized properties. Each model computes the final color by combining diffuse, specular, and ambient contributions using information in the LightingContext and MaterialParams.

---
## 🎛️ Parameters

| Name       | Description            | Type             | Range | Default | Role     |
|------------|------------------------|------------------|-------|---------|----------|
| `ctx`      | Lighting context input | LightingContext  | —     | —       | Input    |
| `mat`      | Material parameters    | MaterialParams   | —     | —       | Input    |
| `(return)` | Final RGB color        | vec3             | 0.0–1.0 | —       | Output   |


---

## 💻 Shader Code & Includes

```
#include "lighting/surface_lighting/lighting_context.glsl"
#include "lighting/surface_lighting/material_params.glsl"
```

### 1. Phong
The Phong lighting model computes specular highlights using the reflected light vector, resulting in sharper and more localized reflections. It offers a classic and intuitive approach to lighting, useful for surfaces where accurate highlight direction is important.

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
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/surface_lighting/phong.glsl)
#### Engine Integrations

<div class="button-row">
  <a class="md-button" href="../../engines/unreal/lighting/PhongLighting.md">Unreal</a>
</div>

### 2. Blinn-phong
The Blinn-Phong lighting model calculates diffuse and specular highlights using the halfway vector between the light and view directions. It provides a smoother and more efficient alternative to the classic Phong model, making it suitable for real-time rendering with stylized or semi-realistic surfaces.

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
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/surface_lighting/blinn_phong.glsl)

#### Engine Integrations

<div class="button-row">
  <a class="md-button" href="../../../engines/unity/lighting/blinnPhongLight">Unity</a>
    <a class="md-button" href="../../../engines/unreal/lighting/blinnPhongLight">Unreal</a>
</div>

### 3. Lambert
Implements a classic Lambertian diffuse model. It computes the intensity of reflected light based on the angle between surface normal and light direction, producing soft, angle-dependent shading.

<!--
if you want to put small code snippet
-->
```glsl
vec3 lambertDiffuse(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0);
    return mat.baseColor * ctx.lightColor * diff;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/surface_lighting/lambert.glsl)

#### Engine Integrations

<div class="button-row">
  <a class="md-button" href="../../../engines/unity/lighting/lambLight">Unity</a>
    <a class="md-button" href="../../../engines/unreal/lighting/lambLight">Unreal</a>
</div>

### 4. Physically Based Rendering
Simulates realistic lighting by blending diffuse and specular reflections based on surface roughness and metallic properties. Produces soft highlights on rough surfaces and sharp reflections on polished materials, enabling physically plausible rendering across diverse material types.

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
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/surface_lighting/pbr.glsl)

#### Engine Integrations

<div class="button-row">
  <a class="md-button" href="../../../../engines/unreal/lighting/PBRLighting">Unreal</a>
</div>

### 5. Rim Lighting
Adds a soft glow around the edges of objects by highlighting areas where the surface normal is nearly perpendicular to the view direction.

<!--
if you want to put small code snippet
-->
```glsl
vec3 computeRimLighting(LightingContext ctx, MaterialParams mat, vec3 rimColor) {
    float rim = pow(1.0 - max(dot(ctx.normal, ctx.viewDir), 0.0), mat.rimPower);
    return rim * rimColor;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/surface_lighting/rim_lighting.glsl)

#### Engine Integrations

<div class="button-row">
  <a class="md-button" href="../../../engines/unity/lighting/rimLight">Unity</a>
    <a class="md-button" href="../../../engines/unreal/lighting/rimLight">Unreal</a>
</div>

### 6. Fake Specular
Simulates stylized highlights without relying on physical material properties. 

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
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/surface_lighting/fake_specular.glsl)

#### Engine Integrations

<div class="button-row">
  <a class="md-button" href="../../../../engines/unreal/lighting/fakeSpecular">Unreal</a>
</div>

---
