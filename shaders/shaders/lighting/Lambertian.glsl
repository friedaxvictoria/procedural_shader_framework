// Lambertian diffuse shading shader
// Category: Lighting
// Description: 
//    This module implements Lambertian diffuse lighting,
//    one of the simplest and most widely used BRDF models.
//
//    The function computes the diffuse reflection from a surface
//    based on the angle between the surface normal and the direction
//    toward the light source.
//    input:
//          normal: surface normal (unit vector)
//          lightDir: direction from surface point toward light (unit vector)
//          lightColor: color/intensity of the light
// Screenshot: screenshots/lighting/Lambertian.png
// From Ruimin Ma

vec3 lambertDiffuse(vec3 normal, vec3 lightDir, vec3 lightColor) {
    float diff = max(dot(normal, lightDir), 0.0);
    return lightColor * diff;
}
