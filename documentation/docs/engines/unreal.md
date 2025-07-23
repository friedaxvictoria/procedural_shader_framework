# 🎮 Unreal Engine Shader Integrations

Unreal Engine is a powerful 3D rendering platform widely used across various industries. It is known for its visual scripting capabilities, high-fidelity real-time rendering, and flexible architecture that supports both artistic and technical workflows.
---

- **Integration Methods:** 
    - Visual Scripting
    - Standard Scripting 
- **Supported Unreal Engine Versions:** All functions were tested on *Unreal Engine 5.5.4* on *Windows* 

---

## Integrate the Framework

To easily include the Framework into a Unreal Engine project, this guide can be followed:

1. Create a new project in Unreal Engine

2. Create a new folder called "Plugins" within your project

3. Extract the ProceduralShaderFramework.zip within this newly created folder. This should result in the following folder structure:
```
YourProject/
├── Plugins/
│   └── ProceduralShaderFramework/
│       ├── ProceduralShaderFramework.uplugin
│       ├── Binaries/
│       └── ...
├── YourProject.uproject
```

4. Regenerate your project:
Right-click your .uproject file and pick "Generate Visual Studio project files"


5. Launch Unreal Engine 

6. Check if the Plugin is Enabled: 
    - Go to Edit > Plugins in the Unreal Editor.
    - Search for ```ProceduralShaderFramework```.
    - Make sure it's enabled.
    - Restart the editor if prompted.

7. Add ```ShaderPlayground``` to your level


    <figure markdown="span">
        ![Unreal Engine ShaderPlayground](images/shaderplayground.png){ width="400" }
    </figure>

8. Create a new Material with the domain set to ```Post Processing```

    <figure markdown="span">
        ![Unreal Engine PostProcessing Domain](images/postprocess.png){ width="400" }
    </figure>

9. Set the required variables within the ```ShaderPlayground```

    <figure markdown="span">
        ![Unreal Engine ShaderPlayground Parameters](images/parameters.png){ width="400" }
    </figure>

10. Have fun!

---

## Visual Scripting

!!! Note
    The visual scripting was integrated to provide a visual alternative. It's main function is to help understand the structure of Unreal Engine's integration. While it works well for small examples, the compilation time for larger scenes can drastically increase. **It is not user friendly to generate large scenes.**

The functions have been integrated as Material Functions that are callable as nodes in the Material Editor. All nodes are located under the **ProceduralShaderFramework** category. Detailed paths for the individual nodes are noted after the description of each of the functions. 

To simplify some initial setups, nodes come with default parameters. For each description of an input parameter, the node's default value for said parameter is noted. If no default value is explicitly mentioned, a input is required.

> Be aware that the visual previews of the nodes might not be expressive. E.g. if correctly used, the visual preview for an SDF node will always be uniformly black or white.

To implement a shader with visual scripting, simple pick the required nodes from the dropdown and connect them appropriately.

---


## Standard Scipting
For the Stardard Scripting approach, a trade-off between user-friendliness and true shader programming had to me made. Since Unreal Engine's graphics API is extremely low-level and would require the user to interact with C++ code, we decided to circumvent that and use Unreal Engine's ```Custom```-Node within the Material Editor, which allows the user to write HLSL code within the Engine. A possible setup, which would allow the user to implement most scenes, would look like above.

*<figure markdown="span">
![Unreal Engine ShaderPlayground Parameters](images/examplehlsl.png){ width="1000" }
</figure>*



---

Find the [Tutorials](unreal/tutorials/christmasTree.md) to discover in-depth explanations on how to construct custom procedural shaders in Unreal Engine and to better understand the relations between functions.

---

## General notes

Some Visual Scripting nodes are different to the HLSL Scripting version, due to limitations in the Material Editor. The most prominent example being the absense of a float3x3 datatype. In cases where this would be required, the matrix is split up into multiple vectors and thus require multiple pins to be connected instead of one.

