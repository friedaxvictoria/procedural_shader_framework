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

!!! info "🎨 Explore All Shaders in This Project"

    Want to see all procedural shaders that are adapted for this engine?

    🧠 Get full access to:
    
    - Shader logic and breakdowns  
    - Code previews with syntax highlighting  
    - Demos, GIFs, and video walkthroughs

    👉 **[Browse Shader Gallery →](../shaders/shaderPage.md)**

---

!!! info "🗂️ View Godot Shader Code Impelementation on GitHub"

    Looking for full Godot project files with GDScript, `.gdshader`, and helpers?

    🔗 Get the complete implementation in our GitHub directory:

    **[📁 Godot Shader Implementation →](https://github.com/friedaxvictoria/procedural_shader_framework/tree/main/godot)**

    💼 Includes:

    - Scene setup files
    - ShaderMaterial assets
    - `.gdshader`, `.gdshaderinc`, and GDScript
    - Integration-ready examples


---

## 🧠 Shader Flow in Godot: A Setup Guide for SDF-Based Rendering

!!! example "🚀 Objective: Procedural Scene Generation with Signed Distance Functions"
   This guide provides a structured approach to building interactive raymarching-based scenes using Signed Distance Functions (SDFs) in the Godot Engine.

   **Outcome:** A fully interactive procedural scene utilizing custom fragment shaders, lighting, and camera controls.

---

### 📋 Step 1: Scene Initialization and Shader Integration

!!! tip "🎯 Goal: Establish Core Scene Hierarchy and Link Shader Resources"

**Procedure:**

1. **Create a `Node2D` Root Node**  
   Begin by adding a `Node2D` to serve as the base of your scene hierarchy.

2. **Attach the Script `sdf_updated.gd` to `Node2D`**  
   This script facilitates real-time updates and management of SDF objects.
    - 📁 *Script Path: `res://addons/scripts/sdf_updated.gd`* 
    <div align="center">
        <img src="../../../static/images/attachScript.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

3. **Add a  `ColorRect` Node as a Child of `Node2D`**  
   This node will be the visual canvas onto which the shader will render.

    <div align="center">
        <img src="../../../static/images/addchildNode.png" alt="Shader Material Applied to ColorRect" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
        <img src="../../../static/images/addColorRect.png" alt="Shader Material Applied to ColorRect" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

    And after adding the child node, go to the Node2D and under the `Shader Material Target`, select the `ColorRect` node.
    <div align="center">
        <img src="../../../static/images/assignColorRect2Node2D.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

4. **Prepare the ShaderMaterial Resource**  
    - Create a new `ShaderMaterial` under root directory.
    <div align="center">
        <img src="../../../static/images/attachShaderMaterial.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
        <img src="../../../static/images/addShaderMaterial.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>
    - Assign the fragment shader file:  
        📁 *Shader Path: `res/sdf_updated.gdshader`*
    <div align="center">
        <img src="../../../static/images/attachShader2Material.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

5. **Assign the ShaderMaterial to the `ColorRect` Node**  
   This links the shader logic with the visible rendering surface.

    <div align="center">
        <img src="../../../static/images/attachMaterial2ColorRect.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
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

- `Noise`: None
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
```

### 💡 Step 3: Lighting & Environment
!!! tip "🎯 Goal: Enhance Visual Fidelity Using Environmental Contexts"
In this step, we will integrate dynamic lighting and background environments to enrich the SDF-rendered scene. Lighting influences shading and reflections, while terrain presets introduce contextual depth.
### Inspector Controls
#### 🌞 Lighting
- **Light Position** – Point light source position for Phong lighting
<div align="center">
  <img src="../../../static/images/lightingMode.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>

#### 🌍 Terrain
- **None** – No landscapes, only SDFs
- **Desert** – Arid landscape with warm tones  
- **Water** – Ocean surface with reflections
<div align="center">
  <img src="../../../static/images/terrainMode.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>


### 🎮 Step 4: Camera Controls

!!! tip "🎯 Goal: Enable Interactive and Cinematic Viewing"
In this step, we will configure camera behaviors that allow users to interactively explore the procedural scene or enable automated motion for presentation. These controls enhance spatial understanding and visual engagement through options like orbiting, shaking, and static framing.
<div align="center">
  <img src="../../../static/images/cameraMode.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
  <img src="../../../static/images/cameraModewithParams.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>

**Available Modes:**

| Mode | Description | Parameters |
|------|-------------|------------|
| **🖱️ Mouse Control** | Interactive camera with mouse input | Click and drag to orbit |
| **🌀 Auto Orbit** | Automatic camera rotation | **Orbit Speed** – Controls how fast the camera revolves around the target. <br> **Orbit Axis** – Determines the axis of rotation (e.g., Y-axis for horizontal orbit). |
| **📷 Static Camera** | Fixed camera position | – |
| **↔️ Back-and-Forth** | Horizontal panning motion | **Movement Speed** – Sets how quickly the camera moves side to side. |
| **💥 Shake** | Subtle camera jitter for dynamic effect | **Shake Speed** – Frequency of the shake motion. <br> **Shake Intensity** – Amplitude or strength of the shaking effect. |

### 🎨 Step 5: Color Animation Modes

!!! tip "🎯 Goal: Add Dynamic Color Behavior to Visual Elements"
In this step, we introduce animated color modes that enhance the visual expressiveness of objects. These modes simulate static coloring, cyclic transitions, or wave-like color movement across the surface.

<div align="center">
  <img src="../../../static/images/colorAnimation.png" alt="Color Mode Options" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
  <img src="../../../static/images/colorAnimationParams.png" alt="Color Mode Parameters" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>

**Available Modes:**

| Mode | Description | Parameters |
|------|-------------|------------|
| **🎨 Static** | Applies a constant, unchanging color to the object | – |
| **🌈 Cycle Color** | Continuously cycles through color hues over time | **Cycle Speed** – Controls how fast the color transitions occur. |
| **🌊 Wave Color** | Propagates color changes as a wave across the object | **Wave Speed** – Sets the rate at which the wave moves through the object. |


### 🔄 Step 6: Object Animation Modes

!!! tip "🎯 Goal: Add Temporal Animation for Expressive Object Behavior"
This step introduces pulsing animations that affect the overall visual rhythm of the object. It adds a temporal, breathing-like motion useful for highlighting objects or adding ambient motion to static shapes.

<div align="center">
  <img src="../../../static/images/animationMode.png" alt="Object Animation Mode" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>

**Available Modes:**

| Mode | Description |
|------|-------------|
| **🛑 No Animation** | Keeps the object static with no animation applied |
| **💫 Pulse Animation** | Applies a rhythmic pulsing effect to the object by modulating its brightness or scale over time |


---

## 🔧 Integration List

!!! success "🎨 Complete Rendering & Shader System"
    Master raymarching, lighting, and surface effects in one comprehensive guide!
    
    🚀 **What you'll learn:**
    - Advanced raymarching with SDF integration
    - Phong lighting implementation
    - Atmospheric sunset lighting
    - Animated water surfaces
    - Desert environment creation
    
    👉 **[View Rendering Guide →](godot/rendering_shaders.md)**

!!! tip "📐 All SDF Primitive Shapes"
    From basic spheres to complex organic dolphins - learn every SDF shape!
    
    🎯 **Includes:**
    - 7 different primitive shapes
    - Mathematical breakdowns
    - Use case examples
    - Performance optimization tips
    
    👉 **[Explore SDF Shapes →](godot/sdf_primitives.md)**

!!! example "🎮 Complete Camera Control System"
    Build interactive 3D experiences with full camera control!
    
    🎯 **Features:**
    - Mouse-driven camera movement
    - Smooth animation system
    - Forward/backward movement
    
    👉 **[Master Camera Controls →](godot/camera_controls.md)**

!!! note "🎭 Animation & Effects Toolkit"
    Bring your objects to life with dynamic animations and effects!
    
    ✨ **Available effects:**
    - Pulsing animations
    - Translation and rotation
    - Dynamic color changes
    
    👉 **[Animate Everything →](godot/animations_effects.md)**

!!! abstract "🛠️ Essential Utilities"
    Core utility functions for advanced shader development!
    
    🔧 **Tools included:**
    - UV mapping systems
    - Coordinate transformations
    
    👉 **[View Utilities →](godot/utilities.md)**

---

## 📌 Notes
- Works with ShaderMaterial and GDScript.
- Great for flexible 2D/3D rendering pipelines.
- `.gdshaderinc` lets you reuse logic across multiple shaders.
