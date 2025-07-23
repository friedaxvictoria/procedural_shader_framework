<div class="container">
    <h1 class="main-heading">SDF Hexprism</h1>
    <blockquote class="author">by Runtong Li</blockquote>
</div>

This function creates an internal instance of an SDF-based Hexprism. In order for the object to be visible in the final output, [RaymarchAll](raymarchAll.md) and an arbitrary Lighting Function have to be included.

---

## The Code

``` hlsl
float sdHexPrism(float3 p, float2 height)
{
    const float3 k = float3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0 * min(dot(k.xy, p.xy), 0.0) * k.xy;
    float2 d = float2(
       length(p.xy - float2(clamp(p.x, -k.z * height.x, k.z * height.x), height.x)) * sign(p.y - height.x),
       p.z - height.y);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

void addHexPrism(inout int index, float3 position, float height, float3 axis, float angle, MaterialParams material)
{
    SDF newSDF;
    newSDF.type = 3;
    newSDF.position = position;
    newSDF.radius = height;
    newSDF.size = float3(0.0, 0.0, 0.0);
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
| `height`        | float   | Height of this object | 
| `axis`        | float3   | The axis determining the orientation of the object <br> <blockquote> *Visual Scripting default value*: float3(0, 0, 1) </blockquote> |
| `angle`        | float   | The angle around the axis |
| `material` | MaterialParams | The material which the SDF is rendered with |
    
### Outputs:
- ```int index```: The incremented input index that can be used as either the input index to another SDF function or as the amount of SDFs in the scene to the [RaymarchAll](raymarchAll.md).  

---

## Implementation

=== "Visual Scripting"
    Find the node at `ProceduralShaderFramework/SDFs/AddHexPrism`
    <figure markdown="span">
        ![Unreal hexprism](../images/sdfs/Hexprism.png){ width="300" }
    </figure>

=== "Standard Scripting"
    Include - ```#include "ProceduralShaderFramework/Shaders/sdf_functions.ush"```

    Example Usage
    ```hlsl
    addHexPrism(index, Position, Height, axis, angle, mat);
    ```

---

This is an engine-specific implementation without a shader-basis.