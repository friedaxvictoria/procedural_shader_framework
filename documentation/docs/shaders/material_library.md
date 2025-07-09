#  🧩 Material Library Shader

<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added -->

- **Category:** Material
- **Author:** Xuetong Fu
- **Shader Type:** ID-based Material Registration  
- **Input Requirements:** id, uv

---

## 🧠 Algorithm

### 🔷 Core Concept

This module implements a centralized material registry that assigns physically-based surface properties to scene objects based on integer material IDs. The logic is modular and designed for reusability across both general-purpose and scene-specific materials.

- **Default Fallback:** All materials begin from a createDefaultMaterialParams() base, ensuring safe fallback values if no match is found.
- **ID-Based Selection:** Each object in the scene carries a material ID. The function getMaterialByID(id, uv) uses conditional branches to map these IDs to corresponding MaterialParams.
- **Preset Construction:** Common material types (e.g., plastic, glass, metal) are built using predefined constructor functions such as makePlastic, makeGlass, or makeMetalBrushed. These functions return consistent and physically meaningful parameter sets.
- **UV-Driven Variations:** Certain materials use the uv coordinate input to introduce visual detail that varies across the surface.

---
## 🎛️ Parameters

| Name | Description | Format | Default |
|------|-------------|-------|---------|
| `id`  | Material ID used to select a predefined material preset. | Integer  | —       |
| `uv`  | The uv parameter typically represents a spatial coordinate that introduces local variation into the material appearance. | vec2 | —      |

---

## 💻 Shader Code & Includes
<!--
if you want to put small code snippet
-->
```glsl
    // Paste full GLSL or HLSL code here

  ```

<!--
if you want to put small code snippet and make it appereable and dissapear
-->
??? note "📄 sdf_updated.gdshader"
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

        #endif // MATERIAL_LIBRARY_GLSL
    ```
<!--
if we want to link the github repo
-->
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/materials/material/material_library.glsl)

---
