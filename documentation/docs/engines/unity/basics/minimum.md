# Minimum

This function outputs the hit position, normal, and hit index out of two sets of inputs based on which hit position is closer to the camera. It is used **before** all the lighting functions are applied. 

Therefore, it can be used to combine outputs of raymarching functions. The subsequent lighting functions are then applied to the output of this function. Other than [Combine Color](combineColor.md), the [Sunrise](...) and [Point Light](...) functions have effects.

---

## The Code

``` hlsl
void getMinimum_float(float4 hitPosition1, float3 normal1, float hitIndex1, float4 hitPosition2, float3 normal2, float hitIndex2, out float4 hitPosition, out float3 normal, out float hitIndex)
{
    if (hitPosition1.w < hitPosition2.w && hitPosition1.w < _raymarchStoppingCriterium)
    {
        hitPosition = hitPosition1;
        normal = normal1;
        hitIndex = hitIndex1;
    }
    else
    {
        hitPosition = hitPosition2;
        normal = normal2;
        hitIndex = hitIndex2;
    }
}
```

---

## The Parameters

### Inputs:
- ```float4 hitPosition1```: The hit position of the first input where the first three dimensions define the point in space and the w-component contains the raymarching parameter at which the hit occured
- ```float3 normal1```: The normal of the first input
- ```float hitIndex1```: The index of the first input 
- ```float4 hitPosition2```: The hit position of the second input where the first three dimensions define the point in space and the w-component contains the raymarching parameter at which the hit occured
- ```float3 normal2```: The normal of the second input
- ```float hitIndex2```: The index of the second input 

### Outputs:
- ```float4 hitPosition```: The hit position that is the closest to the camera out of the two sets of inputs
- ```float3 normal```: The normal corresponding to the closest hit position
- ```float hitIndex```: The index corresponding to the closest hit position

The outputs can be used for further computations using lighting functions (e.g. [Sunrise Lighting](../lighting/sunriseLight.md)).

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/Basics/Minimum`

    ![Unity Translate Camera](images/translateCamera.png){ width="500" }

=== "Standard Scripting"
    Include ...

---

This is an engine-specific implementation without a shader-basis.