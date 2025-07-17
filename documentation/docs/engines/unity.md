# Overview

Unity is a versatile real-time engine known for its **ShaderGraph system**, **cross-platform support**, and ease of integration for custom shaders.

- **Integration Methods:** 
    - Visual Scripting: ShaderGraph
    - Standard Scripting: ShaderLab 
- **Supported Render Pipelines:** URP (Universal Render Pipeline), others may work but were not tested 
- **Supported Unity Versions:** All functions were tested on *Unity 2022.3.50* and *Unity 6000.0.4* 
- **Supported Shader Types:**
    - Unlit Shader
    - Lit Shader
    - Fullscreen Shader

---

## Integrate the Framework

To easily include the integration of the framework into any Unity project, it is available as a UPM. The following gives a step by step guide on how to set up a project:

1. Create a URP (Universal Render Pipeline) in Unity

2. Navigate to *Window/Package Manager*

    ![Unity Overview: Find Package Manager](unity/images/overview/packageManager.png){ width="300" }

3. Add a new package using *Add package from git URL*. Use the following url in the popup-window: [https://github.com/friedaxvictoria/ProceduralShaderFrameworkPackage.git](https://github.com/friedaxvictoria/ProceduralShaderFrameworkPackage.git).

    ![Unity Overview: Include UPM](unity/images/overview/IncludeViaGit.png){ width="300" }

4. Locate the package in the project. Include the prefab **ShaderUniformControl** that can be found at *ProceduralShaderFrameworkPackage/Runtime/uniforms* into the scene. This is essential for the required uniforms to be set. Read more about what their purpose at [Uniforms and C\#](unity/uniformsAndCs.md).

    ![Unity Overview: Locate Uniform Setting Prefab](unity/images/overview/locatePrefab.png){ width="300" }
    
    ![Unity Overview: Add Uniform Setting Prefab](unity/images/overview/addPrefab.png){ width="300" }

5. Create a custom shader with ShaderGraph or ShaderLab.

6. Apply the shader to a Unity material.

7. Apply the material to an object of choice or set it up as a full screen material.

---

## Visual Scripting

The functions have been integrated as Sub Graphs that are callable as nodes in a ShaderGraph. All nodes are located under **PSF** short for **Procedural Shader Framework** once the UPM has been included. Detailed paths for the individual nodes are noted after the description of each of the functions.

Be aware that the visual previews of the nodes might not be expressive. E.g. if correctly used, the visual preview for an SDF node will always be uniformly black or white.

---

## Standard Scipting

---

Find [Tutorials](...) to discover in-depth explanations on how to construct custom procedural shaders in Unity and to better understand the relations between functions.
