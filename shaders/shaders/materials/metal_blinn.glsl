// Shader: Metal (Blinn-GGX) material constructor
// Category: materials
// Description:
//    Defines a colored metal material with no diffuse component,
//    colored specular reflection, Blinn-GGX highlights, and user-defined roughness.
//
// Inputs:
//   specularColor: RGB highlight color of the metal
//   roughness: microfacet roughness (controls highlight width)
//
// Output:
//   A Material struct used in lighting models
//
// Usage:
//   Material mat = makeMetalBlinn(vec3(1.0, 0.5, 0.1), 0.2);
// Screenshot: screenshots/materials/metal_blinn.png
// From: Ruimin Ma

struct Material {
    vec3 diffuseColor;
    vec3 specularColor;
    float roughness;
    float ior;
    int brdfType; // 0 = Blinn, 1 = Phong
};

Material makeMetalBlinn(vec3 specularColor, float roughness) {
    Material mat;
    mat.diffuseColor = vec3(0.0); // metals have no diffuse
    mat.specularColor = specularColor;
    mat.roughness = roughness;
    mat.ior = 0.0; // fully reflective, no transmission
    mat.brdfType = 0; // Blinn
    return mat;
}
