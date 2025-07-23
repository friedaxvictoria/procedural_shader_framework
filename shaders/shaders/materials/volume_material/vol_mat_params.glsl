// --------------------------------------------------------------------
// Author：Xuetong Fu
// VolMaterialParams: Volumetric medium appearance & interaction
// --------------------------------------------------------------------

#ifndef VOL_MAT_PARAMS_GLSL
#define VOL_MAT_PARAMS_GLSL

struct VolMaterialParams {
    vec3 baseColor;           // Intrinsic color of the medium (e.g., white for clouds, orange for flames)
    float densityScale;       // Density multiplier controlling opacity and absorption strength

    // Emission (self-illumination) properties
    float emissionStrength;   // Strength of light emitted by the medium itself
    vec3 emissionColor;       // Emission color (if different from baseColor)

    // Scattering properties
    float scatteringCoeff;    // Scattering strength (higher = more light bounces)
    float absorptionCoeff;    // Absorption strength (higher = faster light decay)
    float anisotropy;         // Phase function anisotropy [-1, 1], 0 = isotropic, >0 = forward scattering

    // Optional for stylized or dynamic effects
    float temperature;        // Optional scalar used for color remapping or animation (e.g., flame ramp)
    float noiseStrength;      // Optional density modulation by procedural noise
};

#endif
