#  🧩 General Structure Shader

<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added -->

<!-- this is for locally stored images -->
<!-- <img src="image directory stored locally inside project" alt="TIE Fighter" width="400" height="225"> -->
<!-- this is for external  link  -->
<!-- <img src="https://......." width="400" alt="TIE Fighter Animation"> -->



<!-- this is for locally stored videos -->
<!-- <video controls width="640" height="360" >
  <source src="video path stored locally" type="video/mp4">
  Your browser does not support the video tag.
</video> -->

<!-- this is for external link, copy the embed code for given video and paste it here -->
<!-- <iframe width="640" height="360" 
  src="https://www.youtube.com/embed/VIDEO_ID" 
  title="TIE Fighter Shader Demo"
  frameborder="0" allowfullscreen></iframe> -->


## Overview

This GLSL shader follows a **modular**, **data-driven** architecture designed for **real-time 3D rendering** using **Signed Distance Fields (SDFs)** and **raymarching**.

### Key Components

- **Scene Representation** – Uses SDFs to define geometry.
- **Raymarching Loop** – Efficiently traces rays through the scene.
- **Material System** – Handles lighting and shading.
- **Animation System** – Procedural motion for dynamic objects.
- **Noise & Utility Functions** – For procedural effects and surface detail.

---

## 1. Signed Distance Fields (SDFs)

- The shader represents objects using **mathematical distance functions**, which define how far a point is from a surface.
- Primitives such as **Sphere**, **Box**, and **Torus** are defined via SDFs.
- `evalSDF()` – Evaluates a single SDF function.
- `evaluateScene()` – Checks all SDFs and tracks the closest hit.

---

## 2. Raymarching

This shader uses **raymarching** to render 3D scenes efficiently.

### How It Works

- **Ray Origin** (`ro`) and **Direction** (`rd`) are set up based on the camera.
- A **marching loop** steps along the ray, checking `evaluateScene()` at each step.
- **Early exit** occurs if a surface is hit (distance < threshold) or max steps are reached.

### Key Functions

```glsl
vec3 raymarch(vec3 ro, vec3 rd, out vec3 hitPos); // Main raymarching loop
```

## 3. Material & Lighting System

The shader supports dynamic materials with **Phong lighting** for realistic shading.

### Components

- **Base Color** – Defined per SDF (e.g., `SDF.color`)
- **Lighting Model** – Uses `applyPhongLighting()` for diffuse and specular shading
- **Material Properties** – Adjustable via `MakePlasticMaterial()`

### Lighting Workflow

#### 1. Get the surface normal using:
   - `SDFsNormal()` for basic shapes
   - Custom normal functions for complex surfaces
#### 2. Compute lighting using:
   - **Diffuse** – Lambertian reflection
   - **Specular** – Phong or Blinn-Phong highlights
   - **Ambient** – A fixed base illuminatio

   ---


## 4. Animation System

  ---

## 5. Noise & Procedural Generation

The shader includes several noise functions used for procedural effects and surface detailing.

### Available Noise Types

- **Gradient Noise** (`Pseudo3dNoise`) – Smooth, Perlin-like noise
- **Fractal Brownian Motion** (`fbmPseudo3D`) – Adds layered detail via multiple octaves
- **Alternative 3D Noise** (`n31`) – A different style of 3D noise with unique characteristics

---

## 6. Rendering Pipeline Summary

### Setup

- Define SDFs, lights, and camera parameters

### Raymarching

- Trace rays through the scene using the `raymarch()` function

### Shading

- Compute surface normals and apply lighting via `applyPhongLighting()`

### Key Advantages

- ✔ **Flexible** – Easily add new SDF shapes
- ✔ **Performant** – Raymarching is efficient for complex scenes
- ✔ **Procedural** – No need for pre-made textures or models


