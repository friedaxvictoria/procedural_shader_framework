#ifndef SDF_ANIMATION_GLSL
#define SDF_ANIMATION_GLSL

// ====================
// SDF Animation Module
// Provides time-driven object-level transformations for SDFs.
// Supports translation, scaling, local/global rotation, and custom path animations.
// From Wanzhang He
// ====================

// === SDF & Animation Structs ===
struct SDF {
    int type;
    vec3 position;
    vec3 size;
    float radius;
};

struct Animation {
    int type;       // Animation type ID
    vec3 param;     // Control parameters (type-dependent)
};

// === Animation Type Table ===
// type = 1 → Translate
//     param = direction * speed
//
// type = 2 → Rotate around Z (self-spin)
//     param.x = angular speed
//
// type = 3 → Rotate around arbitrary axis (self-spin)
//     param = axis * angular speed
//
// type = 4 → Orbit around point in XY plane (Z rotation)
//     param.xy = orbit center, param.z = angular speed
//
// type = 5 → Orbit around point + arbitrary axis
//     param.x = angular speed (center & axis hardcoded)
//
// type = 6 → Pulsing scale
//     param.x = frequency, param.y = amplitude
//
// type = 7 → Predefined path (TIE Fighter)
//     param = unused

// === 1. Translate ===
SDF animateSDF_Translate(SDF sdf, float t, vec3 param) {
    sdf.position += param * sin(t);
    return sdf;
}

// === 2. Rotate around Z (self-spin) ===
SDF animateSDF_RotateZ(SDF sdf, float t, vec3 param) {
    float angle = t * param.x;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    sdf.position.xy = rot * sdf.position.xy;
    return sdf;
}

// === 3. Rotate around arbitrary axis (self-spin) ===
SDF animateSDF_RotateAxis(SDF sdf, float t, vec3 param) {
    vec3 axis = normalize(param);
    float speed = length(param);
    float angle = t * speed;

    float c = cos(angle), s = sin(angle), ic = 1.0 - c;
    mat3 R = mat3(
        c + axis.x*axis.x*ic, axis.x*axis.y*ic - axis.z*s, axis.x*axis.z*ic + axis.y*s,
        axis.y*axis.x*ic + axis.z*s, c + axis.y*axis.y*ic, axis.y*axis.z*ic - axis.x*s,
        axis.z*axis.x*ic - axis.y*s, axis.z*axis.y*ic + axis.x*s, c + axis.z*axis.z*ic
    );

    sdf.position = R * sdf.position;
    return sdf;
}

// === 4. Orbit around center in XY ===
SDF animateSDF_OrbitZ(SDF sdf, float t, vec3 param) {
    vec2 center = param.xy;
    float angle = t * param.z;

    vec2 p = sdf.position.xy - center;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    sdf.position.xy = rot * p + center;
    return sdf;
}

// === 5. Orbit around arbitrary axis and point (hardcoded center) ===
SDF animateSDF_OrbitAxis(SDF sdf, float t, vec3 param) {
    vec3 center = vec3(0.0, 0.0, 3.0);
    vec3 axis = normalize(vec3(0.0, 1.0, 0.0));
    float angle = t * param.x;

    vec3 p = sdf.position - center;

    float c = cos(angle), s = sin(angle), ic = 1.0 - c;
    mat3 R = mat3(
        c + axis.x*axis.x*ic, axis.x*axis.y*ic - axis.z*s, axis.x*axis.z*ic + axis.y*s,
        axis.y*axis.x*ic + axis.z*s, c + axis.y*axis.y*ic, axis.y*axis.z*ic - axis.x*s,
        axis.z*axis.x*ic - axis.y*s, axis.z*axis.y*ic + axis.x*s, c + axis.z*axis.z*ic
    );

    sdf.position = R * p + center;
    return sdf;
}

// === 6. Scale with sinusoidal pulse ===
SDF animateSDF_Scale(SDF sdf, float t, vec3 param) {
    float scale = 1.0 + param.y * sin(t * param.x);
    sdf.size *= scale;
    sdf.radius *= scale;
    return sdf;
}

// === 7. TIE Fighter predefined path ===
vec3 tiePos(vec3 p, float t) {
    float x = cos(t * 0.7);
    p += vec3(x, cos(t), sin(t * 1.1));
    p.xy *= mat2(cos(-x * 0.1), sin(-x * 0.1),
                -sin(-x * 0.1), cos(-x * 0.1));
    return p;
}
SDF animateSDF_TIEPath(SDF sdf, float t, vec3 param) {
    sdf.position = tiePos(sdf.position, t);
    return sdf;
}

// === Main Dispatch ===
SDF animateSDF(SDF sdf, float t, Animation anim) {
    if (anim.type == 1) return animateSDF_Translate(sdf, t, anim.param);
    if (anim.type == 2) return animateSDF_RotateZ(sdf, t, anim.param);
    if (anim.type == 3) return animateSDF_RotateAxis(sdf, t, anim.param);
    if (anim.type == 4) return animateSDF_OrbitZ(sdf, t, anim.param);
    if (anim.type == 5) return animateSDF_OrbitAxis(sdf, t, anim.param);
    if (anim.type == 6) return animateSDF_Scale(sdf, t, anim.param);
    if (anim.type == 7) return animateSDF_TIEPath(sdf, t, anim.param);
    return sdf;
}

// === Batch Dispatcher ===
void animateAllSDFs(inout SDF sdfArray[10], Animation animArray[10], float t) {
    for (int i = 0; i < 10; ++i) {
        sdfArray[i] = animateSDF(sdfArray[i], t, animArray[i]);
    }
}

#endif
