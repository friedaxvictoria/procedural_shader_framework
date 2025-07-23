// ==========================================
// Module: Volumetric Lighting Shader
// Author: Xuetong Fu
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
//      - float: density       : local sample density
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

// ------------------------------------------------
// Local Volumetric Fog Lighting (used for fog)
// Input:
//   VolumeSample s:
//      - float: density       : local sample density
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
vec4 applyVolLitFog(
    VolumeSample s,
    VolCtxLocal ctx,
    VolMaterialParams mat
) {
    // === Phase Function Selection ===
    float cosTheta = dot(ctx.viewDir, ctx.lightDir);
    float phase = computePhaseIsotropic(); // 雾为各向同性

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

    // === Ambient ===
    vec3 ambient = mat.baseColor * ctx.ambient * (0.1 + 0.3 * s.density); // 比云更稀薄、柔和

    // === Absorption / Alpha ===
    float alpha = 1.0 - exp(-s.density * mat.absorptionCoeff * ctx.stepSize * 10.0);

    // === Beam Enhancement ===
    vec3 beam = vec3(0.0);
    if (mat.beamBoost > 0.0) {
        beam = applyVolLitBeam(s.density, ctx, mat.anisotropy, mat.beamBoost);
    }

    // === Final Color Composition ===
    vec3 color = scatter + emission + ambient + beam;

    return vec4(color * (1.2 - alpha), alpha);
}
