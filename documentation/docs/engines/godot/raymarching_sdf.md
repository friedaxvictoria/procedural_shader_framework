# 🎮 Raymarching SDF Shader – Godot Integration

- **Engine:** Godot (v4.x+)
- **Shader Source:** [View Shader](../../shaders/geometry/raymarching_sdf.md)
- **Integration Type:** CanvasItem Shader with `.gdshaderinc` Includes
- **Integrated By:** Team Godot

---

## ⚙️ Setup Overview

This shader implements real-time raymarching using Godot's shader language and modular include files. It renders procedural shapes (like spheres and boxes) using Signed Distance Functions (SDFs), lighting, and blending — all in a full-screen quad.

### 🧩 Files Required

Make sure the following files are in your project:

- `sdf_updated.gdshader` – Main shader
- `sdf_updated.gdshaderinc` – SDF + material logic
- `helper_func.gdshaderinc` – Utility math functions (camera rotation, lighting context estimation, etc.)
- `sdf_updated.gd` – Script to animate the shader( recommended, for passing global variables)

These files are referenced using `@import` inside the `.gdshader`.

---

## 🛠️ Integration Steps

1. Add a **Node2D** (or Node3D) to your scene as the root.
2. Inside it, add a **ColorRect** node or MeshInstance3D (for fullscreen shader display).
3. Create a **ShaderMaterial** and assign `sdf_updated.gdshader` to it.
4. Ensure `sdf_updated.gdshaderinc` and `helper_func.gdshaderinc` are in the directory, so they will be imported by the main shader file.
5. Attach `sdf_updated.gd` script to the root node to drive the unifrom variables in operation.
---

## 🎥 Preview

> 👇 Here's how it looks in real-time using Godot engine:

<video controls width="640" height="360">
  <source src="../../../static/videos/sdf_raymarch.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

## 💡 Notes


---

🧪 Tested in **Godot 4.2.1**  
📦 Compatible with **2D scenes**, useful for visual effects or stylized fullscreen shaders.
