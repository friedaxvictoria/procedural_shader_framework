# 🧩 SDF Animation Shader

- **Category:** Animation / SDF / Scene
- **Author:** Wanzhang He
## 📥 Input Requirements

This shader animation module depends on the following inputs:

### ⏱ Time Input
- `iTime` (`float`) – global shader time (in seconds)
- `timeMode` (`int`) – animation time modulation mode
  - `0`: linear time
  - `1`: `sin(t)`
  - `2`: `abs(sin(t))`

### 🎛 Animation Control Parameters
- `animationType` (`int`) – selects the animation type:
  - 1 = Translate
  - 2 = Orbit
  - 3 = Self Rotate
  - 4 = Pulse Scale
  - 5 = TIE Path
- `translateParam` (`vec4`) – direction (xyz), speed (w)
- `orbitParam` (`vec4`) – center (xyz), angular speed (w)
- `selfRotateParam` (`vec4`) – axis (xyz), angular speed (w)
- `pulseParam` (`vec2`) – frequency, amplitude

### 🧩 SDF Object Parameters
- `_sdfTypeFloat[]` (`float`) – object type (0=Sphere, 1=Box, etc.)
- `_sdfPositionFloat[]` (`vec3`) – object positions
- `_sdfSizeFloat[]` (`vec3`) – size/scale per object
- `_sdfRadiusFloat[]` (`float`) – object radius (for spheres, torus)

> These parameters define the structure and behavior of the animated SDF objects. The animation matrix is applied to these objects dynamically during rendering.

---

## 🧠 Algorithm

This shader implements a modular animation system for SDF-based objects.
It supports several animation types with matrix-based transformations.

### 1. Animation Modes

Supported animation types:
- **Translate**: sinusoidal movement along a direction
- **Orbit**: rotate around a given point
- **Self Rotate**: spin around own axis
- **Pulse Scale**: object expands/contracts periodically
- **TIE Path**: figure-8 path with additional rotation

### 2. Time Modulation

Time is modulated with three modes:
- `t` (linear)
- `sin(t)`
- `abs(sin(t))`

This allows for smooth, oscillatory, or one-direction movement patterns.

### 3. Matrix Composition

Each animation mode returns a `mat4` transformation matrix.
These are composed in `getAnimationMatrix(...)` to produce:
- `animationMatrix`: applied to SDF object
- `inverseAnimationMatrix`: used for raymarching transform

### 4. SDF Integration

Objects are described by arrays like `_sdfTypeFloat`, `_sdfPositionFloat`, etc.
Each object's ray is transformed by the matrix before raymarching, enabling animation.

---

## 💻 Code

### 1. SDF Object Configuration

```glsl
// ===== SDF Variables =====
#define SDF_COUNT 10
float _sdfTypeFloat[SDF_COUNT];
vec3 _sdfPositionFloat[SDF_COUNT];
vec3 _sdfSizeFloat[SDF_COUNT];
float _sdfRadiusFloat[SDF_COUNT];

```

### 2. Animation Parameters

```glsl
// ===== Animation Variables =====
int animationType = 1;
int timeMode = 1;

vec4 translateParam = vec4(1.0, 0.0, 0.0, 2.0);
vec4 orbitParam     = vec4(0.0, 0.0, 0.0, 1.0);
vec4 selfRotateParam = vec4(0.0, 1.0, 0.0, 1.5);
vec2 pulseParam     = vec2(3.0, 0.2);

mat4 animationMatrix = mat4(1.0);
mat4 inverseAnimationMatrix = mat4(1.0);

```

### 3. Animation Parameter Setters

```glsl
// Sets the translation animation parameters.
void setTranslateParam(vec3 direction, float speed) {
// Sets the orbit animation parameters.
void setOrbitParam(vec3 center, float orbitSpeed) {
// Sets the self-rotation animation parameters.
void setSelfRotateParam(vec3 axis, float angularSpeed) {
// Sets the pulse-scale animation parameters.
void setPulseParam(float frequency, float amplitude) {
```

### 4. Time Modulation Function

```glsl
float applyTimeMode(float t, int mode) {
    if (mode == 1) return sin(t);
    if (mode == 2) return abs(sin(t));
    return t;
}

```

### 5. Animation Matrix Functions
#### 5.1 Translate Animation 
```glsl
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
```

#### 5.3 Orbit Animation

```glsl
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
```

#### 5.3 Self-Rotate Animation

```glsl
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
```

#### 5.4 Pulse Scale Animation

```glsl
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
```

#### 5.5 TIE Path Animation

```glsl
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
```

### 6. Animation Dispatcher

```glsl
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
```

### 7. Raymarch Function

```glsl
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
```

### 8. Example mainImage Function

```glsl
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
```

---
