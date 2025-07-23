<div class="container">
    <h1 class="main-heading">SDF Animation v1 Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

- **Category:** Animation
- **Version:** v1 (initial version)
  
This is the **first modular version** of the SDF animation system.  
Each animation type is implemented as a standalone function, operating on a single `SDF` object with per-type parameters.  
No time modulation mode, matrix transformations, or struct flattening are used.

---

## 📥 Input Requirements 

This version uses minimal and direct inputs, mostly hardcoded inside the shader.  
It introduces two simple data structures: `SDF` and `Animation`.

### ⏱ Time Input

| Name     | Type    | Description                        |
|----------|---------|------------------------------------|
| `iTime`  | `float` | Global shader time (in seconds)    |

Time `t` is passed directly to all animation functions (e.g., `sin(t)`, `cos(t)`), without modulation.


### 🧩 SDF Object Struct

```glsl
struct SDF {
    int type;         // Primitive type (0 = sphere, 1 = box, etc.)
    vec3 position;    // World position of the object
    vec3 size;        // Object scale (box half-extents, torus radii, etc.)
    float radius;     // Radius (used for spheres, rounded boxes, etc.)
};
```
Each SDF object represents one shape in the scene and will be animated individually.

### 🎞️ Animation Struct

```glsl
struct Animation {
    int type;       // Animation type ID (1–7)
    vec3 param;     // Animation parameters (meaning depends on type)
};
```
The animation is applied by calling `animateSDF(sdf, iTime, animation)`, where the behavior depends on `animation.type`.

We will detail the **animation type table** and **dispatch behavior** in the next sections.

---
## 🧠 Algorithm

This module provides a clean, per-object animation system using basic GLSL functions.

Each SDF object is animated by evaluating its `Animation` descriptor at time `iTime`, and returning a transformed version of the original SDF.

### 🔁 Per-Object Animation Flow

1. For each frame, call `animateSDF(sdf, iTime, animation)`.
2. The `animation.type` determines which animation function is applied.
3. The `animation.param` vector contains type-specific control parameters (e.g., direction, speed, frequency).
4. The returned `SDF` is positionally or structurally transformed (e.g., moved, rotated, scaled).
5. The transformed SDF is used in raymarching as usual.

### 🔀 Dispatch Logic

All animation behavior is dispatched inside the `animateSDF(...)` function based on the value of `animation.type`.  

| Type | Animation Function           | Description                                                                 | Param Meaning                      |
|------|------------------------------|-----------------------------------------------------------------------------|------------------------------------|
| 1    | `animateSDF_Translate`       | Moves the object back and forth along a direction.                         | `direction * speed`                |
| 2    | `animateSDF_RotateZ`         | Spins the object around its own Z axis (in XY plane).                      | `x = angular speed`                |
| 3    | `animateSDF_RotateAxis`      | Rotates the object around an arbitrary axis through the origin.           | `axis * angular speed`             |
| 4    | `animateSDF_OrbitZ`          | Rotates the object around a 2D center in XY plane.                         | `xy = center, z = angular speed`   |
| 5    | `animateSDF_OrbitAxis`       | Orbits around a hardcoded center using a fixed axis (e.g., Y axis).       | `x = angular speed`                |
| 6    | `animateSDF_Scale`           | Pulses the object’s size up and down (scale animation).                   | `x = frequency, y = amplitude`     |
| 7    | `animateSDF_TIEPath`         | Moves the object along a figure-8 “TIE Fighter” path.                     | *(unused)*                         |

This dispatch table enables structured and extensible animation logic by decoupling motion type from SDF shape or structure.

### 🔂 Batch Animation

To animate multiple SDFs in a scene, the module includes a `animateAllSDFs(...)` function.  

This function takes arrays of `SDF` and `Animation`, and applies the appropriate animation to each object in the batch.

> 💡 This system makes it easy to add, change, or remove animation behaviors for individual objects without affecting the global structure.

---

## 💻 Code

This section contains the full animation module logic.  
Each function operates on an individual `SDF` object using time `t` and type-specific parameters.

### 1. Translate

Moves the object sinusoidally along `param` direction.
param = direction * speed
```glsl
SDF animateSDF_Translate(SDF sdf, float t, vec3 param) {
    sdf.position += param * sin(t);
    return sdf;
}
```

### 2. Rotate around Z (self-spin)

Spins the object in the XY plane.
param.x = angular speed

```glsl
SDF animateSDF_RotateZ(SDF sdf, float t, vec3 param) {
    float angle = t * param.x;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    sdf.position.xy = rot * sdf.position.xy;
    return sdf;
}
```
### 3. Rotate around arbitrary axis

Rotates the object around any 3D axis.
param = axis * angular speed

```glsl
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
```

### 4. Orbit around center in XY

Rotates the object around a center in the XY plane.
param.xy = orbit center, param.z = angular speed

```glsl

SDF animateSDF_OrbitZ(SDF sdf, float t, vec3 param) {
    vec2 center = param.xy;
    float angle = t * param.z;

    vec2 p = sdf.position.xy - center;
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    sdf.position.xy = rot * p + center;
    return sdf;
}
```

### 5. Orbit around fixed axis and center

Object orbits around vec3(0,0,3) with Y-axis rotation.
param.x = angular speed

```glsl

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

```

### 6. Scale with sinusoidal pulse 

Scales the object periodically.
param.x = frequency, param.y = amplitude

```glsl
SDF animateSDF_Scale(SDF sdf, float t, vec3 param) {
    float scale = 1.0 + param.y * sin(t * param.x);
    sdf.size *= scale;
    sdf.radius *= scale;
    return sdf;
}

```

### 7. TIE Fighter predefined path
Moves the object along a dynamic, figure-8-like path.

```glsl
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
```

### 8. Dispatcher & Batch Dispatcher

Central dispatch that selects the appropriate animation based on `animation.type`.

```glsl
// === Dispatcher ===
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
```
