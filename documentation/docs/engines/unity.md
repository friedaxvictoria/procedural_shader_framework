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

## Get the Integration

To easily include the integration of the framework into any Unity project, it is available as a UPM. The following gives a step by step guide on how to set up a project:

1. Create a URP (Universal Render Pipeline) in Unity

image

2. Navigate to *Window/Package Manager*

image

3. Add a new package using *Add package from git URL*. Use the following url [https://github.com/friedaxvictoria/ProceduralShaderFrameworkPackage.git](https://github.com/friedaxvictoria/ProceduralShaderFrameworkPackage.git).

image

4. Locate the package in the project. Include the prefab **ShaderUniformControl** that can be found at *ProceduralShaderFrameworkPackage/Runtime/uniforms* into the scene. This is essential for the required uniforms to be set. Read more about what their purpose at [Uniforms and C\#](unity/uniformsAndCs.md).

image

5. Create a custom shader with ShaderGraph or ShaderLab.

6. Apply the shader to a Unity material.

7. Apply the material to an object of choice or set it up as a full screen material.

---

## Visual Scripting

The functions have been integrated as Sub Graphs that are callable as nodes in a ShaderGraph. All nodes are located under **PSF** short for **Procedural Shader Framework** once the UPM has been included. Detailed paths for the individual nodes are noted after the description of each of the functions.

---

## Standard Scipting

---

Find [Tutorials](camera/mouseBasedMovement.md) to discover in-depth explanations on how to construct custom procedural shaders in Unity and to better understand the relations between functions.
