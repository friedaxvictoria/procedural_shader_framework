# Mouse-Based Camera Movement

This function imitates a camera movements. With a left mouse-click the world can be rotated in the x- and y-direction. By enabling the exposed boolean *allow movement* in the inspector, the camera position can further be modified using WASDQE. This is enabled by modifying the camera position via the *set_shader_uniforms.cs* file.

---

## The Code

``` 
void moveViaMouse_float(out float3x3 mat)
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

[See Helper Functions](unity/cameraRotation.md) to find out more about ```computeRotationMatrix(float3 axis, float angle)```

---

## The Parameters

### Inputs:
- None

### Outputs:
- ```float3x3 mat```: The final camera matrix that can be plugged into the [Water Shader](unity/cameraMatrix.md) or the [SDF Raymarching](unity/cameraMatrix.md). 
    - Contrary to other animation functions, this function does not need to be finished off with a computation of the [Camera Matrix](cameraMatrix.md). 

---

## Experience

- Rotations via clicking the left mouse-button
    - Drag left and right for a rotation around the y-axis.
    - Drag up and down for a rotation around the x-axis.
- Translations via WASDQE
    - W: Forward Movement
    - A: Left Movement
    - S: Backward Movement
    - D: Right Movement
    - Q: Upward Movement
    - E: Downward Movement
    - Press *Shift* for an increased speed. The speed can further be adjusted in the inspector.

---

## Implementation

=== "Shader Graph"
    Find the node at PSF/Camera/Mouse-Based Movement

    ![Unity Move Camera With Mouse](images/mouseMovementCamera.png){ width="500" }

=== "Standard Scripting"
    Include ...

---

This is an engine-specific implementation without a shader-basis.