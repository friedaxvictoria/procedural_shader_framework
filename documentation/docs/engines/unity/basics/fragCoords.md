<div class="container">
    <h1 class="main-heading">Fragment Coordinates</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This function computes fragment coordinates ranging from 0 to 1 based on input coordinates. This function is the basis for all others and should always be included in a shader.

---

## The Code

``` hlsl
void computeFragmentCoordinates_float(float2 inputCoordinates, float scaleUp, float scaleRight, out float2 fragmentCoordinates)
{
    fragmentCoordinates = inputCoordinates.xy * 2 - 1;
    if (scaleRight>scaleUp)
        fragmentCoordinates.x *= scaleRight / scaleUp;
    else
        fragmentCoordinates.y *= scaleUp / scaleRight;
}
```

---

## The Parameters

### Inputs:
- ```float2 inputCoordinates```: The input coordinates - usually uv-input of the object the shader is applied to
- ```float scaleUp```: The vertical scale of the object 
> *ShaderGraph default value*: 1
- ```float scaleRight```: The horizontal scale of the object
> *ShaderGraph default value*: 1

### Outputs:
- ```float2 fragmentCoordinates```: The coordinates mapped to 0 to 1 which are a required input to [SDF Raymarching](...), [Water Surface](...), and certain lighting functions.

---

## Notes on Non-Uniformly Shaped Objects

If a square-shaped object is used within the scene, both the **scaleUp** and the **scaleRight** can be disregarded in the ShaderGraph oder simply set to one for the Standard Scripting. However, if rectangles (e.g. fullscreen shaders) or cuboids are utilised, the scaling parameters are necessary to ensure that no distortion occurs by applying the ratio of the scales to the outputted parameters.

The values used depend on the object's extent as well as Unity's camera:

- For a rectangle choose the vertical scale as **scaleUp** and the horizontal scale as **scaleRight**
- For a cuboid choose the scales as above taking Unity's camera into account. If the camera looks along the z-axis and the y-axis defines the upwards vector, choose the y-scale as **scaleUp** and the x-scale as **scaleRight**.

> If a cuboid is used that is differently scaled in each dimension, the procedural results can only be non-distorted for a combination of two axis.

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/Basics/Fragment Coordinates`

    To easily get access to the scale, add Unity's *Object Node*, connect the scale-parameter to Unity's *Splitter Node*, and choose the required dimensions to connect to the custom node's inputs. 

    ![Unity Translate Camera](images/translateCamera.png){ width="500" }

    >Due to internal workings of the node, the inputCoordinates-input is not required. Within the SubGraph a "Branch On Input Connection" node is used to determine whether any input coordinates were connected to their respective input. If this is not the case, the uv-coordinates are used as a default input.

    ![Unity Translate Camera](images/translateCamera.png){ width="500" }

=== "Standard Scripting"
    Include ...

---

This is an engine-specific implementation without a shader-basis.