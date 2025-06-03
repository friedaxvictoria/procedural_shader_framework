// lighting_context.glsl
// --------------------------------------------------------------------
// LightingContext: Geometric and lighting info used in shading.
// --------------------------------------------------------------------

#ifndef LIGHTING_CONTEXT_GLSL
#define LIGHTING_CONTEXT_GLSL

struct LightingContext {
    vec3 position;    // World-space fragment position
    vec3 normal;      // Normal at the surface point (normalized)
    vec3 viewDir;     // Direction from surface to camera (normalized)
    vec3 lightDir;    // Direction from surface to light (normalized)
    vec3 lightColor;  // RGB intensity of the light source
    vec3 ambient;     // Ambient light contribution
};

LightingContext createLightingContext(
    vec3 position,
    vec3 normal,
    vec3 viewDir,
    vec3 lightDir,
    vec3 lightColor,
    vec3 ambient
) {
    LightingContext ctx;
    ctx.position = position;
    ctx.normal = normal;
    ctx.viewDir = viewDir;
    ctx.lightDir = lightDir;
    ctx.lightColor = lightColor;
    ctx.ambient = ambient;
    return ctx;
}

#endif
