// ==========================================
// Module: Volume Material Library & Registry
// Author：Xuetong Fu
// Category: Volume Material
// Description:
//   Centralized registry mapping material IDs to volumetric
//   material presets for use in density fields (e.g., clouds, smoke, fire).
//
// Dependencies:
//   - VolMaterialParams (from vol_mat_params.glsl)
//   - Preset constructors (from vol_mat_presets.glsl)
// Output:
//   - VolMaterialParams: Initialized material struct for volume shading
// ==========================================

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

#endif // VOLUME_MATERIAL_LIBRARY_GLSL
