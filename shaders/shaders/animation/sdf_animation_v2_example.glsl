// ===========================================================
// File: sdf_animation_v2_example.glsl
// Description:
//     Example shader demonstrating the use of functions from
//     sdf_animation_v2.glsl to build an animated SDF scene.
//
//     This scene includes:
//     - A red sphere animated with sinusoidal translation.
//     - A green round box orbiting around the origin.
//     - A blue torus that follows a TIE-fighter-like path and pulses.
//
//     Each object uses modular animation functions such as:
//         - animateTranslate()
//         - animateOrbit()
//         - animatePulseScale()
//         - tiePos()
//
//     The objects are defined using the SDF struct and animated over time.
//     Ray marching is used for rendering, with flat color output.
//
//     This is an example of how to compose dynamic scenes using
//     the reusable animation and SDF evaluation logic provided
//     in sdf_animation_v2.glsl.
//
// Screenshot: screenshots/animation/sdf_animation_v2_example.gif
//
// Author: Wanzhang He
// ===========================================================

// ==== Structs ====
struct SDF {
    int   type;       // 0 = sphere, 1 = round box, 2 = torus
    vec3  position;
    vec3  size;
    float radius;
};

struct Animation {
    int type;           // 1 = Translate, 2 = RotateSelf, 3 = Orbit, 4 = PulseScale, 5 = TIEPath
    vec4 moveParam;
    vec4 rotateParam;
};

// ==== Distance Functions ====
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdRoundBox(vec3 p, vec3 b, float r) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

float evaluateSDF(SDF sdf, vec3 p) {
    if (sdf.type == 0) return sdSphere(p - sdf.position, sdf.radius);
    if (sdf.type == 1) return sdRoundBox(p - sdf.position, sdf.size, sdf.radius);
    if (sdf.type == 2) return sdTorus(p - sdf.position, sdf.size.xy);
    return 1e5;
}

// ==== Animation Functions ====
float applyTimeMode(float t, int mode) {
    if (mode == 1) return sin(t);
    if (mode == 2) return abs(sin(t));
    return t;
}

vec3 rotateAroundAxis(vec3 pos, vec3 center, vec3 axis, float angle) {
    vec3 p = pos - center;
    float cosA = cos(angle);
    float sinA = sin(angle);
    return center +
        cosA * p +
        sinA * cross(axis, p) +
        (1.0 - cosA) * dot(axis, p) * axis;
}

SDF animateTranslate(SDF sdf, float t, vec4 param, int mode) {
    t = applyTimeMode(t, mode);
    vec3 dir = param.xyz;
    float speed = param.w;
    sdf.position += dir * sin(t * speed);
    return sdf;
}

SDF animateOrbit(SDF sdf, float t, vec4 centerSpeed, vec4 axisUnused, int mode) {
    t = applyTimeMode(t, mode);
    vec3 center = centerSpeed.xyz;
    float speed = centerSpeed.w;
    vec3 axis = vec3(0.0, 1.0, 0.0);
    float angle = t * speed;
    sdf.position = rotateAroundAxis(sdf.position, center, axis, angle);
    return sdf;
}

SDF animatePulseScale(SDF sdf, float t, vec4 freqAmp, int mode) {
    t = applyTimeMode(t, mode);
    float freq = freqAmp.x;
    float amp = freqAmp.y;
    float scale = 1.0 + sin(t * freq) * amp;
    sdf.size *= scale;
    sdf.radius *= scale;
    return sdf;
}

vec3 tiePos(vec3 p, float t) {
    float x = cos(t * 0.7);
    p += vec3(x, cos(t), sin(t * 1.1));
    p.xy *= mat2(cos(-x * 0.1), sin(-x * 0.1), -sin(-x * 0.1), cos(-x * 0.1));
    return p;
}
struct SDFResult {
    float dist;
    vec3 color;
};

SDFResult sceneSDF(vec3 p) {
    float t = iTime;

    // Sphere
    SDF sdf1;
    sdf1.type = 0;
    sdf1.position = vec3(-1.5, 0.0, 0.0);
    sdf1.radius = 0.4;
    sdf1 = animateTranslate(sdf1, t, vec4(1.0, 0.0, 0.0, 1.5), 1);
    float d1 = evaluateSDF(sdf1, p);
    vec3 c1 = vec3(1.0, 0.2, 0.2);

    // Green Round Box – orbits around the origin with radius 2.0
    SDF sdf2;
    sdf2.type = 1;
    sdf2.position = vec3(2.0, 0.0, 0.0);            // initial position on the orbit path
    sdf2.size = vec3(0.3);                          // half-size of the box
    sdf2.radius = 0.1;                              // corner roundness
    sdf2 = animateOrbit(
        sdf2,
        t,
        vec4(0.0, 0.0, 0.0, 1.0),                   // orbit around origin with speed 1.0
        vec4(0),                                    // unused rotation param
        0                                           // linear time mode
    );
    float d2 = evaluateSDF(sdf2, p);
    vec3 c2 = vec3(0.2, 1.0, 0.3);                  // green color


    // Torus
    SDF sdf3;
    sdf3.type = 2;
    sdf3.position = tiePos(vec3(1.0), t);
    sdf3.size = vec3(0.5, 0.15, 0.0);
    sdf3 = animatePulseScale(sdf3, t, vec4(3.0, 0.2, 0.0, 0.0), 2);
    float d3 = evaluateSDF(sdf3, p);
    vec3 c3 = vec3(0.3, 0.5, 1.0);

    // Select closest
    float d = d1;
    vec3 color = c1;
    if (d2 < d) { d = d2; color = c2; }
    if (d3 < d) { d = d3; color = c3; }

    return SDFResult(d, color);
}
float raymarch(vec3 ro, vec3 rd, out vec3 hit, out vec3 color) {
    float d = 0.0;
    for (int i = 0; i < 128; i++) {
        vec3 p = ro + rd * d;
        SDFResult res = sceneSDF(p);
        if (res.dist < 0.001) {
            hit = p;
            color = res.color;
            return d;
        }
        d += res.dist;
        if (d > 100.0) break;
    }
    return -1.0;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, 10.0);
    vec3 rd = normalize(vec3(uv, -1.5));

    vec3 hit, color;
    float dist = raymarch(ro, rd, hit, color);

    if (dist > 0.0) {
        fragColor = vec4(color, 1.0);  // No shading, pure color
    } else {
        fragColor = vec4(0.0);
    }
}
