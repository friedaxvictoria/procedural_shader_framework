// Shader: Metal (Phong-GGX) material constructor
// Category: materials
// Description:
//    Defines a colored metal material with Phong-style specular reflection,
//    GGX roughness model, and no diffuse component. Suitable for legacy specular look.
//
// Inputs:
//   specularColor: RGB highlight color of the metal
//   roughness: microfacet roughness
//
// Output:
//   A Material struct used in lighting models
//
// Usage:
//   Material mat = makeMetalPhong(vec3(1.0, 0.5, 0.1), 0.3);
// Screenshot: screenshots/materials/metal_phong.png
// From: Ruimin Ma

struct Material {
    vec3 diffuseColor;
    vec3 specularColor;
    float roughness;
    float ior;
    int brdfType; // 0 = Blinn, 1 = Phong
};

Material makeMetalPhong(vec3 specularColor, float roughness) {
    Material mat;
    mat.diffuseColor = vec3(0.0); // metals have no diffuse
    mat.specularColor = specularColor;
    mat.roughness = roughness;
    mat.ior = 0.0;
    mat.brdfType = 1; // Phong
    return mat;
}
