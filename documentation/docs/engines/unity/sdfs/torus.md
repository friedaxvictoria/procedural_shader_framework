<div class="container">
    <h1 class="main-heading">SDF Torus</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This function creates an internal instance of an SDF-based torus. In order for the cube to be visible in the final output, [SDF Raymarching](...) and an arbitrary lighting function has to be included. 

For further information of the implementations of SDFs in Unity refer to [General Information](generalInformation.md).

---

## The Code

``` hlsl
// radius.x is the major radius, radius.y is the thickness
float sdTorus(float3 position, float2 radius)
{
    float2 q = float2(length(position.xy) - radius.x, position.z);
    return length(q) - radius.y;
}

void addTorus_float(float index, float3 position, float radius, float thickness, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out float indexOut)
{
    addSDF(index, 2, position, float3(0, radius, thickness), 0, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}
```

---

## The Parameters

### Inputs:
- ```float index```: The index at which the torus is stored 
- ```float3 position```: The central position of the torus
- ```float radius```: The radius of the torus from center to the very outside of the tube
> *ShaderGraph default value*: ```3```
- ```float thickness```: The thickness of the torus' tube
> *ShaderGraph default value*: ```1```
- ```float3 axis```: The axis determining the orientation of the torus
> *ShaderGraph default value*: ```float3(0,1,0)```
- ```float angle```: The angle around the axis 
- Material parameters
    - ```float3 baseColor```: The underlying color of the torus
    > *ShaderGraph default value*: ```float3(0,1,0)```
    - ```float3 specularColor```: The color of the highlights
    - ```float3 specularStrength```: The intensity with which highlights are created
    > *ShaderGraph default value*: ```1```
    - ```float3 shininess```: The shape and sharpness of the highlights; the larger the value, the more focussed the highlight
    > *ShaderGraph default value*: ```32```
- ```float3 noise```: Noise that is added to the shape of the torus


### Outputs:
- ```float indexOut```: The incremented input index that can be used as either the input index to another SDF function or as the amount of SDFs in the scene to the [SDF Raymarching](...).  

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/SDFs/Torus`

    ![Unity Mouse-Based Camera Rotation](){ width="300" }

=== "Standard Scripting"
    Include ...

---

Find the original shader code [here](..).