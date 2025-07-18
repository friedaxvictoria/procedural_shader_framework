# Tweening Shader Library

This header provides a easing (tweening) functions to interpolate values smoothly over time. The library supports 31 tweening types commonly used in animation curves (e.g., ease-in, ease-out, bounce, back, etc.).

---

## The Code
``` hlsl
void tween3D_float(float3 start, float3 end, float duration, int tweenType, float startTime, bool pingpong, out float3 position)
{
    float t = getTweenProgress(startTime, duration, pingpong);

    float eased = applyTweenFunction(t, tweenType);
    position = lerp(start, end, eased);
}

void tween1D_float(float start, float end, float duration, int tweenType, float startTime, bool pingpong, out float scale)
{
    float t = getTweenProgress(startTime, duration, pingpong);

    float eased = applyTweenFunction(t, tweenType);
    scale = lerp(start, end, eased);
}
```

#### **Parameters**
| Name         | Type   | Description |
|--------------|--------|-------------|
| `start`  | float3/float  | Starting value |
| `end`   | float3/float  | Target value |
| `duration` | float  | Duration of the tween in seconds |
| `tweenType`   | enum/int  | Easing type (see Tween Types below) |
| `startTime`  | float    | Time the tween should start (in seconds) |
| `pingpong`   | bool   | If true, animates back and forth (0→1→0...), else loops from 0→1 repeatedly |

#### **Output**
- ```float3 position / float scale``` — The interpolated value at current time.




## Tween Types

Use one of the following constants as `tweenType` in the functions above:

| Constant Name              | Value |
|---------------------------|-------|
| `TWEEN_LINEAR`            | 0     |
| `TWEEN_QUADRATIC_IN`      | 1     |
| `TWEEN_QUADRATIC_OUT`     | 2     |
| `TWEEN_QUADRATIC_INOUT`   | 3     |
| `TWEEN_CUBIC_IN`          | 4     |
| `TWEEN_CUBIC_OUT`         | 5     |
| `TWEEN_CUBIC_INOUT`       | 6     |
| `TWEEN_QUARTIC_IN`        | 7     |
| `TWEEN_QUARTIC_OUT`       | 8     |
| `TWEEN_QUARTIC_INOUT`     | 9     |
| `TWEEN_QUINTIC_IN`        | 10    |
| `TWEEN_QUINTIC_OUT`       | 11    |
| `TWEEN_QUINTIC_INOUT`     | 12    |
| `TWEEN_SINE_IN`           | 13    |
| `TWEEN_SINE_OUT`          | 14    |
| `TWEEN_SINE_INOUT`        | 15    |
| `TWEEN_CIRCULAR_IN`       | 16    |
| `TWEEN_CIRCULAR_OUT`      | 17    |
| `TWEEN_CIRCULAR_INOUT`    | 18    |
| `TWEEN_EXPONENTIAL_IN`    | 19    |
| `TWEEN_EXPONENTIAL_OUT`   | 20    |
| `TWEEN_EXPONENTIAL_INOUT` | 21    |
| `TWEEN_ELASTIC_IN`        | 22    |
| `TWEEN_ELASTIC_OUT`       | 23    |
| `TWEEN_ELASTIC_INOUT`     | 24    |
| `TWEEN_BACK_IN`           | 25    |
| `TWEEN_BACK_OUT`          | 26    |
| `TWEEN_BACK_INOUT`        | 27    |
| `TWEEN_BOUNCE_IN`         | 28    |
| `TWEEN_BOUNCE_OUT`        | 29    |
| `TWEEN_BOUNCE_INOUT`      | 30    |

---

## Implementation

=== "Visual Scripting"
    Find the node at PSF/Animation/Tweening
    Note: For visual scripting, tween type can be provided by the tween value as an integer.


=== "Standard Scripting"
    Include - #include "Assets/Shaders/Includes/tween_functions.hlsl"
    
    Example Usage

    This function call eases 3D position from (0, 0, 3) to (5, 5, 3) over 5 seconds using a bounce in-out easing, with ping-pong enabled to reverse the motion back and forth, starting at time 0. The position is stored in float3 position.

    ```hlsl
    float3 position;
    tween3D_float(float3(0,0,3), float3(5,5,3), 5.0, TWEEN_BOUNCE_INOUT, 0.0, true, position);
    ```
---

This is an engine-specific implementation without a shader-basis.