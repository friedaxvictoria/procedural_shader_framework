<div class="container">
    <h1 class="main-heading">Shader Development Workflow Roadmap</h1>
    <blockquote class="author">by Jeewan Dhamala & Mona Elbatran</blockquote>
</div>

!!! info "⚡ Shader Pipeline: Dynamic SDF Development Framework"
    This framework enables dynamic, modular shader development in Godot using Signed Distance Fields (SDFs). To use it, we have to follow these steps in order:  
    
    - Access shared data through global variables.  
    - Utilize helper functions for rendering calculations.  
    - Manage SDFs dynamically via GDScript.  
    - Integrate core rendering logic from the main shader include file.  
    - Combine all components in the main fragment shader to render the scene.  

    We have to review each section below for detailed instructions and links to documentation, starting with global variables and progressing through to the final shader output.

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

📖 **[Learn More →](globalVariables.md)**

### **2. Helper Functions for Rendering**

Helper functions are stored in the `includes/helper_functions/` folder to support the main rendering logic. These are called within the main shader include files to perform specific tasks.

- **Location**: `includes/helper_functions/` folder
- **Purpose**: Contains utility functions for rendering, such as vector transformations, color manipulations, or mathematical utilities.

**Examples**:

- Normalizing vectors for lighting calculations.
- Converting coordinates for raymarching.
- Utility functions for blending or interpolating values.

📖 **[Learn More →](helperFunction.md)**

### **3. GDScript File for Dynamic SDF Management**

A GDScript file is attached to a Node2D to allow users to dynamically add or remove Signed Distance Fields (SDFs) on the screen. This script provides an interface for manipulating SDFs, which are then passed to the shader for rendering.

- **Location**: `scripts/` folder
- **Purpose**: Manages the creation, modification, and removal of SDFs. Users can interact with this script to customize the scene dynamically.

**Key Functionality**:

- Add SDFs (e.g., torus, dolphin) to the scene.
- Remove SDFs based on user input.
- Update shader parameters with SDF data for rendering.

📖 **[Learn More →](gdScript.md)**

### **4. Main GDShader Include Files**

The project uses the main shader include file `sdf_updated.gdshaderinc` that contains core rendering logic, such as lighting, raymarching, and noise functions. This file is included in the main fragment shader to provide the complete rendering pipeline.

**File**:
- `includes/sdf_updated.gdshaderinc`: Contains the complete rendering pipeline including lighting calculations, raymarching algorithms, and noise functions for procedural effects.

**Purpose**: This file contains the modularized shader logic, making it reusable and easier to maintain across different scenes.

> **Note on Adding New Shaders:** To add a new shader (e.g., for Lambertian lighting effects) to `sdf_updated.gdshaderinc`, we should create a new function following the existing pattern like `Pseudo3dNoise`. Access global variables such as Tme, screen_resolution, or camera_position from `includes/global_variables/global_variables.gdshaderinc`, and leverage helper functions like rot2, n2D, or normalize from `includes/helper_functions/helper_func.gdshaderinc`. Finally, we should integrate this new shader function into the `IntegrationFlexible` method with its proper logic, like by adding conditional logic to check for the shader's activation condition, calling the function, comparing hit distances with other surfaces to select the closest one, and applying the lighting calculations and material properties similar to existing shaders. And at last,testing the implementation within the `sdf_updated.tscn` scene to ensure proper integration with camera animations and GDScript SDFs.

📖 **[Learn More →](gdShaderInclude.md)**


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
📖 **[Learn More →](mainFragmentShader.md)**
