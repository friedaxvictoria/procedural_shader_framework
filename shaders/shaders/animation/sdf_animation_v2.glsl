#ifndef SDF_ANIMATION_GLSL
#define SDF_ANIMATION_GLSL

// =====================================================
// File: sdf_animation_v2.glsl
// Description: Modular animation system for SDF objects
// Author: Wanzhang He
// Version: v2.0
// Date: [2025-06-03]
// 
// Features:
// - 5 animation types (Translate, RotateSelf, Orbit, PulseScale, TIEPath)
// - Time modulation support (linear / sin / abs(sin))
// - Unified animation dispatch with Animation struct
// - Designed for integration in modular shader framework
// =====================================================

// ===== SDF structure =====
struct SDF {
    int type;
    vec3 position;
    vec3 size;
    float radius;
};

// ===== Animation parameter structure =====
struct Animation {
    int type;           // 1=Translate, 2=RotateSelf, 3=Orbit, 4=PulseScale, 5=TIEPath
    vec4 moveParam;
    vec4 rotateParam;
};

// ===== Time modulation =====
// mode = 0 → linear
// mode = 1 → sin(t)
// mode = 2 → abs(sin(t))
float applyTimeMode(float t, int mode) {
    if (mode == 1) return sin(t);
    if (mode == 2) return abs(sin(t));
    return t;
}

// ===== Helper: rotate around axis and center =====
vec3 rotateAroundAxis(vec3 pos, vec3 center, vec3 axis, float angle) {
    vec3 p = pos - center;
    float cosA = cos(angle);
    float sinA = sin(angle);
    return center +
        cosA * p +
        sinA * cross(axis, p) +
        (1.0 - cosA) * dot(axis, p) * axis;
}

// ===== Type 1: Sinusoidal translation =====
SDF animateTranslate(SDF sdf, float t, vec4 param, int mode) {
    t = applyTimeMode(t, mode);
    vec3 dir = param.xyz;
    float speed = param.w;
    sdf.position += dir * sin(t * speed);
    return sdf;
}

// ===== Type 2: Rotation around own axis =====
SDF animateRotateSelf(SDF sdf, float t, vec4 axisSpeed, int mode) {
    t = applyTimeMode(t, mode);
    float speed = axisSpeed.w;
    if (speed < 0.0001) return sdf;
    vec3 axis = normalize(axisSpeed.xyz);
    float angle = t * speed;
    // No change to position yet; placeholder for normal rotation
    return sdf;
}

// ===== Type 3: Orbit around a center point =====
SDF animateOrbit(SDF sdf, float t, vec4 centerSpeed, vec4 axisUnused, int mode) {
    t = applyTimeMode(t, mode);
    vec3 center = centerSpeed.xyz;
    float speed = centerSpeed.w;
    vec3 axis = vec3(0.0, 1.0, 0.0); // default orbit axis
    float angle = t * speed;
    sdf.position = rotateAroundAxis(sdf.position, center, axis, angle);
    return sdf;
}

// ===== Type 4: Pulsing scale effect =====
SDF animatePulseScale(SDF sdf, float t, vec4 freqAmp, int mode) {
    t = applyTimeMode(t, mode);
    float freq = freqAmp.x;
    float amp = freqAmp.y;
    float scale = 1.0 + sin(t * freq) * amp;
    sdf.size *= scale;
    sdf.radius *= scale;
    return sdf;
}

// ===== Type 5: Predefined path animation (TIE Fighter) =====
vec3 tiePos(vec3 p, float t) {
    float x = cos(t * 0.7);
    p += vec3(x, cos(t), sin(t * 1.1));
    p.xy *= mat2(cos(-x * 0.1), sin(-x * 0.1), -sin(-x * 0.1), cos(-x * 0.1));
    return p;
}

SDF animateTIEPath(SDF sdf, float t, int mode) {
    t = applyTimeMode(t, mode);
    sdf.position = tiePos(sdf.position, t);
    return sdf;
}

// ===== Dispatcher function: select animation type =====
SDF animateSDF(SDF sdf, float t, Animation anim, int mode) {
    if (anim.type == 1) return animateTranslate(sdf, t, anim.moveParam, mode);
    if (anim.type == 2) return animateRotateSelf(sdf, t, anim.rotateParam, mode);
    if (anim.type == 3) return animateOrbit(sdf, t, anim.moveParam, anim.rotateParam, mode);
    if (anim.type == 4) return animatePulseScale(sdf, t, anim.moveParam, mode);
    if (anim.type == 5) return animateTIEPath(sdf, t, mode);
    return sdf;
}

#endif // SDF_ANIMATION_GLSL
