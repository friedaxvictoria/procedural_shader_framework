# Cycle Color

This function applies a colour animation to an arbitrary input colour. It cycles through colours based on a sinus computation.

---

## The Code

``` hlsl
void changingColorSin_float(float3 seedColor, float speed, out float3 color)
{
    float3 rootColor = asin(2 * seedColor - 1);
    color = 0.5 + 0.5 * sin(_Time.y * speed * rootColor);
}
```

The computation of the root color is required to ensure that the seed color within the cycle of colors. It is computed by solving for x when _Time.y = 0:

```seedColor = 0.5 + 0.5 * sin(_Time.y * speed * x)```

---

## The Parameters

### Inputs:
- ```float3 seedColor```: The initial color of the object
- ```float3 speed```: The speed with which the color is changed
> *ShaderGraph default value*: 1

### Outputs:
- ```float3 color```: The current color of the object which can directly be plugged into the inputs of SDF functions (e.g. [Sphere](unity/cameraMatrix.md)) or lighting functions (e.g. [Point Light](unity/cameraMatrix.md)).

> To create organic and interesting effects, the function can also be applied to position parameters. See the tutorial on the [Safety Buoy](unity/cameraMatrix.md) for this.

---

## Implementation

=== "Visual Scripting"
    Find the node at PSF/Animation/Cycle Color Sin

    ![Unity Translate Camera](images/translateCamera.png){ width="500" }

=== "Standard Scripting"
    Include ...

---

This is an engine-specific implementation without a shader-basis. It is inspired by this [shadertoy shader](https://www.shadertoy.com/view/fl3fRf){target="_blank"}.