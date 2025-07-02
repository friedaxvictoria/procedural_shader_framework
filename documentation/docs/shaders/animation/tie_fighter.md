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

```

