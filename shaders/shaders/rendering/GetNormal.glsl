// Compute a normal vector at point p by numerically estimating the gradient
// of the Signed Distance Field (SDF) or scalar field defined by Scene().
// This function uses central differences with a small epsilon step.
//
// input:
//   p    – The 3D position at which to estimate the normal.
// output:
//   A unit-length normal vector pointing “outward” from the surface.

vec3 GetNormal(vec3 p) {
    float eps = 0.001;
    vec2 h = vec2(eps, 0);
    float dx = Scene(p + vec3(h.x, h.y, h.y)) - Scene(p - vec3(h.x, h.y, h.y));
    float dy = Scene(p + vec3(h.y, h.x, h.y)) - Scene(p - vec3(h.y, h.x, h.y));
    float dz = Scene(p + vec3(h.y, h.y, h.x)) - Scene(p - vec3(h.y, h.y, h.x));
    return normalize(vec3(dx, dy, dz));
}
