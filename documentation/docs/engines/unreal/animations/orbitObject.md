<div class="container">
    <h1 class="main-heading">Orbit Object Around Point</h1>
    <blockquote class="author">by Maximilian Lipski</blockquote>
</div>

This function rotates an object around a point. It can be applied to SDFs and lights.

---

## The Code

``` hlsl
void orbitObjectAroundPoint(float3 seedPosition, float3 center, float3 axis, float radius, float speed, float angleOffset, float time, out float3 position, out float angle)
{
    axis = normalize(axis);
    angle = time * speed + angleOffset * PI / 180;
        
    float3 radiusAxis = (float3(1, 1, 1) - axis) * radius;
    
    float3 p = seedPosition + radiusAxis - center;
    position = center + cos(angle) * p + sin(angle) * cross(axis, p) + (1 - cos(angle)) * dot(axis, p) * axis;
    
    angle = angle * 180 / PI;
}
```

---

## The Parameters

### Inputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `seedPosition`  <img width=50/>  | float3   | Initial position of the object|
| `centre`        | float3   | Central position around which the object obits |
| `axis`   | float3   | Axis around which the object rotates <br> <blockquote>*ShaderGraph default value*: float3(0,1,0)</blockquote>|
| `radius`   | float   | Distance at which the object rotates around the centre point|
| `speed`   | float   | Speed with which the rotation is applied <br> <blockquote>*ShaderGraph default value*: 1</blockquote>|
| `angleOffset`   | float   | =ptional offset to the rotation defined in degrees. This allows objects to use the same rotation at different starting positions.|
| `time`        | float   | Time the application is running |

> By setting the radius to 0, a self-rotation of the object can be achieved.

### Outputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `position`   | float3   | Current position of the object |
| `angle`        | float   | Angle defining the self-rotation of the object |

The outputs can directly be plugged into the inputs of SDF functions (e.g. [Sphere](../sdfs/sphere.md)) or lighting functions (e.g. [Point Light](../lighting/pointLight.md)). As lighting functions are not susceptible to changes of the angle, it only requires the **position** as input.

---

## Implementation

=== "Visual Scripting"
    Find the node at `ProceduralShaderFramework/Animation/OrbitObjectAroundPoint`

    <figure markdown="span">
        ![Unity Orbit Object](../images/animations/orbitObject.png){ width="500" }
    </figure>

=== "Standard Scripting"
    Include - ```#include "/ProceduralShaderFramework/animation_functions.ush"```

---

Find the original shader code [here](../../../shaders/animation/sdf_animation_shader.md). Changes and simplifications where made to combine the *Orbit Animation* and *Self-Rotate Animation*. The option of different time modes was removed for simplicity reasons.