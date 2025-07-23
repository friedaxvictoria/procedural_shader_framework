<div class="container">
    <h1 class="main-heading">Shake Object</h1>
    <blockquote class="author">by Maximilian Lipski</blockquote>
</div>

This function creates a linear shaking animation on objects by changing its position. It can be applied to SDFs and lights.

---

## The Code

``` hlsl
void shakeObject(float3 seedPosition, float intensity, float speed, float time, out float3 position)
{
    float t = time * speed;

    float x = hash11(t + 1.1) - 0.5;
    float y = hash11(t + 2.3) - 0.5;
    float z = hash11(t + 3.7) - 0.5;

    float3 jitter = float3(x, y, z) * intensity;

    position = seedPosition + jitter;
}
```

---

## The Parameters

### Inputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `seedPosition`   | float3   | Initial position of the object |
| `intensity`        | float   | Intensity of the shaking <br> <blockquote>*ShaderGraph default value*: 1</blockquote> |
| `speed`        | float   | Speed with which the position change is applied <br> <blockquote>*ShaderGraph default value*: 1</blockquote> |
| `time`        | float   | Time the application is running |

> Play around by adding [Tweening](tweening.md) to intensity and speed to create a more intricate animation.

### Outputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `position`   | float3   |  Current position of the object which can directly be plugged into the inputs of an SDF function (e.g. [Sphere](../sdfs/sphere.md)) or lighting functions (e.g. [Point Light](../lighting/pointLight.md)). |

---

## Implementation

=== "Visual Scripting"
    Find the node at `ProceduralShaderFramework/Animation/ShakeObject`

    <figure markdown="span">
        ![Unity Shake Object](../images/animations/shakeObject.png){ width="500" }
    </figure>

=== "Standard Scripting"
    Include - ```#include "/ProceduralShaderFramework/animation_functions.ush"```

---

This is an engine-specific implementation without a shader-basis.