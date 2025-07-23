<div class="container">
    <h1 class="main-heading">Volume Material System Documentation</h1>
    <blockquote class="author">by Xuetong Fu</blockquote>
</div>

---

- **Category:** Material
- **Shader Type:** Utility header
- **Input Requirements:** Volume material ID; material property parameters (see the table below for details)

---

## 🧠 Algorithm

### 🔷 Core Concept
This system organizes material appearance using a three-part module:

---
### 1. `VolMaterialParams` Struct
Defines a data structure storing surface reflectance info (diffuse, specular, roughness, etc.)
#### 🎛️ Parameters

| Member             | Type   | Description                                       |
|--------------------|--------|---------------------------------------------------|
| `baseColor`        | vec3   | Intrinsic color of the medium                            |
| `densityScale`     | float  | Density multiplier controlling opacity and absorption strength   |
| `emissionStrength` | float  | Strength of light emitted by the medium itself                 |
| `emissionColor`    | vec3   | Emission color (if different from baseColor)                   |
| `scatteringCoeff`  | float  | Scattering strength (higher = more light bounces)               |
| `absorptionCoeff`  | float  | Absorption strength (higher = faster light decay)               |
| `anisotropy`       | float  | Phase function anisotropy [-1, 1], 0 = isotropic, >0 = forward scattering |
| `temperature`      | float  | Optional scalar used for color remapping or animation (e.g., flame ramp)  |
| `noiseStrength`    | float  | Optional density modulation by procedural noise                  |

#### 💻 Code
<!--
if you want to put small code snippet
-->
```glsl
#ifndef VOL_MAT_PARAMS_GLSL
#define VOL_MAT_PARAMS_GLSL

struct VolMaterialParams {
    vec3 baseColor;
    float densityScale;
    float emissionStrength;
    vec3 emissionColor;
    float scatteringCoeff;
    float absorptionCoeff; 
    float anisotropy;
    float temperature;
    float noiseStrength; 
};
#endif
```
Usage: `#include "materials/volume_material/vol_mat_params.glsl"`

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/volume_material/vol_mat_params.glsl)

---
### 2. Volume Material Presets
Defines helper functions to generate common volume materials like fog, clouds, etc.
#### 🔧 Functions

| Function                  | Description                          |
|---------------------------|-------------------------------------|
| `makeDefaultVolumeMaterial()` | Neutral white volume (fog-like baseline)     |
| `makeCloud(baseColor)`        | Light-scattering cloud material      |
| `makeFog(baseColor)`          | Thin volume with weak scattering    |
| `makeFlame(emissionColor)`    | Emissive flame-like preset        |
| `makeSmoke(baseColor)`        | Absorptive, dark smoke material      |
| `makeMagicMaterial(baseColor)`| Stylized emissive colored effect        |

> 📌 Notes:
> - All functions return a `VolMaterialParams` struct
> - These presets are meant to showcase possible material types, but they may not reflect the actual materials used in later shaders.

#### 💻 Code
<!--
if you want to put small code snippet and make it appereable and dissapear
-->
??? note "📄 vol_mat_presets.glsl"
    ```glsl
    #ifndef VOL_MAT_PRESETS_GLSL
    #define VOL_MAT_PRESETS_GLSL

    // ------------------------------------------
    // Default Volume Material (neutral white fog)
    // ------------------------------------------
    VolMaterialParams makeDefaultVolumeMaterial() {
        VolMaterialParams mat;
        mat.baseColor = vec3(1.0);
        mat.densityScale = 1.0;

        mat.emissionStrength = 0.0;
        mat.emissionColor = vec3(0.0);

        mat.scatteringCoeff = 0.5;
        mat.absorptionCoeff = 0.1;
        mat.anisotropy = 0.0;

        mat.temperature = 0.0;
        mat.noiseStrength = 0.0;
        return mat;
    }

    // ------------------------------------------
    // Cloud material preset (white fluffy clouds)
    // ------------------------------------------
    VolMaterialParams makeCloud(vec3 baseColor) {
        VolMaterialParams mat = makeDefaultVolumeMaterial();
        mat.baseColor = baseColor;
        mat.densityScale = 1.0;

        mat.scatteringCoeff = 1.0;
        mat.absorptionCoeff = 0.2;
        mat.anisotropy = 0.6;

        mat.noiseStrength = 0.3;
        return mat;
    }

    // ------------------------------------------
    // Fog material preset (neutral or tinted fog)
    // ------------------------------------------
    VolMaterialParams makeFog(vec3 baseColor) {
        VolMaterialParams mat = makeDefaultVolumeMaterial();
        mat.baseColor = baseColor;
        mat.densityScale = 0.5;

        mat.scatteringCoeff = 0.4;
        mat.absorptionCoeff = 0.05;
        mat.anisotropy = 0.0;

        mat.noiseStrength = 0.1;
        return mat;
    }

    // ------------------------------------------
    // Flame material preset (emissive fire volume)
    // ------------------------------------------
    VolMaterialParams makeFlame(vec3 emissionColor) {
        VolMaterialParams mat = makeDefaultVolumeMaterial();
        mat.baseColor = emissionColor;
        mat.emissionColor = emissionColor;
        mat.emissionStrength = 6.0;

        mat.densityScale = 0.6;
        mat.scatteringCoeff = 0.2;
        mat.absorptionCoeff = 0.1;

        mat.temperature = 1000.0;
        mat.noiseStrength = 0.3;
        return mat;
    }

    // ------------------------------------------
    // Smoke material preset (dark absorbing medium)
    // ------------------------------------------
    VolMaterialParams makeSmoke(vec3 baseColor) {
        VolMaterialParams mat = makeDefaultVolumeMaterial();
        mat.baseColor = baseColor;
        mat.densityScale = 0.8;

        mat.scatteringCoeff = 0.3;
        mat.absorptionCoeff = 0.4;
        mat.anisotropy = 0.0;

        mat.noiseStrength = 0.2;
        return mat;
    }

    // ------------------------------------------
    // Magic effect preset (emissive stylized medium)
    // ------------------------------------------
    VolMaterialParams makeMagicMaterial(vec3 baseColor) {
        VolMaterialParams mat = makeDefaultVolumeMaterial();
        mat.baseColor = baseColor;
        mat.emissionColor = baseColor;
        mat.emissionStrength = 3.0;

        mat.densityScale = 1.0;
        mat.scatteringCoeff = 0.6;
        mat.absorptionCoeff = 0.1;

        mat.noiseStrength = 0.4;
        return mat;
    }

    #endif
    ```
<!--
if we want to link the github repo
-->

Usage: `#include "materials/volume_material/vol_mat_presets.glsl"`

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/volume_material/vol_mat_presets.glsl)

---

### 3. Material Library
This module maps int IDs to material presets, useful for assigning materials to objects using hit-ID or tag logic in SDF raymarching.

#### 🏷️ Common IDs

| ID      | ID Macro              | Meaning                    |
|---------|-----------------------|----------------------------|
| 1       | `VOL_CLOUD_WHITE`     | Default white cloud        |
| ...     | ...                   | ...                        |
| 3       | `VOL_FOG_GRAY`        | Neutral low-density fog    |
| ...     | ...                   | ...                        |


> 📌 Notes:
> - Volume material IDs from 1 to 99 are reserved for common preset materials.  
> - Scene-specific materials should use IDs starting from 100 to avoid conflicts.
> - The current list is illustrative only; actual materials may be added, removed, or remapped as the library evolves.

#### 💻 Code
<!--
if you want to put small code snippet and make it appereable and dissapear
-->
??? note "📄 vol_mat_library.glsl"
    ```glsl
    #ifndef VOLUME_MATERIAL_LIBRARY_GLSL
    #define VOLUME_MATERIAL_LIBRARY_GLSL

    // ------------------------------------------
    // Common Volumetric Material Types
    // ------------------------------------------
    #define VOL_CLOUD_WHITE       1
    #define VOL_CLOUD_STORMY      2
    #define VOL_FOG_GRAY          3
    #define VOL_FIRE_ORANGE       4
    #define VOL_SMOKE_BLACK       5
    #define VOL_MAGIC_PURPLE      6

    // ------------------------------------------
    // Scene-Specific Volume Materials (start at 100)
    // ------------------------------------------
    #define VOL_PLASMA_STREAM     100
    #define VOL_NEBULA_GALAXY     101
    #define VOL_HAZE_GREEN        102

    // Get volume material from ID
    VolMaterialParams getVolMaterialByID(int id) {
        VolMaterialParams mat = makeDefaultVolumeMaterial();

        // ---------- Common Volume Types ----------
        if (id == VOL_CLOUD_WHITE) {
            mat = makeCloud(vec3(1.0));
        }
        else if (id == VOL_CLOUD_STORMY) {
            mat = makeCloud(vec3(0.8, 0.85, 0.9));
            mat.anisotropy = 0.7;
            mat.absorptionCoeff = 0.3;
        }
        else if (id == VOL_FOG_GRAY) {
            mat = makeFog(vec3(0.6));
        }
        else if (id == VOL_FIRE_ORANGE) {
            mat = makeFlame(vec3(1.0, 0.4, 0.1));
        }
        else if (id == VOL_SMOKE_BLACK) {
            mat = makeSmoke(vec3(0.1));
        }
        else if (id == VOL_MAGIC_PURPLE) {
            mat = makeMagicMaterial(vec3(0.6, 0.2, 0.8));
        }

        // ---------- Scene-Specific Materials ----------
        else if (id == VOL_PLASMA_STREAM) {
            mat.baseColor = vec3(0.5, 1.0, 1.0);
            mat.emissionStrength = 8.0;
            mat.anisotropy = 0.0;
            mat.densityScale = 0.3;
        }
        else if (id == VOL_NEBULA_GALAXY) {
            mat.baseColor = vec3(0.9, 0.3, 1.0);
            mat.emissionStrength = 2.0;
            mat.scatteringCoeff = 0.4;
            mat.absorptionCoeff = 0.1;
            mat.noiseStrength = 0.5;
        }
        else if (id == VOL_HAZE_GREEN) {
            mat = makeFog(vec3(0.2, 0.6, 0.3));
            mat.densityScale = 0.7;
        }

        return mat;
    }

    #endif
    ```
<!--
if we want to link the github repo
-->

Usage: `#include "materials/volume_material/vol_mat_library.glsl"`

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/volume_material/vol_mat_library.glsl)

---
