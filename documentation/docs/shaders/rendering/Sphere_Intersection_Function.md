#  Sphere Intersection Function

- **Category:** Rendering

- **Author:** Ruimin Ma

- **Shader Type:** Analytic ray-sphere intersection

- **Input:** 

  `ro`: ray origin (world space)
  
  `rd`: ray direction (normalized)
  
  `center`: sphere center (world space)
  
  `radius`: sphere radius

---

## 🧠 Algorithm

### 1. `sphere(vec3 ro, vec3 rd, vec3 center, float radius)`
This function calculates the distance to the intersection point between a ray and a sphere using the standard quadratic formula:

1. The ray is translated so the sphere is centered at the origin.

2. The intersection condition is derived from solving:

   $$
   \left\| \mathbf{ro} + t \cdot \mathbf{rd} - \mathbf{center} \right\|^2 = r^2
   $$

   which expands to a quadratic equation in `t`:

   $$
   t^2 + 2bt + c = 0
   $$

3. The discriminant $d = b^2 - c$ determines whether a real root (intersection) exists.

4. If $d \geq 0$ and the closest root $t = -b - \sqrt{d} \geq 0$, then the ray hits the sphere.

5. Otherwise, return \`-1.0\` to indicate a miss.

This function returns the nearest positive hit distance `t` or `-1.0` if the ray misses the sphere.

---

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `ro` | Ray origin (camera position) | — | World-space coordinate |
| `rd` | Ray direction (normalized) | — | Must be normalized |
| `center` | Sphere center | — | World-space position |
| `radius` | Sphere radius | `>0` | Positive radius required |
| output | Hit distance or `-1.0` for miss | `>0 or -1` | Return `-1.0` if no intersection |



## 💻 Code
`sphere` analytically computes the intersection of a ray with a sphere by solving a quadratic equation. It returns the nearest positive hit distance or `-1.0` if there is no intersection.

```glsl
float sphere(vec3 ro, vec3 rd, vec3 center, float radius)
{
    /* shift the ray so the sphere is at the origin */
    vec3 rc = ro - center;                              // ray-to-centre vector

    /* coefficients of the quadratic  t² + 2·b·t + c = 0  (a = 1 because |rd| = 1) */
    float c = dot(rc, rc) - radius * radius;            // c = |rc|² − r²
    float b = dot(rd, rc);                              // b = rd·rc

    /* discriminant  d = b² − c  */
    float d = b*b - c;

    /* nearest root  t = −b − √d   (if d < 0 → imaginary roots) */
    float t  = -b - sqrt(abs(d));

    /* hit test:
         step(0, min(t,d)) → 1  when  d ≥ 0  *and*  t ≥ 0
                              0  otherwise                       */
    float st = step(0.0, min(t, d));

    /* mix( missValue , hitValue , st ) */
    return mix(-1.0, t, st);                             // –1.0 = miss
}

/*
usage example:
    float dist = sphere(ro, rd, p, 1.0); 
    vec3 normal = normalize(p - (ro+rd*dist));
*/
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/rendering/analytic_sphere.glsl)
