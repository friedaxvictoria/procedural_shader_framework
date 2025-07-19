#  🧩 Material System Documentation

- **Category:** Material
- **Author:** Xuetong Fu
- **Shader Type:** Utility header
- **Input Requirements:** Material ID; uv; material property parameters (see the table below for details)

---

## 🧠 Algorithm

### 🔷 Core Concept
This system organizes material appearance using a three-part module:

---
## 1. `MaterialParams` Struct
Defines a data structure storing surface reflectance info (diffuse, specular, roughness, etc.)
### 🎛️ Parameters

| Member             | Type  | Description                                       |
|--------------------|-------|---------------------------------------------------|
| `baseColor`        | vec3  | Base surface color (albedo/diffuse)              |
| `specularColor`    | vec3  | Color of specular highlights                     |
| `specularStrength` | float | Strength of specular reflections                 |
| `shininess`        | float | Phong/Blinn exponent                             |
| `roughness`        | float | Microfacet roughness (PBR)                       |
| `metallic`         | float | Degree of metallic reflection                                 |
| `rimPower`         | float | Rim light exponent (stylized look)              |
| `fakeSpecularPower`| float | Controls sharpness of stylized highlights        |
| `fakeSpecularColor`| vec3  | Color of stylized highlights                     |
| `ior`              | float | Index of refraction (for transparent materials)  |
| `refractionStrength`| float| Blending factor for refracted background             |
| `refractionTint`   | vec3  | Tint color applied to refracted background             |

### 💻 Code
<!--
if you want to put small code snippet
-->
```glsl
#ifndef MATERIAL_PARAMS_GLSL
#define MATERIAL_PARAMS_GLSL

struct MaterialParams {
    vec3 baseColor; 
    vec3 specularColor;
    float specularStrength;
    float shininess;

    float roughness;
    float metallic;
    float rimPower;
    float fakeSpecularPower;
    vec3 fakeSpecularColor;

    float ior;
    float refractionStrength;
    vec3 refractionTint;
};

#endif
```
Usage: `#include "materials/material/material_params.glsl"`

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/material_params.glsl)

---
## 2. Material Presets
Defines helper functions to generate common materials like glass, plastic, metal, toon, etc.
### 🔧 Functions

| Function               | Description                         |
|------------------------|-------------------------------------|
| `createDefaultMaterialParams()` | Returns a neutral white plastic |
| `makePlastic(color)`   | Basic plastic with given color      |
| `makeGlass(tint, ior)` | Transparent material with tint      |
| `makeMetalBrushed(base, uv, scale)` | Brushed metal with noise-based details |
| `makeToon(color, edgeSharpness)` | Flat toon surface with rim light |
| `makeWater(color)`     | Shiny semi-transparent water preset |

> 📌 Notes:
> - Metal brushed requires external noise function `n31(vec3)`
> - All functions return a `MaterialParams` struct
> - These presets are meant to showcase possible material types, but they may not reflect the actual materials used in later shaders.

### 💻 Code
<!--
if you want to put small code snippet and make it appereable and dissapear
-->
??? note "📄 material_presets.glsl"
    ```glsl
    #ifndef MATERIAL_PRESETS_GLSL
    #define MATERIAL_PRESETS_GLSL

    // ------------------------------------------
    // Default Material (neutral white plastic)
    // ------------------------------------------
    MaterialParams createDefaultMaterialParams() {
        MaterialParams mat;
        mat.baseColor = vec3(1.0);
        mat.specularColor = vec3(1.0);
        mat.specularStrength = 1.0;
        mat.shininess = 32.0;

        mat.roughness = 0.5;
        mat.metallic = 0.0;
        mat.rimPower = 2.0;
        mat.fakeSpecularPower = 32.0;
        mat.fakeSpecularColor = vec3(1.0);

        mat.ior = 1.45;                    // Typical plastic/glass
        mat.refractionStrength = 0.0;     // No refraction by default
        mat.refractionTint = vec3(1.0);
        return mat;
    }

    // ------------------------------------------
    // Plastic material preset
    // ------------------------------------------
    MaterialParams makePlastic(vec3 color) {
        MaterialParams mat = createDefaultMaterialParams();
        mat.baseColor = color;
        mat.metallic = 0.0;
        mat.roughness = 0.4;
        mat.specularStrength = 0.5;
        return mat;
    }

    // ------------------------------------------
    // Glass material preset
    // ------------------------------------------
    MaterialParams makeGlass(vec3 tint, float ior) {
        MaterialParams mat = createDefaultMaterialParams();
        mat.baseColor = tint;
        mat.metallic = 0.0;
        mat.roughness = 0.1;
        mat.ior = ior;
        mat.refractionStrength = 0.9;
        mat.refractionTint = tint;
        mat.specularStrength = 1.0;
        return mat;
    }

    // ------------------------------------------
    // Brushed metal with procedural noise
    // ------------------------------------------
    MaterialParams makeMetalBrushed(vec3 base, vec3 uv, float scale) {
        MaterialParams mat = createDefaultMaterialParams();
        mat.baseColor = base - n31(uv * scale) * 0.1; // Requires external noise n31()
        mat.metallic = 1.0;
        mat.roughness = 0.2;
        mat.specularStrength = 0.5;
        return mat;
    }

    // ------------------------------------------
    // Toon material preset (flat surface with strong rim)
    // ------------------------------------------
    MaterialParams makeToon(vec3 color, float edgeSharpness) {
        MaterialParams mat = createDefaultMaterialParams();
        mat.baseColor = color;
        mat.metallic = 0.0;
        mat.roughness = 1.0;
        mat.rimPower = edgeSharpness;
        mat.fakeSpecularColor = vec3(1.0);
        mat.fakeSpecularPower = 128.0;
        return mat;
    }

    // ------------------------------------------
    // Water material preset
    // ------------------------------------------
    MaterialParams makeWater(vec3 color) {
        MaterialParams mat = createDefaultMaterialParams();
        mat.baseColor = color;
        mat.fakeSpecularColor = vec3(1.0);
        mat.fakeSpecularPower = 64.0;
        mat.specularColor = vec3(1.5);
        mat.specularStrength = 1.5; 
        mat.shininess = 64.0; 
        mat.ior = 1.333;
        mat.refractionStrength = 0.0;
        return mat;
    }

    #endif
    ```
<!--
if we want to link the github repo
-->

Usage: `#include "materials/material/material_presets.glsl"`

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/material_presets.glsl)

---
## 3. Material Library
This module maps int IDs to material presets, useful for assigning materials to objects using hit-ID or tag logic in SDF raymarching.

### 🏷️ Common IDs

| ID      | ID Macro              | Meaning                    |
|---------|-----------------------|----------------------------|
| 1       | `MAT_PLASTIC_WHITE`   | Default neutral material   |
| 2       | `MAT_PLASTIC_COLOR`   | Color plastic material     |
| ...     | ...                   | ...                        |
| 5       | `MAT_GLASS_CLEAR`     | Colorless transparent glass|
| ...     | ...                   | ...                        |

> 📌 Notes:
> - Material IDs from 1 to 100 are reserved for common preset materials (e.g. plastic, glass, metal).  
> - Scene-specific materials should use IDs starting from 101 to avoid conflicts.
> - The current list is illustrative only; actual materials may be added, removed, or remapped as the library evolves.

### 💻 Code
<!--
if you want to put small code snippet and make it appereable and dissapear
-->
??? note "📄 material_library.glsl"
    ```glsl
    #ifndef MATERIAL_LIBRARY_GLSL
    #define MATERIAL_LIBRARY_GLSL

    // ------------------------------------------
    // Common Physically-Based Material Templates
    // ------------------------------------------
    #define MAT_PLASTIC_WHITE      1
    #define MAT_PLASTIC_COLOR      2
    #define MAT_METAL_BRUSHED      3
    #define MAT_METAL_POLISHED     4
    #define MAT_GLASS_CLEAR        5
    #define MAT_GLASS_TINTED       6
    #define MAT_RUBBER_BLACK       7
    #define MAT_CERAMIC_WHITE      8
    #define MAT_EMISSIVE_WHITE     9

    // ------------------------------------------
    // Scene-Specific Materials (Start from 100)
    // ------------------------------------------
    #define MAT_METAL_WING         100
    #define MAT_SOLAR_PANEL        101
    #define MAT_COCKPIT_GLASS      102
    #define MAT_WINDOW_FRAME       103
    #define MAT_COCKPIT_BODY       104
    #define MAT_GUN_BARREL         105
    #define MAT_LASER_EMISSIVE     106

    // Material preset registry
    MaterialParams getMaterialByID(int id, vec3 uv) {
        MaterialParams mat = createDefaultMaterialParams();

        // ---------- Common Material Templates ----------
        if (id == MAT_PLASTIC_WHITE) {
            mat = makePlastic(vec3(1.0));
        }
        else if (id == MAT_PLASTIC_COLOR) {
            mat = makePlastic(vec3(0.4, 0.6, 1.0));
        }
        else if (id == MAT_METAL_BRUSHED) {
            mat = makeMetalBrushed(vec3(0.6), uv, 12.0);
        }
        else if (id == MAT_METAL_POLISHED) {
            mat = makeMetalBrushed(vec3(0.9), uv, 0.0);
            mat.roughness = 0.05;
            mat.specularStrength = 1.0;
        }
        else if (id == MAT_GLASS_CLEAR) {
            mat = makeGlass(vec3(1.0), 1.5);
        }
        else if (id == MAT_GLASS_TINTED) {
            mat = makeGlass(vec3(0.6, 0.8, 1.0), 1.45);
        }
        else if (id == MAT_RUBBER_BLACK) {
            mat = makePlastic(vec3(0.05));
            mat.roughness = 0.9;
            mat.specularStrength = 0.2;
        }
        else if (id == MAT_CERAMIC_WHITE) {
            mat = makePlastic(vec3(0.95));
            mat.roughness = 0.2;
            mat.specularStrength = 0.8;
        }
        else if (id == MAT_EMISSIVE_WHITE) {
            mat.baseColor = vec3(1.0);
            mat.fakeSpecularColor = vec3(1.0);
            mat.fakeSpecularPower = 1.0;
            mat.rimPower = 0.0;
            mat.specularStrength = 0.0;
        }

        // ---------- Scene-Specific Materials ----------
        else if (id == MAT_METAL_WING) {
            mat = makeMetalBrushed(vec3(0.30), uv, 18.7);
            mat.specularStrength = 0.5;
        }
        else if (id == MAT_COCKPIT_BODY) {
            mat = makeMetalBrushed(vec3(0.30), uv, 18.7);
            mat.specularStrength = 0.5;
            float cutout = step(abs(atan(uv.y, uv.z) - 0.8), 0.01);
            mat.baseColor *= 1.0 - 0.8 * cutout;
        }
        else if (id == MAT_SOLAR_PANEL) {
            vec3 modifiedUV = uv;
            if (uv.x < uv.y * 0.7) modifiedUV.y = 0.0;
            float intensity = 0.005 + 0.045 * pow(abs(sin((modifiedUV.x - modifiedUV.y) * 12.0)), 20.0);
            mat.baseColor = vec3(intensity);
            mat.specularStrength = 0.2;
            mat.metallic = 0.0;
        }
        else if (id == MAT_GUN_BARREL) {
            mat.baseColor = vec3(0.02);
            mat.metallic = 1.0;
            mat.specularStrength = 0.2;
        }
        else if (id == MAT_COCKPIT_GLASS) {
            mat = makeGlass(vec3(0.6, 0.7, 1.0), 1.45);
        }
        else if (id == MAT_WINDOW_FRAME) {
            mat.baseColor = vec3(0.10);
            mat.metallic = 1.0;
        }
        else if (id == MAT_LASER_EMISSIVE) {
            mat.baseColor = vec3(0.30, 1.00, 0.30);
            mat.specularStrength = 0.0;
            mat.fakeSpecularColor = vec3(0.3, 1.0, 0.3);
            mat.fakeSpecularPower = 1.0;
            mat.rimPower = 0.5;
        }

        return mat;
    }

    #endif
    ```
<!--
if we want to link the github repo
-->

Usage: `#include "materials/material//material_library.glsl"`

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/material_library.glsl)

---
