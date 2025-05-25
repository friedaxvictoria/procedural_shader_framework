// Shader: TIE Fighter Lighting
// Category: Lighting
// Description:
//   Core lighting utilities for the TIE-Fighter SDF scene.
//   
//   External dependencies (must be provided by previously included modules):
//     • struct Hit  { float d; int id; vec3 uv; };
//     • float  T                         – global looped time (0‥40 s)
//     • Hit    sdTies(vec3)             – scene SDF query
//     • void   getMaterial(in Hit h,
//                          out vec3 baseColor,
//                          out float specScale);
//
//   Functions exposed by this file:
//     – calcN      : numeric normal estimation (tetrahedral offset)
//     – calcShadow : sun-shadow term (soft + hard mix)
//     – ao         : single-sample ambient occlusion
//     – lights     : final RGB lighting evaluation
// From Ruimin Ma

#ifndef TF_LIGHTING_GLSL
#define TF_LIGHTING_GLSL

//--------------------------------------------------
// 1. Surface normal via tetrahedral offsets
//--------------------------------------------------
vec3 calcN(vec3 p, float prox)
{
    float h = prox * 0.2;
    vec3  n = vec3(0.0);

    for (int i = 0; i < 4; ++i)
    {
        vec3 e = 0.005773 * (2.0 * vec3(((i + 3) >> 1) & 1,
                                         (i >> 1) & 1,
                                         (i      ) & 1) - 1.0);
        n += e * sdTies(p + e * h).d;
    }
    return normalize(n);
}

//--------------------------------------------------
// 2. Soft shadow (ray-march occlusion)
//--------------------------------------------------
float calcShadow(vec3 p, vec3 ld)
{
    float s = 1.0;
    float t = 1.0;
    for (float i = 0.0; i < 30.0; ++i)
    {
        float h = sdTies(p + ld * t).d;
        s = min(s, 30.0 * h / t);
        t += h;
        if (s < 0.001 || t > 100.0) break;
    }
    return clamp(s, 0.0, 1.0);
}

//--------------------------------------------------
// 3. Ambient occlusion (single sample)
//--------------------------------------------------
float ao(vec3 p, vec3 n, float h)
{
    return clamp(sdTies(p + h * n).d / h, 0.0, 1.0);
}

//--------------------------------------------------
// 4. Main lighting function
//--------------------------------------------------
vec3 lights(vec3 p, vec3 rd, float d, Hit h)
{
    // ---- material lookup
    vec3  baseColor;
    float specScale;
    getMaterial(h, baseColor, specScale);

    // ---- geometry & ambient terms
    vec3 n   = calcN(p, d);
    float am = mix(ao(p, n, 0.5), ao(p, n, 1.2), 0.75);

    // ---- key light + sky fill
    vec3  ld  = normalize(vec3(30.0, 50.0, -40.0) - p);
    float ldt = dot(ld, n);
    float key = max(0.0, 0.2 + 0.8 * ldt);
    float sky = max(0.0, 0.2 - 0.8 * ldt) * 0.3;
    float rim = clamp(n.y, 0.05, 1.0);

    vec3 lig = (key + sky) * am * mix(0.4, 1.0, calcShadow(p, ld)) *
               vec3(2.0, 1.8, 1.7) +
               rim * vec3(0.9, 0.95, 1.0);

    // ---- specular highlight (Blinn-Phong, sharp)
    float spe = smoothstep(0.0, 1.0,
                 pow(max(0.0, dot(rd, reflect(ld, n))), 50.0)) * specScale;

    return baseColor * lig + spe;
}

#endif // TF_LIGHTING_GLSL