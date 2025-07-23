// ===============================================================
// Module: VolumeLightingContext
// Author: Xuetong Fu
// Category: Volume Lighting
// Description:
//   Defines lighting context structures for volumetric shading.
//   These contexts are passed into volumetric lighting functions
//   to provide necessary geometric and optical parameters.
// ===============================================================

#ifndef VOL_LIT_CONTEXT_GLSL
#define VOL_LIT_CONTEXT_GLSL

// ---------------------------------------------------------------
// Local Volume Context
// Used for lighting computations on bounded volume rendering.
// ---------------------------------------------------------------
struct VolCtxLocal {
    vec3 position;       // World-space sample position inside the volume
    vec3 viewDir;        // Direction from sample to camera (normalized)
    vec3 lightDir;       // Direction from sample to light source (normalized)
    vec3 lightColor;     // RGB intensity of the light source
    vec3 ambient;        // Ambient light contribution (global fill light)
    float stepSize;      // Raymarch step size at this sample (used for absorption)
};

VolCtxLocal createVolCtxLocal(
    vec3 position,
    vec3 viewDir,
    vec3 lightDir,
    vec3 lightColor,
    vec3 ambient,
    float stepSize
) {
    VolCtxLocal ctx;
    ctx.position = position;
    ctx.viewDir = viewDir;
    ctx.lightDir = lightDir;
    ctx.lightColor = lightColor;
    ctx.ambient = ambient;
    ctx.stepSize = stepSize;
    return ctx;
}

#endif
