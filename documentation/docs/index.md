# 🎨 Procedural Shader Development Documentation

Welcome to the **Shader Snippets Documentation Site** — a collaborative knowledge base for procedural shaders used in multiple engines including **Unreal**, **Unity**, and **Godot**.

---

## 🧠 What Are Shaders?

**Shaders** are small programs that run on the GPU to control how objects are drawn on the screen controlling color, shape, lighting, animation, and more. Procedural shaders use **mathematical functions** to generate visuals dynamically without relying on textures or models.

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

This documentation bridges that gap, taking reusable shader logic and adapting it to each platform’s workflow. This documentation helps shader developers and engine integrators:

- Understand how each shader works (algorithm, parameters, results).
- Learn how to use these shaders in different game engines.
- Explore visual demos and integration walkthroughs.

---

## 🔍 What's Inside?

**🧩 Engine Integration**  
Learn how to use shaders across different engines:


| Engine             | Features             | Integration Guide                 |
|------             |--------               |-----------------                  | 
| **🚀 Godot** | GDScript Control • ShaderMaterial • Scene Integration | **[Setup Guide →](engines/godot.md#godot)** |        
| **🎬 Unreal Engine** | Material Editor • HLSL Support  | **[Setup Guide →](engines/unreal.md#unreal-engine)** |
| **🧩 Unity** | Shader Graph • HLSL Support • Animation Timeline | **[Setup Guide →](engines/unity.md#unity)** |




### 🔧 **What Each Engine Section Includes:**
- ✅ **Step-by-step setup guides** with screenshots
- ✅ **Shader-specific implementation examples**
- ✅ **Runtime parameter control methods**

<!-- <details>
<summary><strong>🎯 Quick Engine Comparison</strong></summary>

| Feature | Unreal | Unity | Godot |
|---------|:------:|:-----:|:-----:|
| **Visual Editor** | ✅ Material Editor | ✅ Shader Graph | ✅ Visual Script |
| **Code Support** | HLSL/MaterialExpressions | HLSL/ShaderLab | GLSL |
| **Real-time Preview** | ✅ | ✅ | ✅ |
| **Mobile Optimization** | ✅ | ✅ | ✅ |
| **VR Support** | ✅ | ✅ | ✅ |
| **Learning Curve** | Medium | Medium | Easy |

</details> -->

---

### 📹 Media Gallery
Watch shader demos in action:

<img src="../../../static/images/demo_tf.gif" alt="TIE Fighter" width="900" height="225">
---

<!--
## 🤝 How to Contribute
Want to add your own shader or document its usage in an engine?

👉 Check out the [Team Guide](team-guide.md)
-->


<!--
## 🚀 What's Next?
- Add new shaders weekly
- Improve engine integration with GIFs, performance tips
- Add interactivity (live demos, WebGL previews)
-->

## 🧠 Shader Flow in Godot: A Setup Guide for SDF-Based Rendering

!!! example "🚀 Objective: Procedural Scene Generation with Signed Distance Functions"
   This guide provides a structured approach to building interactive raymarching-based scenes using Signed Distance Functions (SDFs) in the Godot Engine.

   **Outcome:** A fully interactive procedural scene utilizing custom fragment shaders, lighting, and camera controls.

   **Estimated Completion Time:** Approximately 10 minutes

---
<!-- 
### 📋 Step 1: Scene Initialization and Shader Integration

!!! tip "🎯 Goal: Establish Core Scene Hierarchy and Link Shader Resources"

**Procedure:**

1. **Create a `Node2D` Root Node**  
   Begin by adding a `Node2D` to serve as the base of your scene hierarchy.

2. **Attach the Script `sdf_updated.gd` to `Node2D`**  
   This script facilitates real-time updates and management of SDF objects.
    - 📁 *Script Path: `addons/scripts/sdf_updated.gd`* 

3. **Add a `ColorRect` Node as a Child of `Node2D`**  
   This node will be the visual canvas onto which the shader will render.

    <div align="left">
    <img src="../../../static/images/ss1.png" alt="Shader Material Applied to ColorRect" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

4. **Prepare the ShaderMaterial Resource**  
    - Create a new `ShaderMaterial`.
    - Assign the fragment shader file:  
        📁 *Shader Path: `res/sdf_updated.gdshader`*

5. **Assign the ShaderMaterial to the `ColorRect` Node**  
   This links the shader logic with the visible rendering surface.

    <div align="left">
    <img src="../../../static/images/ss2.png" alt="Shader Material Applied to ColorRect" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

6. **Save and Execute the Scene**  
   Run the project to verify that the initial shader output is displayed.

---

### 🎨 Step 2: Incorporating SDF-Based Primitives

!!! success "✨ Supported SDF Primitives"
The system currently supports **seven** distinct SDF shapes:

- **Sphere**
- **Cube**
- **Torus**
- **Dolphin** *(Animated)*
- **Hexagonal Prism**
- **Octahedron**
- **Ellipsoid**

#### 🔧 Configurable Parameters

Each SDF object accepts the following customizable parameters:

| **Parameter** | **Type**     | **Description / Options** |
|---------------|--------------|----------------------------|
| `Type`        | `int`        | `0`=Sphere, `1`=Cube, `2`=Torus, `3`=Dolphin, `4`=HexPrism, `5`=Octahedron, `6`=Ellipsoid |
| `Position`    | `Vector3`    | World-space coordinates    |
| `Size`        | `Vector3`    | Scale factors for each axis |
| `Radius`      | `float`      | Defines object roundness   |
| `Color`       | `Vector3`    | RGB vector for base color  |
| `Noise Type`  | `int`        | `0`=None, `1`=Pseudo3D, `2`=FBM, `3`=N31 |
| `Specular Color` | `Vector3` | Color for light reflections |
| `Specular Strength` | `float` | Intensity of specular highlights |
| `Shininess`   | `float`      | Surface reflectiveness     |

!!! note "🐬 Special Case: Animated Dolphin"
The **Dolphin** primitive supports additional animation parameters:

- `Speed`: Controls swimming velocity
- `Direction`: A `Vector3` indicating motion vector
- `Time Offset`: Adjusts animation phase for individual dolphins

---

### 💾 Script Integration Example

Within the `_ready()` function of `sdf_updated.gd`, populate the scene by instantiating and configuring `ShaderObject` instances:

```gd
func _ready():
    shader_objects = [
        # Sphere
        ShaderObject.new().set_values(0, Vector3(0, 0.0, 0), Vector3.ZERO, 1.0, Vector3(0.2, 0.2, 1.0), 0),

        # Cubes
        ShaderObject.new().set_values(1, Vector3(1.9, 0, 0), Vector3(1, 1, 1), 0.2, Vector3(0.2, 1.0, 0.2), 0),
        ShaderObject.new().set_values(1, Vector3(-1.9, 0, 0), Vector3(1, 1, 1), 0.2, Vector3(0.2, 1.0, 0.2), 0),

        # Torus
        ShaderObject.new().set_values(2, Vector3(-2.0, 0.0, 0), Vector3(1.0, 5.0, 1.5), 0.2, Vector3(1.0, 0.2, 0.2), 2),
        ShaderObject.new().set_values(2, Vector3(2.0, 0.0, 0), Vector3(1.0, 5.0, 1.5), 0.2, Vector3(1.0, 0.2, 0.2), 2),

        # Dolphin (commented out by default)
        # ShaderObject.new().set_values(3, Vector3(0, -2.0, 0), Vector3(5.0, 5.0, 5.0), 3.0, Vector3(0.5, 0.7, 1.0), 0, Vector3.ONE, 0.8, 16.0, 2.0, Vector3(1, 0, 0.2), 0.0),

        # HexPrism
        ShaderObject.new().set_values(4, Vector3(0.0, 0.0, 0.0), Vector3(1, 1, 1), 0.3, Vector3(0.2, 1.0, 0.2), 0),

        # Octahedron
        ShaderObject.new().set_values(5, Vector3(1.9, 0.0, 0.0), Vector3(1, 1, 1), 1.0, Vector3(0.2, 1.0, 0.2), 0),

        # Ellipsoid
        ShaderObject.new().set_values(6, Vector3(-1.9, 0.0, 0.0), Vector3(1, 1, 1), 0.3, Vector3(0.2, 1.0, 0.2), 0),
    ]
``` -->