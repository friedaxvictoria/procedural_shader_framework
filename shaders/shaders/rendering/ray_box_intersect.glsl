#ifndef RAY_BOX_INTERSECT_GLSL
#define RAY_BOX_INTERSECT_GLSL

/* -----------------------------------------------------------------------------
   Oriented Bounding Box (OBB) – Ray / Box Intersection Helper
   -----------------------------------------------------------------------------
   A light‑weight first‑pass culling routine: test a world‑space ray against an
   *oriented* bounding box.  Typical use‑case is to clip expensive SDF or other
   ray‑based evaluations to the sub‑segment of the ray that actually passes
   through the object.
   https://www.shadertoy.com/view/MlKGWK

   full example combined with existing RayMarch + GetNormal helpers
   -------------------------------------------------------------------------
       // provided in our project:
       //   bool  RayMarch(vec3 ro, vec3 rd, out float dist);
       //   vec3  GetNormal(vec3 p);

       // (1) cull with OBB
       vec2 hit = rm_traceBox(ro, rd, u_BoxPos, u_HalfSize, u_BoxRot);
       if (hit.x >= 0.0)                     // ray crosses the box
       {
           // (2) march *inside* the box only
           vec3  marchOrigin = ro + rd * hit.x;      // start on entry face
           float boxSegment  = hit.y - hit.x;        // allowed travel

           float distInside;                         // distance marched
           bool  surfaceHit = RayMarch(marchOrigin, rd, distInside);

           if (surfaceHit && distInside <= boxSegment)
           {
               // (3) shading
               vec3 hitPos = marchOrigin + rd * distInside;
               vec3 n      = GetNormal(hitPos);
               vec3 color  = ShadeLambert(n, baseColor, lightDir);
               // ...
           }
       }

   ------------------------------------------------------------------------- */

// PI constants --------------------------------------------------------------
const float PI  = 3.141592653589793;
const float PI2 = 1.5707963267948966;   // PI / 2

// rotation helpers (row‑major 3×3) -----------------------------------------
mat3 rm_rotX(float a){
    float s = sin(a), c = cos(a);
    return mat3( 1.0, 0.0, 0.0,
                 0.0,   c,  -s,
                 0.0,   s,   c);
}
mat3 rm_rotY(float a){
    float s = sin(a), c = cos(a);
    return mat3(   c, 0.0,   s,
                 0.0, 1.0, 0.0,
                  -s, 0.0,   c);
}
mat3 rm_rotZ(float a){
    float s = sin(a), c = cos(a);
    return mat3(   c,  -s, 0.0,
                   s,   c, 0.0,
                 0.0, 0.0, 1.0);
}

/* ---------------------------------------------------------------------------
   rm_traceQuad  – analytic ray / rectangle intersection (internal)
   ---------------------------------------------------------------------------
   ro(vec3)      : ray origin (world space)
   rd(vec3)      : *normalised* ray direction
   quadPos(vec3) : centre of the quad (world space)
   halfSize(vec2): half‑extent in local X & Y
   rot(mat3)     : local → world rotation
   pivot(vec3)   : ±halfSize.z, distinguishes the two faces

   returns: t along the ray (<0.0 = miss)                                           */
float rm_traceQuad(in vec3 ro, in vec3 rd,
                   in vec3 quadPos,
                   in vec2 halfSize,
                   in mat3 rot,
                   in vec3 pivot)
{
    vec3 planePos = quadPos + rot * pivot;
    vec3 planeN   = rot * vec3(0.0, 0.0, -1.0);

    float denom = dot(rd, planeN);
    if (abs(denom) < 1e-5) return -1.0;           // ray ‖ plane

    float t = dot(planePos - ro, planeN) / denom;
    if (t < 0.0) return -1.0;                     // plane behind origin

    // bounds check in quad local space
    vec3 hitP = transpose(rot) * (ro + rd * t - quadPos);
    if (abs(hitP.x) > halfSize.x || abs(hitP.y) > halfSize.y) return -1.0;

    return t;
}

// positive‑only min helper ---------------------------------------------------
float rm_pmin(float a, float b){
    return (a >= 0.0 && b >= 0.0) ? min(a, b) :
           (a >= 0.0)             ? a         :
                                     b;
}

/* ---------------------------------------------------------------------------
   rm_traceBox – PUBLIC API
   ---------------------------------------------------------------------------
   ro(vec3)      : ray origin (world space)
   rd(vec3)      : *normalised* ray direction
   boxPos(vec3)  : box centre (world space)
   halfSize(vec3): half‑extents in local/model space
   rot(mat3)     : model → world rotation

   returns vec2(tEnter, tExit)
           tEnter < 0.0  → miss
           otherwise     → ray inside box for t ∈ [tEnter, tExit]               */
vec2 rm_traceBox(in vec3 ro, in vec3 rd,
                 in vec3 boxPos,
                 in vec3 halfSize,
                 in mat3 rot)
{
    vec4 piv = vec4(halfSize, 0.0);

    float t0 = rm_traceQuad(ro, rd, boxPos,       halfSize.xy,       rot,             piv.wwz);
    float t1 = rm_traceQuad(ro, rd, boxPos,       halfSize.xy,       rot,            -piv.wwz);

    float t2 = rm_traceQuad(ro, rd, boxPos, halfSize.zy, rot * rm_rotY(PI2),  piv.wwx);
    float t3 = rm_traceQuad(ro, rd, boxPos, halfSize.zy, rot * rm_rotY(PI2), -piv.wwx);

    float t4 = rm_traceQuad(ro, rd, boxPos, halfSize.xz, rot * rm_rotX(PI2), -piv.wwy);
    float t5 = rm_traceQuad(ro, rd, boxPos, halfSize.xz, rot * rm_rotX(PI2),  piv.wwy);

    float tEnter = rm_pmin(rm_pmin(t0, t1),
                           rm_pmin(rm_pmin(t2, t3), rm_pmin(t4, t5)));
    if (tEnter < 0.0) return vec2(-1.0);

    float tExit = 1e30;
    if (t0 > 0.0 && t0 != tEnter) tExit = min(tExit, t0);
    if (t1 > 0.0 && t1 != tEnter) tExit = min(tExit, t1);
    if (t2 > 0.0 && t2 != tEnter) tExit = min(tExit, t2);
    if (t3 > 0.0 && t3 != tEnter) tExit = min(tExit, t3);
    if (t4 > 0.0 && t4 != tEnter) tExit = min(tExit, t4);
    if (t5 > 0.0 && t5 != tEnter) tExit = min(tExit, t5);

    return vec2(tEnter, tExit);
}

#endif // RAY_BOX_INTERSECT_GLSL
