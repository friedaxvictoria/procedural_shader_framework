/*
calcNormal  camera-adaptive, tetrahedral normal estimation for SDF ray-marchers

  Replaces the textbook 6-tap central difference

      n = normalize(vec3(SDF(p+ε.xyy)-SDF(p-ε.xyy),
                         SDF(p+ε.yxy)-SDF(p-ε.yxy),
                         SDF(p+ε.yyx)-SDF(p-ε.yyx)));

  with a **4-tap “tetrahedron” stencil** whose radius grows with hit distance.
  This costs 4 instead of 6 SDF evaluations, eliminates axial bias and keeps
  detail crisp close-up while relaxing in the far field.
  https://www.shadertoy.com/view/XlsGz4

 Input:
    pos  : world-space position where the ray hit the surface (already SDF ≈ 0)
    ray  : incident ray direction, *normalized*
    t    : hit distance (camera → pos), used to scale the sampling pitch
 
  Output:
   A unit-length normal pointing outward from the surface.
*/
vec3 calcNormal( vec3 pos, vec3 ray, float t )
{
    float pitch = 0.5 * t / iResolution.x;
    pitch = max(pitch, 0.005);

    vec2 d = vec2(-1.0, 1.0) * pitch;

    vec3 p0 = pos + d.xxx;
    vec3 p1 = pos + d.xyy;
    vec3 p2 = pos + d.yxy;
    vec3 p3 = pos + d.yyx;

    float f0 = map(p0).x;
    float f1 = map(p1).x;
    float f2 = map(p2).x;
    float f3 = map(p3).x;

    vec3 grad = p0*f0 + p1*f1 + p2*f2 + p3*f3
              - pos*(f0 + f1 + f2 + f3);

    grad -= max(0.0, dot(grad, ray)) * ray;

    return normalize(grad);
}