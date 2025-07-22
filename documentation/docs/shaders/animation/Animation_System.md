<div class="container">
    <h1 class="main-heading">Animation Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/animation_SDFs.gif" alt="general scene" width="500" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

---

## Overview

The shader supports two types of animation: **camera animation** and **SDF object animation**.

### Camera Animation

- Based on a modular system using `CameraState` and `CameraAnimParams` structs.
- Provides four animation modes:
  - **Static** – fixed viewpoint
  - **Orbit** – camera revolves around a scene center
  - **Ping-pong** – camera moves back and forth
  - **First-person** – camera moves forward continuously
- The system outputs a camera matrix used for ray direction setup in raymarching shaders.
- View matrix is constructed in column-major order using eye, target, and up vectors.

### SDF Object Animation

- Uses a matrix-based animation system that transforms each SDF object individually.
- Supports five animation types:
  - **Translate** – sinusoidal motion along a direction
  - **Orbit** – circular movement around a center
  - **Self Rotate** – object spins around its own axis
  - **Pulse Scale** – scales up and down periodically
  - **TIE Path** – complex figure-8 motion with rotation
- Each animation is driven by global time (`iTime`) and mode-dependent parameters.
- The animation matrix is applied before raymarching, and its inverse is used to transform rays into object-local space.
- Time modulation allows smooth or oscillating patterns using linear, `sin(t)`, or `abs(sin(t))` curves.


To see the different animation functions, refer to [Animation Shaders](../shaderPage.md#-animation-shaders)