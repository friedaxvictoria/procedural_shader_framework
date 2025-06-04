// ==========================================
// Module: Integration
// Category: Volumetric Lighting
// Description:
//   Computes volumetric scattering from inside a bounded volume
//   (e.g., cloud layer) using step-based integration along a ray.
// ==========================================

uniform sampler2D NoiseTex;
uniform vec2 Resolution; 

// ------------------------------------------------------------
// Volume Sample
// Description:
//   Represents the **local physical properties** of a single point
//   sampled along a ray through a volumetric medium.
// Note:
//   This structure may be extended to support heterogeneous volumes with additional attributes.
// ------------------------------------------------------------
struct VolumeSample{
    float density;
    float emission;
};

// ------------------------------------------------------------
// Integrate Cloud
// Inputs:
//   - vec3 rayOrigin     : Start point of the viewing ray
//   - vec3 rayDir        : Direction of the ray (normalized)
//   - float rayLength    : Total distance the ray can travel
//   - float stepCount    : Max number of integration steps
//   - vec3 lightDir      : Direction to light source (normalized)
//   - vec3 lightColor    : Light source color/intensity
//   - vec3 ambient       : Global ambient light
//   - VolMaterialParams mat : Volumetric material parameters
//
// Output:
//   - vec4 RGBA color with accumulated light and alpha
//     (pre-multiplied alpha for compositing)
//
// Notes:
//   - Automatically determines entry/exit based on cloud height
//     bounds (CLOUD_BASE / CLOUD_TOP).
//   - Early exits for rays completely outside the volume bounds.
//   - Integrates using adaptive step size `dt`, with noise offset.
//   - Stops when accumulated alpha > 0.99 or t exceeds volume bounds.
// ------------------------------------------------------------
vec4 integrateCloud(vec3 rayOrigin, vec3 rayDir, float rayLength,
                    float stepCount, vec3 lightDir, vec3 lightColor, 
                    vec3 ambient, VolMaterialParams mat) {
    const float yb = CLOUD_BASE;
    const float yt = CLOUD_TOP;
    float tb = (yb - rayOrigin.y) / rayDir.y;
    float tt = (yt - rayOrigin.y) / rayDir.y;

    float tmin, tmax;
    if (rayOrigin.y > yt) {
        if (tt < 0.0) return vec4(0.0);
        tmin = tt; tmax = tb;
    }
    else if (rayOrigin.y < yb) {
        if (tb < 0.0) return vec4(0.0);
        tmin = tb; tmax = tt;
    }
    else {
        tmin = 0.0;
        tmax = rayLength;
        if (tt > 0.0) tmax = min(tmax, tt);
        if (tb > 0.0) tmax = min(tmax, tb);
    }

    vec4 accum = vec4(0.0);

    vec2 uv = gl_FragCoord.xy / Resolution;
    float jitter = texture(NoiseTex, uv).x;
    float t = tmin + 0.1 * jitter;

    for (int i = 0; i < int(stepCount); ++i) {
        float dt = max(0.05, 0.02 * t);
        vec3 p = rayOrigin + t * rayDir;

        float density = map(p, 5);
        if (density > 0.01) {
            VolumeSample s;
            s.density = density * mat.densityScale;
            s.emission = 0.0;

            VolCtxLocal ctx = createVolCtxLocal(
                p, -rayDir, lightDir, lightColor, ambient, dt
            );

            vec4 local = applyVolLitCloud(s, ctx, mat);       
            
            accum.rgb += (1.0 - accum.a) * local.a * local.rgb;
            accum.a += (1.0 - accum.a) * local.a;
        }

        t += dt;
        if (t > tmax || accum.a > 0.99) break;
    }

    return clamp(accum, 0.0, 1.0);
}
