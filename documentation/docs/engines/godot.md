# 🎮 Godot Engine Shader Integrations

Godot is a lightweight, open-source engine great for creative shaders using its own **GodotShader Language** with scripting and includes support.

---

### 🧠 Engine Overview

- **Shader Language:** GodotShader (GLSL-like syntax)  
- **Integration Method:** `.gdshader`, `.gdshaderinc`, GDScript  
- **Ideal For:** Indie games, creative prototyping, open-source projects  
- **Visual Editing:** ❌ (Manual code editing)  
- **Performance:** Great for 2D/3D lightweight FX  

> Godot’s custom shader scripting gives low-level control for creative procedural visuals.

Godot uses **`.gdshader`** files and supports modular include files for SDFs and raymarching techniques.

---

!!! info "🎨 Explore All Shaders in This Engine"

    Want to see all procedural shaders adapted for this engine?

    🧠 Get full access to:
    - Shader logic and breakdowns  
    - Code previews with syntax highlighting  
    - Demos, GIFs, and video walkthroughs

    👉 **[Browse Shader Gallery →](../shaders/shaderPage.md)**



---

## 🔧 Integration List

| Shader Name       | Integration Type     | Link |
|-------------------|----------------------|------|
| 🌀 Raymarching SDF | Shader + Includes    | [View Integration](godot/raymarching_sdf.md) |

---

## 📌 Notes
- Works with ShaderMaterial and GDScript.
- Great for flexible 2D/3D rendering pipelines.
- `.gdshaderinc` lets you reuse logic across multiple shaders.

---

## 🧠 Shader Flow in Godot

- Uses `TIME` or exposed `uniform float t`
- Main `.gdshader` includes helper and SDF logic
- Driven from a simple `GDScript` (e.g., `sdf_updated.gd`)