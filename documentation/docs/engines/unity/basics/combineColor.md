<div class="container">
    <h1 class="main-heading">Combine Color</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This function can be used to combine the output of different raymarching-based functions. It is used **after** all the lighting functions have been applied to the raymarching. 

> This function has been added for completion's sake but is not recommended. It can only combine hit objects but it **cannot maintain** lighting effects that affect the environment such as the [Sunrise](../lighting/sunriseLight.md) or the [Point Light](../lighting/pointLight.md). For the prefered method to combine results, refer to [Minimum](minimum.md). 

> However, it may be used for experimental shaders that compare the effect of different lighting functions.

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

The edgecase, that for a fragment both inputs did not yield a hit, is checked for first. In such a case, the color is set to black, thus, **removing any effects lighting might have** on those fragments.

---

## The Parameters

### Inputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `hitPosition1`  <img width=50/>  | float4   | Hit position of the first input where the first three dimensions define the point in space and the w-component contains the raymarching parameter at which the hit occured|
| `color1`        | float3   | Color of the first input|
| `hitPosition2`   | float4   | Hit position of the second input where the first three dimensions define the point in space and the w-component contains the raymarching parameter at which the hit occured|
| `color2`        | float3   | Color of the second input|

### Outputs:
| `color`        | float3   | Combined color of both inputs based on which hit is closer to the camera|

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/Basics/Combine Color`

    <figure markdown="span">
        ![Unity Combine Color](../images/basics/combineColor.png){ width="500" }
    </figure>

=== "Standard Scripting"
    Include - ```#include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/basics_functions.hlsl"```

    Example Usage

    ```hlsl
    float3 resultColor;
    combinedColor_float(hitPosition1, color1, hitPosition2, color2, resultColor)
    ```


---

This is an engine-specific implementation without a shader-basis. It was created to allow for the combination of shader-library-code.