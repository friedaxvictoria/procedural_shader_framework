// Shader: Dielectric material constructor
// Category: materials
// Description:
//    Defines a dielectric (non-metal) material with colored diffuse,
//    white specular highlights, adjustable roughness, and index of refraction (IOR).
//
// Inputs:
//   diffuseColor: RGB base color of the material
//   roughness: GGX microfacet width, controls highlight sharpness
//   ior: index of refraction (e.g., 1.5 for glass)
//
// Output:
//   A Material struct used in lighting models
//
// Usage:
//   Material mat = makeDielectric(vec3(0.5, 0.2, 0.1), 0.05, 1.5);
// Screenshot: screenshots/materials/dielectric.png
// From: Ruimin Ma

struct Material {
    vec3 diffuseColor;
    vec3 specularColor;
    float roughness;
    float ior;
    int brdfType; // 0 = Blinn, 1 = Phong
};

Material makeDielectric(vec3 diffuseColor, float roughness, float ior) {
    Material mat;
    mat.diffuseColor = diffuseColor;
    mat.specularColor = vec3(1.0); // white highlight
    mat.roughness = roughness;
    mat.ior = ior;
    mat.brdfType = 0; // Blinn by default
    return mat;
}
