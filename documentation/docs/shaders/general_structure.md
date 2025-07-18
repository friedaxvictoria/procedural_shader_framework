#  🧩 General Structure Shader

<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added -->

<!-- this is for locally stored images -->
<img src="image directory stored locally inside project" alt="TIE Fighter" width="400" height="225">
<!-- this is for external  link  -->
<img src="https://......." width="400" alt="TIE Fighter Animation">



<!-- this is for locally stored videos -->
<video controls width="640" height="360" >
  <source src="video path stored locally" type="video/mp4">
  Your browser does not support the video tag.
</video>

<!-- this is for external link, copy the embed code for given video and paste it here -->
<iframe width="640" height="360" 
  src="https://www.youtube.com/embed/VIDEO_ID" 
  title="TIE Fighter Shader Demo"
  frameborder="0" allowfullscreen></iframe>


## Overview

1. Core Architecture

This GLSL shader follows a modular, data-driven architecture designed for real-time 3D rendering using Signed Distance Fields (SDFs) and raymarching. The key components are:

- Scene Representation – Uses SDFs to define geometry.
- Raymarching Loop – Efficiently traces rays through the scene.
- Material System – Handles lighting and shading.
- Animation System – Procedural motion for dynamic objects.
- Noise & Utility Functions – For procedural effects.

2. Signed Distance Fields (SDFs)

- The shader represents objects using mathematical distance functions, which define how far a point is from a surface.
- Primitives (Sphere, Box, Torus, etc.) are defined via SD functions.
- evalSDF() evaluates a single SDF.
- evaluateScene() checks all SDFs and tracks the closest hit.

3. Raymarching

This shader uses raymarching to render 3D scenes efficiently.

How It Works:
- Ray Origin (ro) & Direction (rd) are set up from camera.
- Marching Loop steps along the ray, checking evaluateScene() at each point.
- Early Exit if a surface is hit (distance < threshold) or max steps are reached.

Key Functions:
- raymarch(ro, rd, out hitPos) – Main loop.
- SDFsNormal(p) – Estimates surface normals using finite differences (for lighting).

4. Material & Lighting System

The shader supports dynamic materials with Phong lighting for realistic shading.

Components:
- Base Color – Defined per SDF (SDF.color).
- Lighting Model – Uses applyPhongLighting() for diffuse + specular.
- Material Properties – Adjustable via MakePlasticMaterial().

Lighting Workflow:
- Get surface normal (SDFsNormal() or custom normals for complex shapes).
- Compute lighting using:
- Diffuse (Lambertian)
- Specular (Phong/Blinn-Phong)
- Ambient (fixed base light)

5. Animation System

6. Noise & Procedural Generation

The shader includes some noise functions.

Available Noise Types:
- Gradient Noise (Pseudo3dNoise) – Smooth, Perlin-like noise.
- Fractal Brownian Motion (fbmPseudo3D) – Adds detail via octaves.
- Alternative 3D Noise (n31) – Different noise flavor.




---

## 🧠 Algorithm

### 🔷 Core Concept

To adapt this shader for different use cases:
- Add New SDFs – Implement new SD functions.
- Modify Materials – Adjust MakePlasticMaterial().
- Change Lighting – Tweak applyPhongLighting().
- Animate Objects – Update positions in mainImage().

---
## 🎛️ Parameters

| Name | Description | Range | Default |
|------|-------------|-------|---------|
| `T`  | Looping time | 0–40  | —       |
| ...  | ...          | ...   | ...     |

---

## 💻 Shader Code & Includes
<!--
if you want to put small code snippet
-->
```glsl
    struct SDF {
    int   type;       // Shape type (0=sphere, 1=box, etc.)
    vec3  position;   // World position
    vec3  size;      // Dimensions (varies by type)
    float radius;     // Rounding/radius
    vec3  color;      // Base color
};

float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;     // Current point in the ray
        float noise;
        fbmPseudo3D(p, 1, noise);    // here you can replace fbmPseudo3D with fbm_n31 for different noise
        float d = evaluateScene(p) + noise*0.3*0.0; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }
    return -1.0; // No hit
}

// Evaluate the scene by checking all SDF shapes
float evaluateScene(vec3 p) {
    float d = 1e5;
    int bestID = -1;
    for (int i = 0; i < 10; ++i) {
        float di = evalSDF(sdfArray[i], p);
        if(di < d)
        {
            d = di; // Update the closest distance
            bestID = i; // Update the closest hit ID
        }
    }
    
           // Check all dolphins
    for (int i = 0; i < DOLPHIN_COUNT; ++i) {
        float di = dolphinDistance(p, dolphins[i], time).x;
        if(di < d) {
            d = di;
            bestID = 10 + i; // Use IDs >= 10 for dolphins
        }
    }
    
    gHitID = bestID;  // Store the ID of the closest hit shape
    return d;
}

  ```

<!--
if you want to put small code snippet and make it appereable and dissapear
-->
??? note "📄 sdf_updated.gdshader"
    ```glsl
        shader_type canvas_item;

        #include "res://addons/includes/sdf_updated.gdshaderinc"
        void fragment() {
            vec4 color;
        vec3 lightPosition = camera_position;
        IntegrationFlexible(UV, color, lightPosition);
            COLOR = color;

        }
    ```
<!--
if we want to link the github repo
-->
🔗 [View Full Shader Code on GitHub](https://github.com/your-org/your-repo/blob/main/path/to/tie_fighter.glsl)

---
