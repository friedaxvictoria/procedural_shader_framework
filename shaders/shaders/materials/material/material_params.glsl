// --------------------------------------------------------------------
// MaterialParams: Surface reflectance & appearance properties.
// --------------------------------------------------------------------

#ifndef MATERIAL_PARAMS_GLSL
#define MATERIAL_PARAMS_GLSL

struct MaterialParams {
    vec3 baseColor;           // Diffuse/albedo base color
    vec3 specularColor;       // Specular reflection color
    float specularStrength;   // Specular intensity multiplier
    float shininess;          // Phong/Blinn specular exponent

    // Optional for PBR/stylized models
    float roughness;          // Surface microfacet roughness (PBR)
    float metallic;           // Degree of metallic reflection
    float rimPower;           // Exponent for rim lighting
    float fakeSpecularPower;  // Stylized highlight sharpness
    vec3 fakeSpecularColor;   // Stylized highlight color

    // Optional for refractive/translucent materials
    float ior;                // Index of Refraction (used in refraction)
    float refractionStrength; // Blending factor for refracted background
    vec3 refractionTint;     // Tint color applied to refracted background
};

#endif
