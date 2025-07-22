#  🧩 Signed Distance Field (SDF) Shader

<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added -->

<!-- this is for locally stored images -->
<!-- <img src="image directory stored locally inside project" alt="TIE Fighter" width="400" height="225"> -->
<!-- this is for external  link  -->
<!-- <img src="https://......." width="400" alt="TIE Fighter Animation"> -->



<!-- this is for locally stored videos -->
<!-- <video controls width="640" height="360" > -->
  <!-- <source src="video path stored locally" type="video/mp4"> -->
  <!-- Your browser does not support the video tag. -->
<!-- </video> -->

<!-- this is for external link, copy the embed code for given video and paste it here -->
<!-- <iframe width="640" height="360"  -->
  <!-- src="https://www.youtube.com/embed/VIDEO_ID"  -->
  <!-- title="TIE Fighter Shader Demo" -->
  <!-- frameborder="0" allowfullscreen></iframe> -->



- **Category:** SDF
- **Author:** Saeed Shamseldin

---

## Overview

This documentation covers the **Signed Distance Field (SDF)** module used in the GLSL shader.  
SDFs define 3D shapes mathematically, enabling **raymarching-based rendering** without using traditional polygon meshes.

### Key Features

- Defines shapes via distance functions: `sdSphere`, `sdRoundBox`, `sdTorus`
- Supports smooth blending between shapes using `smoothUnion()`
- Enables volumetric effects like **fog** and **clouds**, and supports complex geometry like **fractals**

---

## Scene Composition

### SDF Struct

```glsl
struct SDF {
    int   type;      // Shape type (0=sphere, 1=box, 2=torus, etc)
    vec3  position;  // World position
    vec3  size;      // Dimensions (varies by type)
    float radius;    // Rounding/radius
    vec3  color;     // Base color
};
```

### Scene Evaluation

```glsl
float evaluateScene(vec3 p) {
    float d = 1e5;
    for (int i = 0; i < 10; i++) {
        float di = evalSDF(sdfArray[i], p); // Check each SDF
        if (di < d) d = di; // Track closest hit
    }
    return d;
}
```

### Normal Estimation

Calculates surface normals for lighting using central differences:

```glsl
vec3 SDFsNormal(vec3 p) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    return normalize(
        k.xyy * evaluateScene(p + k.xyy * h) + // X-axis
        k.yyx * evaluateScene(p + k.yyx * h) + // Y-axis
        k.yxy * evaluateScene(p + k.yxy * h) + // Z-axis
        k.xxx * evaluateScene(p + k.xxx * h)
    );
}
```
### Raymarching Integration
Basic Raymarching Loop

```glsl
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float d = evaluateScene(p); // Query SDF
        if (d < 0.001) { 
            hitPos = p; 
            return t; // Hit!
        }
        t += d; // March forward
        if (t > 50.0) break; // Max distance
    }
    return -1.0; // Miss
}
```
Optimizations

**Early Termination** – Exit the loop as soon as a surface is hit

**Distance Clamping** – Break the loop if t > maxDist to avoid unnecessary

## Engine Integrations

<div class="button-row">
  <a class="custom-button md-button" href="../../../../engines/unity/sdfs/raymarching">Unity</a>
</div>