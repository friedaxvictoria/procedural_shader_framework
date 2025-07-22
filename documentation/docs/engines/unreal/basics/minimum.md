<div class="container">
    <h1 class="main-heading">Minimum</h1>
    <blockquote class="author">by Maximilian Lipski</blockquote>
</div>

This function outputs the hit-position, normal, and hit-index out of two sets of inputs based on which hit-position is closer to the camera. It is used **before** all the lighting functions are applied. 

Therefore, it can be used to combine outputs of raymarching functions. The subsequent lighting functions are then applied to the output of this function. Other than [Combine Color](combineColor.md), the [Sunrise](../lighting/sunriseLight.md) and [Point Light](../lighting/pointLight.md) functions have effects.

---

## The Code

``` hlsl
void getMinimum(float4 hitPosition0, float3 normal0, MaterialParams material0, float4 hitPosition1, float3 normal1, MaterialParams material1, out float4 hitPos, out float3 normal, out MaterialParams material)
{
    if (hitPosition0.w < hitPosition1.w && hitPosition0.w < _raymarchStoppingCriterium)
    {
        hitPos = hitPosition0;
        normal = normal0;
        material = material0;
        
    }
    else
    {
        hitPos = hitPosition1;
        normal = normal1;
        material = material1;
    }
}
```

---

## The Parameters

### Inputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `hitPosition0`  <img width=50/>  | float4   | Hit-position of the first input where the first three dimensions define the point in space and the w-component contains the raymarching parameter at which the hit occured|
| `normal0`        | float3   | Normal of the first input|
| `material0`        | float   | Material of the first input|
| `hitPosition1`   | float4   | Hit-position of the second input where the first three dimensions define the point in space and the w-component contains the raymarching parameter at which the hit occured|
| `normal1`        | float3   | Normal of the second input|
| `material1`        | float   | Material of the second input|

### Outputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `hitPosition`  <img width=50/>  | float4   | Hit-position that is the closest to the camera out of the two sets of inputs|
| `normal`        | float3   | Normal corresponding to the closest hit-position|
| `material`        | float3   | Material corresponding to the closest hit-position|

The outputs can be used for further computations using lighting functions (e.g. [Sunrise](../lighting/sunriseLight.md)).

---

## Implementation

=== "Visual Scripting"
    Find the node at `ProceduralShaderFramework/Utils/Minimum`

    <figure markdown="span">
        ![Unity Minimum](../images/basics/minimum.png){ width="500" }
    </figure>

=== "Standard Scripting"
    Include - ```#include "/ProceduralShaderFramework/util_functions.ush"```

---

This is an engine-specific implementation without a shader-basis.