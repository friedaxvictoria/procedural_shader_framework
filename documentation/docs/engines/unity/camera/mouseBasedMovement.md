<div class="container">
    <h1 class="main-heading">Mouse-Based Camera Rotation</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This function imitates a camera rotation based on the mouse position. With a left mouse-click the world can be rotated in the x- and y-direction. 

> In contrast to the other camera animations, this mouse-based rotation should not be connected to the [Camera Matrix](cameraMatrix.md). The usage of *lookAtPosition* would break the usability of this function.

---

## The Code

``` hlsl
void rotateViaMouse_float(out float3x3 mat)
{
    float2 mouse = _mousePoint.xy / _ScreenParams.xy;

    // Center mouse to [-0.5, +0.5]
    mouse = mouse - 0.5;

    // Convert to yaw and pitch
    // == PI * mouse.x when centered
    float yaw = lerp(-PI, PI, mouse.x + 0.5); 
    // Invert Y axis
    float pitch = lerp(-PI / 2, PI / 2, -mouse.y + 0.5); 

    float3x3 rotY = computeRotationMatrix(float3(0, 1, 0), yaw);
    float3x3 rotX = computeRotationMatrix(float3(1, 0, 0), pitch);

    mat = mul(rotY, rotX);
}
```

See [Helper Functions](../helperFunctions.md) to find out more about ```computeRotationMatrix(float3 axis, float angle)```

---

## The Parameters

### Inputs:
None

### Outputs:
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `mat`        | float3x3   | Final camera matrix that can be plugged into the [Water Shader](../water/waterSurface.md) or the [SDF Raymarching](../sdfs/raymarching.md) |

---

## Experience

- Rotations via clicking the left mouse-button
    - Drag left and right for a rotation around the y-axis.
    - Drag up and down for a rotation around the x-axis.

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/Camera/Rotate Via Mouse`

    <figure markdown="span">
        ![Unity Mouse-Based Camera Rotation](../images/camera/rotateViaMouse.png){ width="300" }
    </figure>

=== "Standard Scripting"
    Include - ```#include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/animation_functions.hlsl"```

    Example Usage

    ```hlsl
    float3x3 camMat;
    rotateViaMouse_float(camMat);
    ```

---

This is an engine-specific implementation without a shader-basis.