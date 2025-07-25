<div class="container">
    <h1 class="main-heading">Lighting and Material System Shader</h1>
    <blockquote class="author">by Saeed Shamseldin</blockquote>
</div>


<img src="../../../static/images/images4Shaders/colored_SDFs.png" alt="general scene" width="500" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

---
## Overview

This documentation covers the Phong-based lighting model and material system used in the GLSL shader. The system provides realistic shading for SDF-rendered objects, supporting:


- **Diffuse/specular lighting**

- **Custom material properties** (plastic, metals, etc.)

- **Dynamic normal mapping** (via SDF derivatives)

## Core Components

**A. Lighting Model**

Based on the Phong reflection model, with three components:

1. Ambient: Base illumination (constant).

2. Diffuse: Lambertian scattering (depends on surface normal).

3. Specular: Glossy highlights (depends on view direction).

**B. Material Properties**

Controlled by four parameters:

| **Parameter**        | **Description**           | **Example Values**                  |
|----------------------|---------------------------|-------------------------------------|
| `BaseColor`          | Albedo (RGB)              | `vec3(1.0, 0.0, 0.0)` (red)         |
| `SpecularColor`      | Highlight tint            | `vec3(1.0)` (white)                 |
| `SpecularStrength`   | Highlight intensity       | `0.5` (medium)                      |
| `Shininess`          | Highlight tightness       | `32.0` (plastic)                    |

## Key Functions
**A. applyPhongLighting()**

Calculates the final pixel color using Phong shading.

| **Parameter**       | **Type**   | **Description**                                         |
|---------------------|------------|---------------------------------------------------------|
| `Position`          | `vec3`     | World-space hit point                                   |
| `Normal`            | `vec3`     | Surface normal (unit vector)                            |
| `ViewDir`           | `vec3`     | Direction to camera (`normalize(camPos - Position)`)    |
| `LightPos`          | `vec3`     | World-space light position                              |
| `LightColor`        | `vec3`     | RGB light color                                         |
| `AmbientColor`      | `vec3`     | Ambient light (constant)                                |
| `BaseColor`         | `vec3`     | Material albedo                                         |
| `SpecularColor`     | `vec3`     | Specular tint                                           |
| `SpecularStrength`  | `float`    | Highlight intensity                                     |
| `Shininess`         | `float`    | Highlight exponent (higher = sharper)                   |
| `OutputColor`       | `out vec3` | Final shaded color                                      |

**Implementation**
```glsl
void applyPhongLighting(
    vec3 Position, vec3 Normal, vec3 ViewDir,
    vec3 LightPos, vec3 LightColor, vec3 AmbientColor,
    vec3 BaseColor, vec3 SpecularColor, float SpecularStrength, float Shininess,
    out vec3 OutputColor
) {
    // Diffuse (Lambertian)
    vec3 L = normalize(LightPos - Position);
    float diff = max(dot(Normal, L), 0.0);
    vec3 diffuse = diff * BaseColor * LightColor;

    // Specular (Phong)
    vec3 R = reflect(-L, Normal);
    float spec = pow(max(dot(R, ViewDir), 0.0), Shininess);
    vec3 specular = spec * SpecularColor * SpecularStrength;

    // Combine
    OutputColor = AmbientColor + diffuse + specular;
}
```

**B. MakePlasticMaterial()**

Configures a plastic-like material.

| **Parameter**         | **Type**     | **Description**                                 |
|-----------------------|--------------|-------------------------------------------------|
| `Color`               | `vec3`       | Albedo color                                    |
| `specularcolor`       | `vec3`       | Specular tint (usually white)                   |
| `specularstrength`    | `float`      | Highlight intensity (e.g., `0.5`)               |
| `shininess`           | `float`      | Highlight exponent (e.g., `32.0`)               |
| `BaseColor`           | `out vec3`   | Output albedo                                   |
| `SpecularColor`       | `out vec3`   | Output specular tint                            |
| `SpecularStrength`    | `out float`  | Output highlight strength                       |
| `Shininess`           | `out float`  | Output shininess                                |


**Implementation**
```glsl
void MakePlasticMaterial(
    vec3 Color, vec3 specularcolor, float specularstrength, float shininess,
    out vec3 BaseColor, out vec3 SpecularColor, out float SpecularStrength, out float Shininess
) {
    BaseColor = Color;
    SpecularColor = specularcolor;
    SpecularStrength = specularstrength;
    Shininess = shininess;
}
```
**Integration with Raymarching**

1. **After [raymarching](../geometry/SDF_Shader.md#raymarching-integration)**, call [`SDFsNormal(hitPos)`](../geometry/SDF_Shader.md#normal-estimation) to get normals.

2. **Configure materials** using MakePlasticMaterial().

3. **Apply lighting** via applyPhongLighting().