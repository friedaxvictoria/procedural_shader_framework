<div class="container">
    <h1 class="main-heading">Oriented Box Intersection</h1>
    <blockquote class="author">by Ruimin Ma</blockquote>
</div>

- **Category:** Rendering

- **Shader Type:** Oriented bounding box ray intersection

- **Input:** 

  `ro`: Ray origin in world space
  
  `rd`: Ray direction (normalized)
  
  `boxPos`: Center position of the box
  
  `halfSize`: Half-extents in local x/y/z
  
  `rot`: Box rotation matrix (local → world)

---

## 🧠 Algorithm

### 1.`rm_traceBox(...)`
This function performs an analytic intersection between a ray and a rotated box using six face tests.

---

#### 1. **Each face is treated as a rotated quad**:

The function calls `rm_traceQuad(...)` for all 6 faces:

- 2 front/back (Z)  
- 2 left/right (X)  
- 2 top/bottom (Y)

---

#### 2. **Intersect ray with each face**:

For a face at position **p** with normal **n**, compute:

$$
t = \frac{(\mathbf{p} - \mathbf{ro}) \cdot \mathbf{n}}{\mathbf{rd} \cdot \mathbf{n}}
$$

Then project the hit point into the local box space and verify it lies within the rectangle.

---

#### 3. **Find earliest valid hit time (`tEnter`)**:

$$
t_{\text{enter}} = \min \{ t_0, t_1, ..., t_5 \} \quad \text{(where } t_i \geq 0\text{)}
$$

If all intersections are negative, return `vec2(-1.0)` for a miss.

---

#### 4. **Find earliest valid exit (`tExit`) ≠ `tEnter`**:

Scan remaining faces to get the nearest valid exit distance greater than `tEnter`.

---

#### 5. **Return the result**:

```glsl
return vec2(tEnter, tExit);
```

---

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `ro` | Ray origin (camera position in world space) | — | Starting point of ray |
| `rd` | Ray direction (normalized) | — | Direction of marching |
| `boxPos` | Center of the box in world space | — | Midpoint of box volume |
| `halfSize` | Half extents of the box in local space | — | Dimensions along x, y, z directions |
| `rot` | Rotation matrix from local box space to world | —     | Use `rm_rotX/Y/Z()` to build it |
| output | `vec2(tEnter, tExit)` or `vec2(-1.0)` if missed | — | tEnter < 0.0 → miss; else [entry, exit] ray segment inside |

## 💻 Code
`rm_traceBox` tests whether a ray intersects a rotated box (OBB) and returns the entry and exit distances along the ray. It uses face-by-face analytical tests for robust culling and sub-segment restriction of more expensive ray evaluations.

```glsl
#ifndef RAY_BOX_INTERSECT_GLSL
#define RAY_BOX_INTERSECT_GLSL

/* 
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
```

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/rendering/ray_box_intersect.glsl)
