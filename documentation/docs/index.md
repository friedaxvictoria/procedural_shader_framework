---
hide:
  - navigation
---

# 🎨 Procedural Shader Development Documentation

Welcome to the **Shader Snippets Documentation Site** — a collaborative knowledge base for procedural shaders used in multiple engines including **Unreal**, **Unity**, and **Godot**.

---

## 🧠 What Are Shaders?

**Shaders** are small programs that run on the GPU to control how objects are drawn on the screen — controlling color, shape, lighting, animation, and more. Procedural shaders use **mathematical functions** to generate visuals dynamically without relying on textures or models.

!!! info "🎨 Explore All Shaders Implemented"

    Want to see all procedural shaders adapted for this framework?

    🧠 Get full access to:

      - Shader logic and breakdowns  
      - Code previews with syntax highlighting  
      - Demos, GIFs, and video walkthroughs

    👉 **[Browse Shader Gallery →](shaders/shaderPage.md)**

---

## 🕹️ What Are Game Engines?

Game engines like **Unity**, **Unreal Engine**, and **Godot** provide tools and runtimes for rendering 2D/3D scenes. Each engine supports its own shader system:

- **Unreal:** Uses Material Editor with optional HLSL for advanced effects
- **Unity:** Supports Shader Graph and HLSL via ShaderLab
- **Godot:** Uses a GLSL-inspired shading language and integrates with GDScript for control

---

## 🔄 How Are Shaders Rendered in Engines?

Engines convert your shader logic into **renderable materials** that can be applied to objects in the scene. Each engine may use:

- **Visual Node Graphs** (like Shader Graph in Unity or Material Editor in Unreal)
- **Code-based shaders** (HLSL, GLSL, or Godot Shading Language)
- **Runtime scripting** to animate or parameterize shader behavior

This documentation bridges this gap, taking reusable shader logic and adapting it to each platform’s workflow. This documentation helps shader developers and engine integrators:

- Understand how each shader works (algorithm, parameters, results).
- Learn how to use these shaders in different game engines.
- Explore visual demos and integration walkthroughs.

**🧩 Engine Integration**  
Learn how to use shaders across different engines:


| Engine             | Features             | Integration Guide                 |
|------             |--------               |-----------------                  | 
| **🚀 Godot** | GDScript Control • ShaderMaterial • Scene Integration | **[Setup Guide →](engines/godot.md#godot)** |        
| **🎬 Unreal Engine** | Material Editor • HLSL Support  | **[Setup Guide →](engines/unreal.md#unreal-engine)** |
| **🧩 Unity** | Shader Graph • HLSL Support • Animation Timeline | **[Setup Guide →](engines/unity.md#unity)** |


---

### 🔧 **What Each Engine Section Includes:**
- ✅ **Step-by-step setup guides** with screenshots
- ✅ **Shader-specific implementation examples**
- ✅ **Runtime parameter control methods**


---

### 📹 Media Gallery

<div style="display: flex; justify-content: center; gap: 40px; flex-wrap: wrap; text-align: center;">

  <div style="width: 30%;">
    <h4>🐬 Swimming Dolphin</h4>
    <img src="../../../static/videos/swimming_dolphin.gif
        " alt="Swimming Dolphin GIF" width="640" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
  </div>

  <div style="width: 30%;">
    <h4>🌅 Sunrise Lighting</h4>
    <img src="../../../static/videos/sunrise.gif
      " alt="Sunrise Lighting GIF" width="640" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
  </div>

  <div style="width: 30%;">
    <h4>🛸 TIE Fighter</h4>
     <img src="../../../static/videos/demo_tf.gif
      " alt="Tie Fighter" width="640" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
  </div>

</div>

<p align="center"><em>Animations provided by <strong>Shader Team</strong></em></p>

 Want to see more animations? 🎬 [Explore the Gallery](https://github.com/friedaxvictoria/procedural_shader_framework/tree/main/shaders/screenshots)
