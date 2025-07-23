# 🧱 Shader Library Overview

Welcome to the **Shader Library** — a central hub for exploring all procedural shaders used in this project.

Each shader includes:

- 📜 A brief description and visual preview  
- 🧠 Algorithm or math explanation  
- 💻 Source code with syntax highlighting  
- 🖼️ Screenshots or demo videos  
<!-- - 🎛️ Customizable parameters -->

---

## 📚 Shader Categories

### 🧩 General Structure
Foundational logic and architecture of the shader system.

- [General Structure](general_structure.md)

### ✳️ Core Shader Systems

#### 🔷 Signed Distance Field (SDF)
Distance-based geometry representation used in raymarching.

- [SDF System](geometry/SDF_Shader.md)

#### 💡 Lighting & Material System
Phong-based lighting and material representation in GLSL.

- [Lighting & Material](lighting/Lighting_and_Material_System.md)

#### 🕹️ Animation System
How shaders handle time-based movement and transformation.

- [Animation System](animation/Animation_System.md)

#### 🌐 Noise System
Procedural noise generation for textures, terrain, and effects.

- [Noise System](noise/Noise_System.md)

---

### 🎞️ Animation Shaders
Time-based visual motion using trigonometry, noise, or interpolation.

- [TIE Fighter](animation/tie_fighter.md)
- [Camera Orientation](animation/calcLookAtMatrix.md)
- [SDF Animation](animation/sdf_animation_shader.md)
- [Camera Animation](animation/Camera_Anim.md)

---

### ☁️ Noise Shaders
Modular procedural noise grouped by type and use-case.

#### 📦 Core Modules
- [noise.glsl](noise/noise.md) — Aggregates all noise types  
- [hash.glsl](noise/hash.md) — Hashing and pseudo-random tools  

#### 🌊 Classic Noise
- [1D Noise](noise/1d_noise.md)  
- [2D Noise](noise/2d_noise.md)  
- [3D Perlin Noise](noise/3d_perlin_noise.md)  
- [Simplex Noise](noise/simplex_noise.md)  

#### ⚙️ Utility Noise
- [3D Noise (time varying)](noise/3d_noise.md)  
- [Grayscale Helper](noise/grayScale_noise.md)  

#### 🧭 Spatial Noise
- [Cell Noise](noise/cell_noise.md) — Voronoi-style patterning  

#### 🌱 Fractal Noise
- [FBM](noise/fbm.md) — Fractal Brownian Motion  

#### 🔥 Effects Using Noise
- [Stylized Glow & Star](noise/stylized_glow.md)  
- [TIE Fighter Trail](noise/tie_fighter_noise.md)  

---

### 🧱 Geometry Shaders
Procedural geometry generation and raymarching techniques.

- [Geometry SDFs](geometry/Geometry_SDFs.md)
- [SDF Raymarching](geometry/raymarching_sdf.md)
- [SDF Sphere](geometry/SDF_Sphere.md)
- [SDF Square](geometry/SDF_Square.md)
- [SDF Rock](geometry/SDF_Rock.md)
- [SDF Cactus](geometry/SDF_Cactus.md)

---

### 🎨 Material Shaders
Visual properties for stylized or physical material rendering.

- [Material System](material/material_system.md)
- [Volume Materials](material/volume_material_system.md)

---

### 💡 Lighting Shaders
Surface illumination techniques including specular, rim, and volume lighting.

- [Rim & Reflection](lighting/Rim_lighting_and_reflection.md)
- [Lighting Functions](lighting/lighting_functions.md)
- [Lighting Context](lighting/lighting_context.md)
- [Volume Lighting Functions](lighting/volume_lighting_functions.md)
- [Volume Lighting Context](lighting/volume_lighting_context.md)
- [Sunrise](lighting/Sunrise.md)

---

### 🖥️ Rendering Shaders
Ray-based rendering algorithms and intersection methods.

- [Ray Marching](rendering/Ray_Marching.md)
- [Sphere Intersection](rendering/Sphere_Intersection_Function.md)
- [Volumetric Ray Marching](rendering/VolumetricRayMarch.md)
- [Heightfield Intersection](rendering/Heightfield_Ray_Intersection.md)
- [Oriented Box Intersection](rendering/Oriented_Box_Intersection.md)
- [Surface Normal Estimation](rendering/Surface_Normal_Estimation.md)
- [Advanced Normal Estimation](rendering/Tetrahedral_adaptive_SDF_normal_estimation.md)

---

### 🌄 Scene Shaders
Complete visuals for environments, sky, terrain, or effects.

- [Sun & Halo](scenes/SunAndHalo.md)
- [Volumetric FBM Cloud](scenes/Cloud_fbm.md)
- [Water Surface](scenes/water_surface.md)
- [Boat & Flag](scenes/boat_flag.md)
- [Cloud Volume](scenes/cloud_volume.md)
- [Cloud & Ground](scenes/cloud_ground.md)
- [Cloud & Water](scenes/cloud_water.md)
- [Terrain & Castle](scenes/terrain_castle.md)
- [Dolphin](scenes/dolphin.md)
- [Desert](scenes/desert.md)
- [Snowy Mountain](scenes/Snowy_Mountain.md)
- [TIE_Fighter](scenes/tie_fighter.md)

---

## 📘 Reading a Shader Page

Every shader page follows a consistent format:

- **Overview** — Summary and purpose  
- **Algorithm** — Core logic and math involved  
- **Code** — Full source with highlights  
- **Results** — Screenshots or visual demos  
<!-- - **Parameters** — Optional customization inputs -->

---
