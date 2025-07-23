// ==========================================
// Module: Volume Material Presets
// Author：Xuetong Fu
// Category: Volume Material
// Description:
//   Provides factory functions for constructing VolMaterialParams
//   for different types of volumetric media, including cloud, fog,
//   flame, smoke, magic effects, and customizable default presets.
//
//   These are intended to be used in the vol_mat_library.glsl
//   registration function or directly in volume evaluation code.
//
// Dependencies:
//   - VolMaterialParams structure (vol_mat_params.glsl)
// ==========================================

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

#endif // VOLUME_MATERIAL_PRESETS_GLSL
