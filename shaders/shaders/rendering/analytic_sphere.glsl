/*  Analytic ray–sphere intersection
    ---------------------------------------------------------------
    Inputs
      ro      : ray origin      (world space)
      rd      : ray direction   (must be normalised)
      center  : sphere centre   (world space)
      radius  : sphere radius

    Output
      float   :  nearest positive hit distance  (t  > 0)
                 –1.0 if the ray misses the sphere
*/

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