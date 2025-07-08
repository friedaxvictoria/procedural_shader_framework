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

### 🌀 Animation Shaders
Shaders that control movement over time, often using sine/cosine functions or time-based interpolation.

- [TIE Fighter](animation/tie_fighter.md)

### ☁️ Noise Shaders  
Procedural textures using hash-based value, gradient, and fractal noise.  
Grouped by functional type for clarity:

#### 🧩 Core Modules  
Unified entry point and hash support.

- [noise.glsl](noise/noise.md) — Main include file, collects all noise types  
- [hash.glsl](noise/hash.md) — Random number and hash utilities

#### 🎛️ Classic Noise  
Basic, smooth procedural noise generators.

- [1D_noise.glsl](noise/1d_noise.md) — 1D interpolated value noise  
- [2D_noise.glsl](noise/2d_noise.md) — 2D grid-based value noise  
- [3D_Perlin_noise.glsl](noise/3d_perlin_noise.md) — Classic 3D gradient noise  
- [simplex_noise.glsl](noise/simplex_noise.md) — Fast, low-artifact simplex noise  

#### 🧱 Spatial Noise  
Noise patterns structured around space and proximity.

- [cell_noise.glsl](noise/cell_noise.md) — 2D Voronoi cell structure with jitter

#### 🌫️ Fractal Noise  
Multi-octave patterns for natural surfaces.

- [fbm.glsl](noise/fbm.md) — Fractal Brownian Motion

#### 🔧 Utility Noise  
Variants and helpers used for animation or visual variation.

- [3D_noise.glsl](noise/3d_noise.md) — Time-varying pseudo 3D gradient noise  
- [grayScale_noise.glsl](noise/grayScale_noise.md) — Grayscale noise helper  

#### ✨ Noise-based Effects  
Visual effects built using the above noise modules.

- [Stellar_Corona.glsl](noise/stellar_corona.md) — Radiating solar atmosphere using FBM  
- [stylized_glow_and_star_shape.glsl](noise/stylized_glow.md) — Stylized star shape and bloom  
- [TIE Fighter_noise.glsl](noise/tie_fighter_noise.md) — Procedural engine trail + noise shading

---
### 🔷 Geometry Shaders

Shaders that generate or modify geometry procedurally.

- [SDF Raymarching](geometry/raymarching_sdf.md)

---

**📘 How to Read a Shader Page**

Every shader entry follows the same layout:

- **Overview** — What it is, what it does  
- **Algorithm** — Description of logic and flow  
- **Code** — Full GLSL/HLSL implementation  
- **Results** — Previews, GIFs, or videos  
<!-- - **Parameters** — Inputs you can change  -->

---
