// Shader: Phong lighting model
// Category: lighting
// Description:
//    Implements the Phong lighting model with ambient, diffuse, and specular
//    components. Can be used for basic BRDF simulation in raymarching or raster shaders.
// Inputs:
//   N: surface normal (unit vector)
//   L: light direction (from surface to light, unit vector)
//   V: view direction (from surface to camera, unit vector)
//   lightColor: RGB color of the light
//   ambient: ambient light intensity
//   diffuseColor: material diffuse color
//   specularColor: material specular color
//   shininess: specular exponent (higher = sharper highlight)
//
// Output:
//   RGB color of the final shading
// Usage:
// #include "lighting/phong.glsl"
// These can be used as default parameters
// col = phongLighting(
//     N, L, V,
//     vec3(1.0),                  // lightColor
//     vec3(0.2),                  // ambient
//     vec3(0.6, 0.6, 0.6),        // diffuse color
//     vec3(1.0),                  // specular color
//     32.0                       // shininess
// );
// Screenshot: screenshots/lighting/Phong lighting model.png
// From Ruimin Ma

vec3 phongLighting(
    vec3 N, vec3 L, vec3 V,
    vec3 lightColor,
    vec3 ambient,
    vec3 diffuseColor,
    vec3 specularColor,
    float shininess
) {
    vec3 R = reflect(-L, N); // reflection vector
    float diff = max(dot(N, L), 0.0);
    float spec = pow(max(dot(R, V), 0.0), shininess);

    return ambient +
           diff * diffuseColor * lightColor +
           spec * specularColor;
}
