<div class="container">
    <h1 class="main-heading">SDF Animation v2 Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

- **Category:** Animation
- **Version:** v2 (initial version)

This is the **second modular version** of the SDF animation system.  
Compared to v1, it introduces a **unified `Animation` struct with two vec4 fields**, **time modulation modes**, and **cleaner orbit/rotation helpers**.  
All animation types are defined as functions operating on a single `SDF` object.

---

## 📥 Input Requirements

The v2 system uses two GLSL structs: `SDF` and `Animation`, and an extra integer input `mode` for time modulation.

### Parameters Overview

| Name           | Description                     | Type    | Notes                              |
|----------------|---------------------------------|---------|------------------------------------|
| `iTime`        | Global shader time              | `float` | Passed to all animation functions  |
| `mode`         | Time modulation mode            | `int`   | 0 = linear, 1 = sin, 2 = abs(sin)  |
| `SDF`          | Geometric object struct         | `struct`| Contains `position`, `size`, etc.  |
| `Animation`    | Animation type + parameters     | `struct`| Includes `type`, `moveParam`, etc. |

### ⏱ Time Input

| Name     | Type    | Description                                 |
|----------|---------|---------------------------------------------|
| `iTime`  | `float` | Global shader time (in seconds)             |
| `mode`   | `int`   | Time modulation mode (0 = linear, 1 = sin, 2 = abs(sin)) |

The time `t` is modulated based on the mode selected before being passed into animation functions.

### 🧩 SDF Struct

```glsl
struct SDF {
    int type;
    vec3 position;
    vec3 size;
    float radius;
};
```

Each object represents a geometric primitive in the scene.


### 🎞️ Animation Struct

```glsl
struct Animation {
    int type;             // 1–5, see table below
    vec4 moveParam;       // Used for translation/orbit/pulse
    vec4 rotateParam;     // Used for rotation/orbit
};
```

The `type` field dispatches to the correct animation behavior.  
Parameters are split into movement and rotation components.

### ⏳ Time Modulation Modes

The animation time input can be modulated via:

| Mode | Formula         | Description                 |
|------|------------------|-----------------------------|
| 0    | `t`              | Linear, unmodified          |
| 1    | `sin(t)`         | Sinusoidal motion           |
| 2    | `abs(sin(t))`    | Pulsed motion (non-negative)|

```glsl
float applyTimeMode(float t, int mode);
```

---

## 🧠 Algorithm

This shader implements a modular animation system for SDF-based objects. Each object is animated independently using a descriptor struct (`Animation`) and a time modulation mode.

| Stage           | Function                | Purpose                                      |
|-----------------|-------------------------|----------------------------------------------|
| Dispatcher      | `animateSDF(...)`       | Dispatches animation by type                 |
| Motion Types    | `animateTranslate()` etc.| Translate, Rotate, Orbit, Pulse, TIE motion |
| Time Modulation | `applyTimeMode(...)`    | Allows sin/abs(sin)/linear time usage        |

### Animation Types

| Type | Function               | Description                          |
|------|------------------------|--------------------------------------|
| 1    | `animateTranslate`     | Sinusoidal translation in a direction |
| 2    | `animateRotateSelf`    | Rotation around the object's own axis |
| 3    | `animateOrbit`         | Orbits around a center along fixed Y axis |
| 4    | `animatePulseScale`    | Pulsing scale animation              |
| 5    | `animateTIEPath`       | Moves along figure-8 "TIE" path       |

---

## 💻 Shader Code 

###  0. Rotation Helper

Used by orbit logic to rotate around arbitrary axis and center.

```glsl
vec3 rotateAroundAxis(vec3 pos, vec3 center, vec3 axis, float angle) {
    vec3 p = pos - center;
    float cosA = cos(angle);
    float sinA = sin(angle);
    return center +
        cosA * p +
        sinA * cross(axis, p) +
        (1.0 - cosA) * dot(axis, p) * axis;
}
```

### 1. Translate

Applies sinusoidal translation along a specified direction.  
- `param.xyz`: direction  
- `param.w`: speed  
- `mode`: time modulation (0 = linear, 1 = sin, 2 = abs(sin))
  
```glsl
SDF animateTranslate(SDF sdf, float t, vec4 param, int mode) {
    t = applyTimeMode(t, mode);
    vec3 dir = param.xyz;
    float speed = param.w;
    sdf.position += dir * sin(t * speed);
    return sdf;
}
```

### 2. Rotation around own axis

Placeholder function to rotate the object around a self-defined axis.  
Currently does not modify `sdf.position`, but can be extended to rotate orientation or normal data.  
- `axisSpeed.xyz`: rotation axis  
- `axisSpeed.w`: angular speed
  
```glsl
SDF animateRotateSelf(SDF sdf, float t, vec4 axisSpeed, int mode) {
    t = applyTimeMode(t, mode);
    float speed = axisSpeed.w;
    if (speed < 0.0001) return sdf;
    vec3 axis = normalize(axisSpeed.xyz);
    float angle = t * speed;
    // No change to position yet; placeholder for normal rotation
    return sdf;
}
```

### 3. Orbit around a center point

Moves the object in a circular orbit around a center point using a fixed Y-axis.  
- `centerSpeed.xyz`: center position  
- `centerSpeed.w`: angular speed  
- `axis`: fixed to `vec3(0,1,0)`

```glsl
SDF animateOrbit(SDF sdf, float t, vec4 centerSpeed, vec4 axisUnused, int mode) {
    t = applyTimeMode(t, mode);
    vec3 center = centerSpeed.xyz;
    float speed = centerSpeed.w;
    vec3 axis = vec3(0.0, 1.0, 0.0); // default orbit axis
    float angle = t * speed;
    sdf.position = rotateAroundAxis(sdf.position, center, axis, angle);
    return sdf;
}
```

### 4. Pulsing scale effect

Applies a pulsing scale animation to the object's size using sine wave modulation.  
- `freqAmp.x`: frequency  
- `freqAmp.y`: amplitude  
Affects both `sdf.size` and `sdf.radius`.

```glsl
SDF animatePulseScale(SDF sdf, float t, vec4 freqAmp, int mode) {
    t = applyTimeMode(t, mode);
    float freq = freqAmp.x;
    float amp = freqAmp.y;
    float scale = 1.0 + sin(t * freq) * amp;
    sdf.size *= scale;
    sdf.radius *= scale;
    return sdf;
}
```

### 5. Predefined path animation (TIE Fighter)

Moves the object along a predefined looping "TIE Fighter" path.  
Combines cosine and sine oscillations with local rotation to create a figure-8 motion.

```glsl
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
```

###  6. Dispatcher

Central animation dispatcher that routes `SDF` to its animation handler.  
- `anim.type`: determines animation type  
- `anim.moveParam`: used for motion  
- `anim.rotateParam`: used for rotation or center  
- `mode`: selects time modulation method
  
```glsl
SDF animateSDF(SDF sdf, float t, Animation anim, int mode) {
    if (anim.type == 1) return animateTranslate(sdf, t, anim.moveParam, mode);
    if (anim.type == 2) return animateRotateSelf(sdf, t, anim.rotateParam, mode);
    if (anim.type == 3) return animateOrbit(sdf, t, anim.moveParam, anim.rotateParam, mode);
    if (anim.type == 4) return animatePulseScale(sdf, t, anim.moveParam, mode);
    if (anim.type == 5) return animateTIEPath(sdf, t, mode);
    return sdf;
}
```

---


