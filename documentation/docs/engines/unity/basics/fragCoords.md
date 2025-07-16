# Fragment Coordinates

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

> Both scaling parameters are required to account for non-uniformly scaled objects. Correcting the coordinates with the scaling relation, ensures that no distortion occurs.

### Outputs:
- ```float2 fragmentCoordinates```: The coordinates mapped to 0 to 1 which are arequired input to [SDF Raymarching](...), [Water Surface](...), and certain lighting functions.

---

## Notes

Write something about cubes and non-uniformity

---

## Implementation

=== "Visual Scripting"
    Find the node at PSF/Basics/Fragment Coordinates

    ![Unity Translate Camera](images/translateCamera.png){ width="500" }

    >Due to internal workings of the node, the inputCoordinates-input is not required. Within the SubGraph a "Branch On Input Connection" node is used to determine whether any input coordinates were connected to their respective input. If this is not the case, the uv-coordinates are used as a default input.

    ![Unity Translate Camera](images/translateCamera.png){ width="500" }

=== "Standard Scripting"
    Include ...

---

This is an engine-specific implementation without a shader-basis.