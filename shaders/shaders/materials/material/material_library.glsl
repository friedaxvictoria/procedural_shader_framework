// ==========================================
// Module: Material Library & Registry
// Category: Material
// Description:
//   Centralized material registration system mapping material IDs
//   to constructed MaterialParams using standardized presets.
//   Designed for use with ID-based scene descriptions (e.g. SDF hit IDs).
//
// Dependencies:
//   - MaterialParams (from material_params.glsl)
//   - Material preset constructors (from material_presets.glsl)
//   - Noise function n31(vec3) if brushed metal is used
// ==========================================

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
