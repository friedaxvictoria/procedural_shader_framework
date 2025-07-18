# Combine Color

This function can be used to combine the output of different raymarching based functions. It is used **after** all the lighting functions have been applied to the raymarching. 

*Note:* This function has been added for completion's sake but is not recommended. It can only combine hit objects but it **cannot maintain** lighting effects that affect the environment such as the [Sunrise](...) or the [Point Light](...). For this, refer to [Minimum](minimum.md). However, it may be used for experimental shaders that compare the effect of different lighting functions.

---

## The Code

``` hlsl
void combinedColor_float(float4 hitPosition1, float3 color1, float4 hitPosition2, float3 color2, out float3 color)
{
    if (hitPosition1.w > _raymarchStoppingCriterium && hitPosition2.w > _raymarchStoppingCriterium)
        color = float3(0, 0, 0);
    else if (hitPosition1.w < hitPosition2.w)
        color = color1;
    else
        color = color2;
}
```

The edgecase that for a fragment both inputs did not yield a hit, is checked for first. In that case, the color is set to black. Thus, removing any effects lighting might have on those fragments.

---

## The Parameters

### Inputs:
- ```float4 hitPosition1```: The hit position of the first input where the first three dimensions define the point in space and the w-component contains the raymarching parameter at which the hit occured
- ```float3 color1```: The color of the first input
- ```float4 hitPosition2```: The hit position of the second input where the first three dimensions define the point in space and the w-component contains the raymarching parameter at which the hit occured
- ```float3 color2```: The color of the second input

### Outputs:
- ```float3 color```: The combined color of both inputs based on which hit is closer to the camera

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/Basics/Combine Color`

    ![Unity Translate Camera](images/translateCamera.png){ width="500" }

=== "Standard Scripting"
    Include ...

---

This is an engine-specific implementation without a shader-basis.