<div class="container">
    <h1 class="main-heading">SDF Ellipsoid</h1>
    <blockquote class="author">by Runtong Li</blockquote>
</div>

This function creates an internal instance of an SDF-based Ellipsoid. In order for the object to be visible in the final output, [RaymarchAll](raymarchAll.md) and an arbitrary Lighting Function have to be included.

---

## The Code

``` hlsl
float sdEllipsoid(float3 p, float3 r)
{
    float k0 = length(p / r);
    float k1 = length(p / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

void addEllipsoid(inout int index, float3 position, float3 radius, float3 axis, float angle, MaterialParams material)
{
    SDF newSDF;
    newSDF.type = 5;
    newSDF.position = position;
    newSDF.radius = 0.0;
    newSDF.size = radius;
    newSDF.rotation = computeRotationMatrix(normalize(axis), angle * PI / 180);
    newSDF.material = material;
    
    addSDF(index, newSDF);
}
```

---

## The Parameters

### Inputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `index`        | int   | The index at which this object is stored <br> <blockquote> *Visual Scripting default value*: 1 </blockquote>|
| `position`        | float3   | The central position of this object |
| `radius`        | float   | The radius of this object | 
| `axis`        | float3   | The axis determining the orientation of the object <br> <blockquote> *Visual Scripting default value*: float3(0, 0, 1) </blockquote> |
| `angle`        | float   | The angle around the axis <br> <blockquote> *Visual Scripting default value*: 0 </blockquote>|
| `material` | MaterialParams | The material which the SDF is rendered with |
    
### Outputs:
- ```int index```: The incremented input index that can be used as either the input index to another SDF function or as the amount of SDFs in the scene to the [RaymarchAll](raymarchAll.md).  

---

## Implementation

=== "Visual Scripting"
    Find the node at `ProceduralShaderFramework/SDFs/AddElipsoid`
    <figure markdown="span">
    ![Unreal ellipsoid](../images/sdfs/ellipsoid.png){ width="300" }
    </figure>

=== "Standard Scripting"
    Include - ```#include "ProceduralShaderFramework/Shaders/sdf_functions.ush"```

    Example Usage
    ```hlsl
    addEllipsoid(index, Position, Height, axis, angle, mat);
    ```
---

This is an engine-specific implementation without a shader-basis.