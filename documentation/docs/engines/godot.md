<div class="container">
    <h1 class="main-heading">Godot Engine Framework Structure</h1>
    <blockquote class="author">by Jeewan Dhamala & Mona Elbatran</blockquote>
</div>

Godot represents a light, open-source game development framework characterized by its integrated shader compiler and node-based architecture optimized for real-time graphics rendering in both 2D and 3D contexts. Distinguished from commercial alternatives such as Unity, Godot employs a purely code-based approach to shader development, eschewing visual scripting interfaces in favor of direct shader language implementation through its proprietary GDSL syntax.

* **Integration Methods:**
    * Visual Scripting: *Not supported for shader development*
    * Standard Scripting: Godot Shader Language (GDSL)
* **Supported Render Pipelines:** Default Scripting: GDScript with node lifecycle pipeline (_init(), _enter_tree(), 
 _ready(),_process(), etc.)
* **Supported Engine Versions:** Comprehensive testing conducted on *Godot 4.2.1* 
* **Implemented Shader Categories:**
    * CanvasItem Shaders (2D post-processing and UI effects)
    * Spatial Shaders (3D material systems and surface rendering)

---

## File Structure
This framework structure showcases a Godot Engine setup for a rendering-focused application using GDScript 
and GLSL shaders. Below is an overview of how the project is structured, including scripts, shaders, 
and their interactions.

```
godot/
├── 📁 .vscode/
├── 📁 addons/
├── 📁 includes/
│   ├── 📁 global_variables/
│   │   └── 📄 global_variables.gdshaderinc
│   ├── 📁 helper_functions/
│   │   └── 📄 helper_functions.gdshaderinc
│   └── 📄 sdf_updated.gdshaderinc
├── 📁 scripts/
│   └── 📄 sdf_updated.gd
├── ⚙️ .editorconfig
├── 📋 .gitattributes
├── 🚫 .gitignore
├── 🖼️ icon.svg
├── 📄 icon.svg.import
├── 🎮 project.godot
├── 📖 README.md
├── 🎨 sdf_updated.gdshader
├── 🌳 sdf_updated.tres
└── 🎬 sdf_updated.tscn
```

---
## Getting Started

1. Clone or download the project files **[Project Link](https://github.com/friedaxvictoria/procedural_shader_framework.git)**
2. Open the project in Godot Engine
3. Run the main scene (`sdf_updated.tscn`) to see the SDF rendering in action
4. Modify the SDF Manager script (`sdf_updated.gd`) to add custom shapes and effects
5. Experiment with shader parameters, through inspector, to achieve desired visual results

---

## Workflow Pipeline

1. **User Interaction**: The user modifies the scene by adding or removing SDFs via scripts in the directory `scripts/sdf_updated.gd`, attached to nodes in `sdf_updated.tscn`.
2. **Data Passing**: The GDScript updates shader uniforms (e.g., SDF positions, sizes) through the global variables system.
3. **Shader Processing**:

    - The main fragment shader (`sdf_updated.gdshader`) includes the main rendering file (`sdf_updated.gdshaderinc`).
    - Helper functions from `includes/helper_functions/` support the main rendering logic.
    - Global variables from `includes/global_variables/` provide shared data access.
    - The IntegrationFlexible method combines raymarching, lighting, and noise to produce the final image.

4. **Rendering**: The shader outputs the final pixel colors, rendering the dynamic SDF scene in the `sdf_updated.tscn` scene.

🚀 **[Explore the Complete Workflow →](godot/shaderFlow.md)**

---

## Key Features

- **Dynamic SDF Manipulation**: Real-time addition and removal of geometric primitives
- **Modular Shader Architecture**: Organized shader code for maintainability and reusability
- **Flexible Rendering Pipeline**: Supports various lighting models and procedural effects
- **Performance Optimized**: Efficient raymarching implementation for real-time rendering
- **User-Friendly Interface**: GDScript integration for easy scene modification

---

## Requirements

- Godot Engine 4.x
- Graphics card with shader support
- Basic understanding of GDScript and GLSL shaders

