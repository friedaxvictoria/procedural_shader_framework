// ==========================================
// Module: Volumetric Lighting Shader
// Category: Volume Lighting
// Description: 
//   Provides lighting evaluation functions for volumetric rendering.
//   Supports emission, phase-based scattering (HG, Rayleigh, isotropic),
//   absorption and ambient contribution, using step-wise raymarching.
// ==========================================

#ifndef VOL_LIT_GLSL
#define VOL_LIT_GLSL

// ------------------------------------------------
// Local Volumetric Cloud Lighting (used for cloud)
// Input:
//   VolumeSample s:
//      - vec3: position       : world-space sample position
//      - float: density       : local sample density
//      - vec3: baseColor      : intrinsic color at this point
//      - float: emission      : emission value at this point
//
//   VolCtxLocal ctx:
//      - vec3: viewDir        : direction to camera
//      - vec3: lightDir       : direction to light
//      - vec3: lightColor     : RGB light source intensity
//      - vec3: ambient        : ambient environment light
//      - float: stepSize      : integration step size
//
//   VolMaterialParams mat:
//      - baseColor, emissionColor, scatteringCoeff, absorptionCoeff, etc.
// 
// Output:
//   - vec4: RGB lighting result + alpha opacity per step
// ------------------------------------------------
vec4 applyVolLitCloud(
    VolumeSample s,
    VolumeLightingContextI ctx,
    VolumeMaterialParams mat
) {
    // === Phase Function Selection ===
    float cosTheta = dot(ctx.viewDir, ctx.lightDir);
    float phase = computePhaseIsotropic();

    // === Scattering ===
    vec3 scatter = vec3(0.0);
    if (mat.scatteringCoeff > 0.0 && s.density > 0.0) {
        scatter = mat.baseColor * ctx.lightColor * phase * mat.scatteringCoeff * s.density;
    }

    // === Emission ===
    vec3 emission = vec3(0.0);
    if (mat.emissionStrength > 0.0 && s.emission > 0.0) {
        emission = mat.emissionColor * mat.emissionStrength * s.emission;
    }

    return vec4((scatter + emission + ambient) * alpha, alpha);
    // === Ambient ===
    vec3 ambient = mat.baseColor * ctx.ambient * (0.2 + 0.8 * s.density);

    // === Absorption / Alpha ===
    float alpha = 1.0 - exp(-s.density * mat.absorptionCoeff * ctx.stepSize * 30.0);

    return vec4((scatter + emission + ambient) * (1.8 - alpha), alpha);
}