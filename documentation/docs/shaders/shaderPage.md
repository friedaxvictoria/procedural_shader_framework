# 🧱 Shader Library Overview

Welcome to the **Shader Library**, a central hub for exploring all procedural shaders in this project.

**🔍 Each shader includes:**

- 📜 A brief description and visual preview  
- 🧠 Algorithm or math explanation  
- 💻 Source code with syntax highlighting  
- 🖼️ Results and demo screenshots or videos  
<!-- - 🎛️ Customization parameters  -->


---

## 📂 Shader Categories

### 🔭 General Structure
General structure of the shaders logic

- [General Structure](general_structure.md)

### Signed Distance Field (SDF) System Shader
This documentation covers the Signed Distance Field (SDF) module used in the GLSL shader.

- [SDF System](geometry/SDF_Shader.md)

### Lighting and Material System Shader 
This documentation covers the Phong-based lighting model and material system used in the GLSL.

- [Lighting & Material System](lighting/Lighting_and_Material_System.md)

### Noise System Shader
The noise system in this shader provides procedural pattern generation for textures, terrain, and effects.

- [Noise System](noise/Noise_System.md)

### 🌀 Animation Shaders
Shaders that control movement over time, often using sine/cosine functions or time-based interpolation.

- [TIE Fighter](animation/tie_fighter.md)
- [Camera Orientation Setup Shader](animation/calcLookAtMatrix.md)
- [SDF Animation](animation/sdf_animation_shader.md)


### ☁️ Noise Shaders  
Procedural textures using hash-based value, gradient, and fractal noise.  
Grouped by functional type for clarity:

#### Core Modules  
Unified entry point and hash support.

- [noise.glsl](noise/noise.md) — Main include file, collects all noise types  
- [hash.glsl](noise/hash.md) — Random number and hash utilities

#### Classic Noise  
Basic, smooth procedural noise generators.

- [1D_noise.glsl](noise/1d_noise.md) — 1D interpolated value noise  
- [2D_noise.glsl](noise/2d_noise.md) — 2D grid-based value noise  
- [3D_Perlin_noise.glsl](noise/3d_perlin_noise.md) — Classic 3D gradient noise  
- [simplex_noise.glsl](noise/simplex_noise.md) — Fast, low-artifact simplex noise
  
#### Utility Noise  
Variants and helpers used for animation or visual variation.

- [3D_noise.glsl](noise/3d_noise.md) — Time-varying pseudo 3D gradient noise  
- [grayScale_noise.glsl](noise/grayScale_noise.md) — Grayscale noise helper
  
#### Spatial Noise  
Noise patterns structured around space and proximity.

- [cell_noise.glsl](noise/cell_noise.md) — 2D Voronoi cell structure with jitter

#### Fractal Noise  
Multi-octave patterns for natural surfaces.

- [fbm.glsl](noise/fbm.md) — Fractal Brownian Motion

#### Noise-based Effects  
Visual effects built using the above noise modules.

- [stylized_glow_and_star_shape.glsl](noise/stylized_glow.md) — Stylized star shape and bloom  
- [TIE Fighter_noise.glsl](noise/tie_fighter_noise.md) — Procedural engine trail + noise shading

### 🔷 Geometry Shaders

Shaders that generate or modify geometry procedurally.

- [SDF Raymarching](geometry/raymarching_sdf.md)
- [SDF Sphere](geometry/SDF_Sphere.md)
- [SDF Square](geometry/SDF_Square.md)
- [SDF Rock](geometry/SDF_Rock.md)
- [SDF Cactus](geometry/SDF_Cactus.md)

### 🧱 Material Shaders

Define the visual appearance of surfaces by specifying physical or stylized material properties such as color, roughness, metallicity, and transparency. Used alongside lighting models to produce realistic or artistic effect.

- [Material System](material/material_system.md)
- [Volume Material System](material/volume_material_system.md)

### 💡 Lighting Shaders

Compute surface lighting effects including diffuse, specular, rim, and reflection. Often used in combination with geometry to produce realism or stylized appearances.

- [Rim Reflection Lighting](lighting/Rim_lighting_and_reflection.md)
- [Lighting Functions](lighting/lighting_functions.md)
- [Lighting Context](lighting/lighting_context.md)
- [Volume Lighting Functions](lighting/volume_lighting_functions.md)
- [Volume Lighting Context](lighting/volume_lighting_context.md)

### Rendering Shaders

- [Ray_Marching](rendering/Ray_Marching.md)
- [Sphere Intersection](rendering/Sphere_Intersection_Function.md)
- [Volumetric Ray Marching](rendering/VolumetricRayMarch.md)
- [Heightfield Ray Intersection](rendering/Heightfield_Ray_Intersection.md)
- [Oriented Box Intersection](rendering/Oriented_Box_Intersection.md)
- [Surface Normal Estimation](rendering/Surface_Normal_Estimation.md)
- [Advanced Normal Estimation](rendering/Tetrahedral_adaptive_SDF_normal_estimation.md)

### 🔷 Scenes Shaders

Shaders that render complete background or environmental elements such as sky, sun, clouds, or horizon effects. These shaders are not limited to lighting or material computation but instead define the overall visual atmosphere of a scene.

- [Sun And Halo](scenes/SunAndHalo.md)
- [Volumetric FBM Cloud](scenes/Cloud_fbm.md)
- [Water Surface](scenes/water_surface.md)
- [Boat And Flag](scenes/boat_flag.md)
- [Cloud Volume](scenes/cloud_volume.md)
- [Cloud And Ground](scenes/cloud_ground.md)
- [Cloud And Water](scenes/cloud_water.md)
- [Terrain And Castle](scenes/terrain_castle.md)
- [Dolphin](scenes/dolphin.md)
  
---

**📘 How to Read a Shader Page**

Every shader entry follows the same layout:

- **Overview** — What it is, what it does  
- **Algorithm** — Description of logic and flow  
- **Code** — Full GLSL/HLSL implementation  
- **Results** — Previews, GIFs, or videos  
<!-- - **Parameters** — Inputs you can change  -->

---
