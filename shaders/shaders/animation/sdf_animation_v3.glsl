// =====================================================
// File: sdf_animation_v3.glsl
// Description: Modular animation system for SDF objects with multiple animation types.
// Author: Wanzhang He
// Version: v3.0
// Date: 2025-06-30
//
// Features:
// - Supports 5 animation types: Translate, Self Rotate, Orbit, Pulse Scale, TIE Path
// - Uses animation matrices for easy combination of transformations
// - Provides default parameters and functions to modify them for flexible control
// - Time modulation modes: linear, sine, absolute sine
// - Designed for easy integration into modular shader frameworks
// =====================================================

// ===== SDF Variables =====
#define SDF_COUNT 10
// Object types: 0 = Sphere, 1 = RoundBox, 2 = Torus, 3 = Dolphin
float _sdfTypeFloat[SDF_COUNT];
vec3 _sdfPositionFloat[SDF_COUNT];
vec3 _sdfSizeFloat[SDF_COUNT];
float _sdfRadiusFloat[SDF_COUNT];

// ===== Animation Variables =====
int animationType = 1;        // 1 = Translate, 2 = Orbit, 3 = SelfRotate, 4 = PulseScale, 5 = TIEPath
int timeMode = 1;             // 0 = linear, 1 = sin(t), 2 = abs(sin(t))

// === Parameter sets for animation
vec4 translateParam = vec4(1.0, 0.0, 0.0, 2.0);     // xyz = direction, w = speed
vec4 orbitParam     = vec4(0.0, 0.0, 0.0, 1.0);     // xyz = orbit center, w = orbit speed
vec4 selfRotateParam = vec4(0.0, 1.0, 0.0, 1.5);    // xyz = axis, w = angular speed
vec2 pulseParam     = vec2(3.0, 0.2);               // x = frequency, y = amplitude

// === Animation transform matrices 
mat4 animationMatrix = mat4(1.0);         // Combined transform matrix for SDF
mat4 inverseAnimationMatrix = mat4(1.0);  // Inverse matrix for raymarching

// ===== SDF objects =====
void initSDFObjects() {
    _sdfTypeFloat[0]     = 0.0;
    _sdfPositionFloat[0] = vec3(0.0, 0.0, 0.0);
    _sdfSizeFloat[0]     = vec3(0.0);
    _sdfRadiusFloat[0]   = 1.0;

    _sdfTypeFloat[1]     = 1.0;
    _sdfPositionFloat[1] = vec3(1.9, 0.0, 0.0);
    _sdfSizeFloat[1]     = vec3(1.0);
    _sdfRadiusFloat[1]   = 0.2;
}


// ===== SDF Animation =====
// ===== Animation Parameters Setting =====
// Default setting
void initAnimationParams() {
    // Set defaults only if you are not overriding via engine/editor
    translateParam     = vec4(1.0, 0.0, 0.0, 1.5);      // Move along X, speed 1.5
    orbitParam         = vec4(0.0, 0.0, 0.0, 1.0);      // Orbit around origin, speed 1.0
    selfRotateParam    = vec4(0.0, 1.0, 0.0, 1.0);      // Y-axis spin, 1 rad/sec
    pulseParam         = vec2(3.0, 0.2);                // Pulse with freq=3, amp=0.2
    animationType      = 0;                             // Default: no animation
    timeMode           = 0;                             // Default: linear
}

// Sets the translation animation parameters.
// direction: Movement direction vector (x, y, z)
// speed: Oscillation speed multiplier
void setTranslateParam(vec3 direction, float speed) {
    translateParam = vec4(direction, speed);
}

// Sets the orbit animation parameters.
// center: Orbit center point (x, y, z)
// orbitSpeed: Angular speed of orbit (in radians per second)
void setOrbitParam(vec3 center, float orbitSpeed) {
    orbitParam = vec4(center, orbitSpeed);
}

// Sets the self-rotation animation parameters.
// axis: Axis of rotation (must be normalized)
// angularSpeed: Speed of rotation around the axis (in radians per second)
void setSelfRotateParam(vec3 axis, float angularSpeed) {
    selfRotateParam = vec4(axis, angularSpeed);
}

// Sets the pulse-scale animation parameters.
// frequency: Frequency of the pulsing scale oscillation
// amplitude: Strength of the scale deformation
void setPulseParam(float frequency, float amplitude) {
    pulseParam = vec2(frequency, amplitude);
}

// ===== Time modulation =====
// Apply time modulation based on mode
// mode = 0 → linear
// mode = 1 → sin(t)
// mode = 2 → abs(sin(t))
float applyTimeMode(float t, int mode) {
    if (mode == 1) return sin(t);
    if (mode == 2) return abs(sin(t));
    return t;
}

// ==== 1. Translate ====
// Moves the object back and forth along a direction with sinusoidal motion.
mat4 getTranslateMatrix(float t, int mode) {
    float modT = applyTimeMode(t, mode);
    vec3 offset = translateParam.xyz * sin(modT * translateParam.w);

    return mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        offset.x, offset.y, offset.z, 1.0
    );
}

// ==== 2. Orbit ====
// Rotates the object around a center point on the Y axis.
mat4 getOrbitMatrix(float t, int mode) {
    float modT = applyTimeMode(t, mode);
    float angle = modT * orbitParam.w;
    float c = cos(angle), s = sin(angle);
    vec3 center = orbitParam.xyz;

    mat4 toOrigin = mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        -center.x, -center.y, -center.z, 1.0
    );

    mat4 rotationY = mat4(
         c, 0.0, -s, 0.0,
        0.0, 1.0, 0.0, 0.0,
         s, 0.0,  c, 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    mat4 back = mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        center.x, center.y, center.z, 1.0
    );

    return back * rotationY * toOrigin;
}

// ==== 3. Self Rotate ====
// Rotates the object around its own center using a custom axis.
mat4 getSelfRotateMatrix(float t, int mode) {
    float modT = applyTimeMode(t, mode);
    float angle = modT * selfRotateParam.w;
    vec3 axis = normalize(selfRotateParam.xyz);
    float c = cos(angle), s = sin(angle);
    float x = axis.x, y = axis.y, z = axis.z;

    return mat4(
        c + (1.0 - c)*x*x,     (1.0 - c)*x*y - s*z, (1.0 - c)*x*z + s*y, 0.0,
        (1.0 - c)*y*x + s*z,   c + (1.0 - c)*y*y,   (1.0 - c)*y*z - s*x, 0.0,
        (1.0 - c)*z*x - s*y,   (1.0 - c)*z*y + s*x, c + (1.0 - c)*z*z,   0.0,
        0.0,                   0.0,                 0.0,                 1.0
    );
}

// ==== 4. Pulse Scale ====
// Scales the object periodically using a sine wave.
mat4 getPulseScaleMatrix(float t, int mode) {
    float modT = applyTimeMode(t, mode);
    float scale = 1.0 + sin(modT * pulseParam.x) * pulseParam.y;

    return mat4(
        scale, 0.0,   0.0,   0.0,
        0.0,   scale, 0.0,   0.0,
        0.0,   0.0,   scale, 0.0,
        0.0,   0.0,   0.0,   1.0
    );
}

// ==== 5. TIE Path ====
// Moves the object along a figure-8 orbit, also spins slightly.
mat4 getTIEPathMatrix(float t, int mode) {
    float modT = applyTimeMode(t, mode);
    float x = cos(modT * 0.7);
    vec3 offset = vec3(x, cos(modT), sin(modT * 1.1));
    float angle = -x * 0.1;
    float c = cos(angle), s = sin(angle);

    mat4 rotation = mat4(
         c, s,   0.0, 0.0,
        -s, c,   0.0, 0.0,
         0.0, 0.0, 1.0, 0.0,
         0.0, 0.0, 0.0, 1.0
    );

    mat4 translate = mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        offset.x, offset.y, offset.z, 1.0
    );

    return translate * rotation;
}

// ===== Dispatcher function: select animation type =====
// Returns the final animation matrix based on the animation type and time modulation.
mat4 getAnimationMatrix(float t, int animationType, int timeMode) {
    if (animationType == 1) {
        return getTranslateMatrix(t, timeMode);   // Translate
    }
    else if (animationType == 2) {
        return getOrbitMatrix(t, timeMode);       // Orbit
    }
    else if (animationType == 3) {
        return getSelfRotateMatrix(t, timeMode);  // SelfRotate
    }
    else if (animationType == 4) {
        return getPulseScaleMatrix(t, timeMode);  // PulseScale
    }
    else if (animationType == 5) {
        return getTIEPathMatrix(t, timeMode);     // TIEPath
    }
    return mat4(1.0); // Identity matrix if no animation
}
// Other Function
float raymarch(vec3 ro, vec3 rd) {
    float t = 0.0;
    const float tMax = 100.0;
    const float epsilon = 0.001;

    for (int i = 0; i < 128; ++i) {
        vec3 p = ro + rd * t;

        // Example SDF: sphere at origin with radius 1
        // Replace with getSDF(p) if you have a general SDF function
        float dist = length(p) - 1.0;

        if (dist < epsilon) {
            return t; // hit found, return distance
        }

        t += dist;
        if (t > tMax) break;
    }
    return -1.0; // no hit
}
// Simple Example 1
/*
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalize pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    // Camera setup
    vec3 ro = vec3(0.0, 0.0, 5.0);
    vec3 rd = normalize(vec3(uv, -1.5));

    // Compute animation matrix and inverse matrix
    animationMatrix = getAnimationMatrix(iTime, animationType, timeMode);
    inverseAnimationMatrix = inverse(animationMatrix);

    // Transform ray into object space
    vec3 transformed_ro = vec3(inverseAnimationMatrix * vec4(ro, 1.0));
    vec3 transformed_rd = normalize(vec3(inverseAnimationMatrix * vec4(rd, 0.0)));

    // Raymarching call
    float t = raymarch(transformed_ro, transformed_rd);

    if (t > 0.0) {
        fragColor = vec4(1.0, 0.5, 0.2, 1.0); // Hit color
    } else {
        fragColor = vec4(0.0); // Background color
    }
}
*/
