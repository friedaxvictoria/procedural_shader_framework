// Shader: SDF Sphere Raymarch Shader
// Category: Geometry
// Description:
// This module defines core functions for rendering a sphere
//    using Signed Distance Fields (SDF) and ray marching.
//
//    It includes:
//      - SphereSDF: computes the signed distance from a point to a sphere
//                  input:
//                      p: The position in 3D space where the distance is evaluated.
//                      center: The center of the sphere.
//                      radius: The radius of the sphere.
//                  output:
//                      The signed distance from point p to the sphere surface.
//      - RayMarch: performs sphere-specific ray marching to find surface intersections
//                  input: 
//                      ro: Ray origin – typically the camera position.
//                      rd: Ray direction – normalized vector pointing into the scene.
//                      center: The center of the sphere.
//                      radius: The radius of the sphere.
//                  output:
//                      The total distance traveled along the ray.
//      - GetNormal: estimates the surface normal using central differences on the SDF
//                  input:
//                       p: The position in 3D space where the distance is evaluated.
//                       center: The center of the sphere.
//                       radius: The radius of the sphere.
//                  output:
//                       The normalized surface normal at point p.
//    Use this module in your main shader to render SDF-based spheres
//    with lighting and shading effects.
// Screenshot: screenshots/geometry/sphere.png
// From Ruimin Ma

#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURF_DIST 0.01

float SphereSDF(vec3 p, vec3 center, float radius) {
    return length(p - center) - radius;
}

float RayMarch(vec3 ro, vec3 rd, vec3 center,  float radius) {
    float dO = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = SphereSDF(p, center, radius);
        dO += dS;
        if (dS < SURF_DIST || dO > MAX_DIST) break;
    }
    return dO;
}

// Compute normal from SDF using finite differences
vec3 GetNormal(vec3 p, vec3 center, float radius) {
    float eps = 0.001;
    vec2 h = vec2(eps, 0.0);
    float dx = SphereSDF(p + vec3(h.x, h.y, h.y), center, radius) - SphereSDF(p - vec3(h.x, h.y, h.y), center, radius);
    float dy = SphereSDF(p + vec3(h.y, h.x, h.y), center, radius) - SphereSDF(p - vec3(h.y, h.x, h.y), center, radius);
    float dz = SphereSDF(p + vec3(h.y, h.y, h.x), center, radius) - SphereSDF(p - vec3(h.y, h.y, h.x), center, radius);
    return normalize(vec3(dx, dy, dz));
}