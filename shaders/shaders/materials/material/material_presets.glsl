// ==========================================
// Module: Material Presets
// Category: Material
// Description:
//   Provides factory functions for constructing MaterialParams
//   for different types of materials, including default and
//   stylized presets such as plastic, glass, metal, and toon.
//
//   These are intended to be used in the material_library.glsl
//   registration function or directly in scene-specific shading.
//
// Dependencies:
//   - MaterialParams structure (material_params.glsl)
// ==========================================

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

#endif // MATERIAL_PRESETS_GLSL