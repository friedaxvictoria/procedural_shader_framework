<div class="container">
    <h1 class="main-heading">🧠 Shader Flow in Godot: A Setup Guide for SDF-Based Rendering</h1>
    <blockquote class="author">by Jeewan Dhamala & Mona Elbatran</blockquote>
</div>
!!! example "🚀 Objective: Procedural Scene Generation with Signed Distance Functions"
   This guide provides a structured approach to building interactive raymarching-based scenes using Signed Distance Functions (SDFs) in the Godot Engine.

   **Outcome:** A fully interactive procedural scene utilizing custom fragment shaders, lighting, and camera controls.

---
!!! info "🎮 Quick Start: Running the Existing Scene"
    If we've cloned the project and want to see the final result immediately:

    1. Open the Project in Godot
        - Launch Godot Engine
        - Select "Import" and navigate to the cloned project folder
        - Open the project

    2. Run the Main Scene
        - Select the main scene (sdf_updated.tscn)
        - click the "Play" button

    3. Explore the Interactive Features
        - In the inspector, experiment with real-time parameter adjustments
        - Observe the SDF-based procedural rendering in action

    The cloned project contains a complete, functional SDF rendering setup that we can immediately run and explore.
___

### 📋 Step 1: Scene Initialization and Shader Integration

!!! tip "🎯 Goal: Establish Core Scene Hierarchy and Link Shader Resources"

**Procedure:**

1. **Create a `Node2D` Root Node**  
   Begin by adding a `Node2D` to serve as the base of our scene hierarchy.

2. **Attach the Script `sdf_updated.gd` to `Node2D`**  
   This script facilitates real-time updates and management of SDF objects.
    - 📁 *Script Path: `res://addons/scripts/sdf_updated.gd`* 
    <div align="center">
        <img src="../../../static/images/images4Godot/attachScript.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

3. **Add a  `ColorRect` Node as a Child of `Node2D`**  
   This node will be the visual canvas onto which the shader will render.

    <div align="center">
        <img src="../../../static/images/images4Godot/addchildNode.png" alt="Shader Material Applied to ColorRect" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
        <img src="../../../static/images/images4Godot/addColorRect.png" alt="Shader Material Applied to ColorRect" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

    And after adding the child node, go to the Node2D and under the `Shader Material Target`, select the `ColorRect` node.
    <div align="center">
        <img src="../../../static/images/images4Godot/assignColorRect2Node2D.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

4. **Prepare the ShaderMaterial Resource**  
    - Create a new `ShaderMaterial` under root directory.
    <div align="center">
        <img src="../../../static/images/images4Godot/attachShaderMaterial.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
        <img src="../../../static/images/images4Godot/addShaderMaterial.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>
    - Assign the fragment shader file:  
        📁 *Shader Path: `res/sdf_updated.gdshader`*
    <div align="center">
        <img src="../../../static/images/images4Godot/attachShader2Material.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
    </div>

5. **Assign the ShaderMaterial to the `ColorRect` Node**  
   This links the shader logic with the visible rendering surface.

    <div align="center">
        <img src="../../../static/images/images4Godot/attachMaterial2ColorRect.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
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

Within the `_ready()` function of `sdf_updated.gd`, populate the scene by instantiating and configuring `ShaderObject` instances. **[[Explore more on Godot Script]](gdScript.md)**

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
  <img src="../../../static/images/images4Godot/lightingMode.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>

#### 🌍 Terrain
- **None** – No landscapes, only SDFs
- **Desert** – Arid landscape with warm tones  
- **Water** – Ocean surface with reflections
<div align="center">
  <img src="../../../static/images/images4Godot/terrainMode.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>


### 🎮 Step 4: Camera Controls

!!! tip "🎯 Goal: Enable Interactive and Cinematic Viewing"
In this step, we will configure camera behaviors that allow users to interactively explore the procedural scene or enable automated motion for presentation. These controls enhance spatial understanding and visual engagement through options like orbiting, shaking, and static framing.
<div align="center">
  <img src="../../../static/images/images4Godot/cameraMode.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
  <img src="../../../static/images/images4Godot/cameraModewithParams.png" alt="Camera Controls" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
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
  <img src="../../../static/images/images4Godot/colorAnimation.png" alt="Color Mode Options" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
  <img src="../../../static/images/images4Godot/colorAnimationParams.png" alt="Color Mode Parameters" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
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
  <img src="../../../static/images/images4Godot/animationMode.png" alt="Object Animation Mode" width="360" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>

**Available Modes:**

| Mode | Description |
|------|-------------|
| **🛑 No Animation** | Keeps the object static with no animation applied |
| **💫 Pulse Animation** | Applies a rhythmic pulsing effect to the object by modulating its brightness or scale over time |

