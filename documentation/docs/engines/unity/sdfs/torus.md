<div class="container">
    <h1 class="main-heading">SDF Torus</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This function creates an internal instance of an SDF-based torus. In order for the cube to be visible in the final output, [SDF Raymarching](raymarching.md) and an arbitrary [Lighting Function](../lighting/generalInformation.md) have to be included. 

---

## The Code

``` hlsl
// radius.x is the major radius, radius.y is the thickness
float sdTorus(float3 position, float2 radius)
{
    float2 q = float2(length(position.xy) - radius.x, position.z);
    return length(q) - radius.y;
}

void addTorus_float(int index, float3 position, float radius, float thickness, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out int indexOut)
{
    addSDF(index, 2, position, float3(0, radius, thickness), 0, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}
```

---

## The Parameters  

### Inputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `index`  <img width=50/>  | int   | Index at which the torus is stored  |
| `position`        | float3   | Central position |
| `radius`        | float   | Radius of the torus from center to the middle of the tube <br> <blockquote>*ShaderGraph default value*: 3</blockquote>|
| `thickness`        | float   | Thickness of the torus' tube <br> <blockquote>*ShaderGraph default value*: 1</blockquote>|
| `axis`            | float3   | Axis determining the orientation <br> <blockquote>*ShaderGraph default value*: float3(0,1,0)</blockquote>|
| `angle` | float   | World-space position of the light source |
| `baseColor`  | float3   | Underlying color <br> <blockquote>*ShaderGraph default value*: float3(1,0,0)</blockquote>|
| `specularColor`        | float3   | Color of the highlights |
| `specularStrength`            | float   | Intensity with which highlights are created between 0 and 1 <br> <blockquote>*ShaderGraph default value*: 1</blockquote> |
| `shininess` | float   | Shape and sharpness of the highlights; the larger the value, the more focussed the highlight  <br> <blockquote>*ShaderGraph default value*: 32</blockquote>|
| `noise` | float   | Noise that is added to the shape of the torus |

### Outputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `indexOut`  | int   | Incremented input index that can be used as either the input index to another SDF function or as the amount of SDFs in the scene to the [SDF Raymarching](raymarching.md) |

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/SDFs/Torus`

    <figure markdown="span">
        ![Unity Torus](../images/sdfs/torus.png){ width="500" }
    </figure>

=== "Standard Scripting"

    Include - ```#include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/sdf_functions.hlsl"```

    Example Usage

    ```hlsl
    addTorus_float(index, float3(0,4.5,0), 2, 0.2, float3(0.8,0.1,0.1), 45, float3(0.2,0.5,0.2), float3(0.8,0.1,0.1), 2, 1, 0, index);
    ```


---

Find the original shader code [here](../../../shaders/geometry/Geometry_SDFs.md).