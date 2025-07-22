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

1. Clone or download the project files **[Click Here for Link](https://github.com/friedaxvictoria/procedural_shader_framework.git)**
2. Open the project in Godot Engine
3. Run the main scene (`sdf_updated.tscn`) to see the SDF rendering in action
4. Modify the SDF Manager script (`sdf_updated.gd`) to add custom shapes and effects
5. Experiment with shader parameters, through inspector, to achieve desired visual results

---

## Framework Workflow

1. **User Interaction**: The user modifies the scene by adding or removing SDFs via scripts in the directory `scripts/sdf_updated.gd`, attached to nodes in `sdf_updated.tscn`.
2. **Data Passing**: The GDScript updates shader uniforms (e.g., SDF positions, sizes) through the global variables system.
3. **Shader Processing**:

    - The main fragment shader (`sdf_updated.gdshader`) includes the main rendering file (`sdf_updated.gdshaderinc`).
    - Helper functions from `includes/helper_functions/` support the main rendering logic.
    - Global variables from `includes/global_variables/` provide shared data access.
    - The IntegrationFlexible method combines raymarching, lighting, and noise to produce the final image.

4. **Rendering**: The shader outputs the final pixel colors, rendering the dynamic SDF scene in the `sdf_updated.tscn` scene.

👉 **[View how it works→](godot/shaderFlow.md)**

---

## Overal Structure in Detail

### **1. Global Variables**

Global variables are managed in the `includes/global_variables/` folder to store all shared variables used across the shaders, ensuring consistency and ease of access.

- **Location**: `includes/global_variables/` folder
- **Purpose**: Defines global constants and uniforms used throughout the shader pipeline.

**Examples**:

- uniform vec2 resolution: Screen resolution for rendering.
- uniform float time: Animation time for dynamic effects.
- uniform vec3 camera_pos: Camera position for raymarching.
- SDF-specific parameters (e.g., positions, sizes, or types of SDFs).

**Usage**: Included in the shader inclusive and helper function files to access shared variables.

👉 **[View how it works→](godot/globalVariables.md)**

### **2. Helper Functions for Rendering**

Helper functions are stored in the `includes/helper_functions/` folder to support the main rendering logic. These are called within the main shader include files to perform specific tasks.

- **Location**: `includes/helper_functions/` folder
- **Purpose**: Contains utility functions for rendering, such as vector transformations, color manipulations, or mathematical utilities.

**Examples**:

- Normalizing vectors for lighting calculations.
- Converting coordinates for raymarching.
- Utility functions for blending or interpolating values.

👉 **[View how it works→](godot/helperFunction.md)**

### **3. GDScript File for Dynamic SDF Management**

A GDScript file is attached to a Node2D to allow users to dynamically add or remove Signed Distance Fields (SDFs) on the screen. This script provides an interface for manipulating SDFs, which are then passed to the shader for rendering.

- **Location**: `scripts/` folder
- **Purpose**: Manages the creation, modification, and removal of SDFs. Users can interact with this script to customize the scene dynamically.

**Key Functionality**:

- Add SDFs (e.g., torus, dolphin) to the scene.
- Remove SDFs based on user input.
- Update shader parameters with SDF data for rendering.

👉 **[View how it works→](godot/gdScript.md)**

### **4. Main GDShader Include Files**

The project uses the main shader include file `sdf_updated.gdshaderinc` that contains core rendering logic, such as lighting, raymarching, and noise functions. This file is included in the main fragment shader to provide the complete rendering pipeline.

**File**:
- `includes/sdf_updated.gdshaderinc`: Contains the complete rendering pipeline including lighting calculations, raymarching algorithms, and noise functions for procedural effects.

**Purpose**: This file contains the modularized shader logic, making it reusable and easier to maintain across different scenes.

👉 **[View how it works→](godot/gdShaderInclude.md)**



**Usage**: Referenced by the main `sdf_updated.gdshaderinc` file as needed.

### **5. Main Fragment Shader**

The main fragment shader orchestrates the rendering pipeline by calling the IntegrationFlexible method defined in the `sdf_updated.gdshaderinc` file.

- **File**: `sdf_updated.gdshader`
- **Scene**: `sdf_updated.tscn`
- **Resource**: `sdf_updated.tres`
- **Purpose**: Combines all shader logic to produce the final pixel colors.

**Key Functionality**:

- Includes global variables for shared data.
- Includes the main `sdf_updated.gdshaderinc` file.
- Calls the IntegrationFlexible method, which integrates raymarching, lighting, and noise effects to render the scene.

**Structure**:
```glsl
shader_type canvas_item;

#include "includes/sdf_updated.gdshaderinc"

void fragment() {
    vec3 color = IntegrationFlexible(FRAGCOORD, resolution, time, camera_pos);
    COLOR = vec4(color, 1.0);
}
```
👉 **[View how it works→](godot/mainFragmentShader.md)**

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

