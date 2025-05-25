// Shader: TIE Fighter Geometry
// Category: Geometry
// Description:
//   Core geometry module that defines a complete TIE‑Fighter via Signed Distance
//   Fields (SDF) and supplies helper routines for ray‑marching visual previews.
//   
//   It includes:
//     – Primitive Helpers
//         • dot2      : squared‑length utility
//         • rot       : 2×2 rotation matrix
//         • opModPolar: polar repetition helper
//     – Basic SDF Primitives
//         • sdBox, sdHex, sdPlane, sdTri, sdCyl
//     – TIE Construction
//         • sdWings   : wing panel SDF
//         • sdTie     : full fighter SDF
//         • scene     : current scene distance field (single TIE)
//     – Utility Routines
//         • getNormal : central‑difference normal estimation on the SDF
//         • raymarch  : sphere‑tracing loop (120 steps, 200‑unit max)
//   Use this module together with dedicated lighting, material and noise files
//   for a full PBR render pipeline.
// Screenshot: screenshots/geometry/TIE_Fighter.png
// From Ruimin Ma

#define MAX_STEPS 120
#define MAX_DIST  200.0
#define SURF_DIST 0.001

//---------------------------------------------------
// Primitive helpers
//---------------------------------------------------
float dot2(vec3 v) { return dot(v, v); }

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

vec2 opModPolar(vec2 p, float n, float o) {
    float ang = 3.141 / n;
    float a  = mod(atan(p.y, p.x) + ang + o, 2. * ang) - ang;
    return length(p) * vec2(cos(a), sin(a));
}

//---------------------------------------------------
// Basic SDF primitives
//---------------------------------------------------
float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.);
}

float sdHex(vec3 p, vec2 h) {
    const vec3 k = vec3(-0.866, 0.5, 0.577);
    p = abs(p);
    p.xy -= 2. * min(dot(k.xy, p.xy), 0.) * k.xy;
    vec2 d = vec2(length(p.xy - vec2(clamp(p.x, -k.z * h.x, k.z * h.x), h.x)) *
                  sign(p.y - h.x),
                  p.z - h.y);
    return min(max(d.x, d.y), 0.) + length(max(d, 0.));
}

float sdPlane(vec3 p, vec3 n) { return dot(p, n); }

float sdTri(vec3 p, vec3 a, vec3 b, vec3 c) {
    vec3 ba = b - a, pa = p - a;
    vec3 cb = c - b, pb = p - b;
    vec3 ac = a - c, pc = p - c;
    vec3 n  = cross(ba, ac);
    return sqrt((sign(dot(cross(ba, n), pa)) +
                 sign(dot(cross(cb, n), pb)) +
                 sign(dot(cross(ac, n), pc)) < 2.)
                 ? min(min(dot2(ba * clamp(dot(ba, pa) / dot2(ba), 0., 1.) - pa),
                         dot2(cb * clamp(dot(cb, pb) / dot2(cb), 0., 1.) - pb)),
                       dot2(ac * clamp(dot(ac, pc) / dot2(ac), 0., 1.) - pc))
                 : dot(n, pa) * dot(n, pa) / dot2(n));
}

float sdCyl(vec3 p, vec2 hr) {
    vec2 d = abs(vec2(length(p.xy), p.z)) - hr;
    return min(max(d.x, d.y), 0.) + length(max(d, 0.));
}

//---------------------------------------------------
// Wing & fighter SDFs
//---------------------------------------------------
float sdWings(vec3 p) {
    p.xy = abs(p.xy);
    p.z  = abs(p.z) - 2.3;
    return min(sdTri(p, vec3(0), vec3(2, 3, 0), vec3(-2, 3, 0)),
               sdTri(p, vec3(0), vec3(3.3, 0, 0), vec3(2, 3, 0))) - 0.03;
}

float sdTie(vec3 p) {
    p = p.zyx - vec3(10.0, 0.0, 0.0); // centre the model

    // wings first (cheap early exit)
    float d = sdWings(p);
    if (d > 2.5) return d;

    // --- wing ribs
    vec3 op = p;
    p.xy = abs(p.xy);
    p.z  = abs(p.z) - 2.3;
    float f = 0.0;
    float rib = 1e5;
    if ((f = abs(p.y)) < 0.1)                       rib = 0.03 + step(f, 0.025) * 0.02;
    else if ((f = abs(p.y - p.x * 1.5)) < 0.15)     rib = 0.03 + step(f, 0.025) * 0.02;
    else if (abs(p.y - 3.0) < 0.1)                  rib = 0.03;
    else if (abs(p.x - 3.3 + p.y * 0.43) < 0.1)     rib = 0.03;
    if (rib < 1e5) d -= rib;

    // --- centre hex & cross‑bar
    float center = min(sdHex(p, vec2(0.7, 0.06)), sdHex(p, vec2(0.5, 0.12)));
    center = min(center, sdCyl(op, vec2(mix(0.21, 0.23, step(p.y, 0.04)), 2.3)));

    p.z  = abs(p.z + 0.8) - 0.5;
    f    = sdCyl(p, vec2(mix(0.21, 0.33, (p.z + 0.33) / 0.48), 0.24));
    p.x -= 0.25; p.z += 0.02;
    center = min(center, max(f, -sdBox(p, vec3(0.1, 0.4, 0.08))));
    d = min(d, center);

    // --- cockpit supports
    p = op; p.yz = abs(p.yz);
    d = min(d, sdTri(p, vec3(0), vec3(0, 0.8, 0), vec3(0, 0, 2)) - 0.05);

    // --- cockpit sphere
    f = step(0.75, p.y);
    d = min(d, length(op) - 0.9 - 0.02 * (f + step(p.y, 0.03) + f * step(p.z, 0.1)));

    // --- cockpit glass & frame
    p = op; p.x += 0.27; p.yz = opModPolar(p.yz, 8.0, 0.4);
    d = min(d, max(length(p) - 0.7,
                   sdPlane(p + vec3(0.77, 0.0, 0.0), vec3(vec2(-1, 0) * rot(0.5), 0))));
    d = min(d, max(length(p) - 0.71, 0.45 - length(p.yz)));

    // --- gun barrels
    p = op; p.x += 0.7; p.y += 0.6; p.z = abs(p.z) - 0.2;
    d = min(d, sdCyl(p.zyx, vec2(0.05, 0.2)));

    return d;
}

//---------------------------------------------------
// Scene wrapper (single ship for now)
//---------------------------------------------------
float scene(vec3 position) {
    return sdTie(position);
}

//---------------------------------------------------
// Normal estimation (central differences)
//---------------------------------------------------
vec3 getNormal(vec3 pos, float h) {
    vec2 e = vec2(h, 0.0);
    return normalize(vec3(
        scene(pos + e.xyy) - scene(pos - e.xyy),
        scene(pos + e.yxy) - scene(pos - e.yxy),
        scene(pos + e.yyx) - scene(pos - e.yyx)));
}

//---------------------------------------------------
// Ray‑march loop (sphere tracing)
//---------------------------------------------------
float raymarch(vec3 ro, vec3 rd) {
    float distAccum = 0.0;
    for (int i = 0; i < MAX_STEPS; ++i) {
        float d = scene(ro + rd * distAccum);
        if (d < SURF_DIST) return distAccum;
        if (distAccum > MAX_DIST) break;
        distAccum += d;
    }
    return -1.0;
}

//---------------------------------------------------
// Camera ray helper (optional)
//---------------------------------------------------
vec3 getRayDir(vec3 ro, vec3 lookAt, vec2 uv) {
    vec3 fwd   = normalize(lookAt - ro);
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), fwd));
    vec3 up    = cross(fwd, right);
    return normalize(uv.x * right + uv.y * up + fwd);
}
