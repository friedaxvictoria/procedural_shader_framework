<div class="container">
    <h1 class="main-heading">Helper Functions</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This sections gives an overview of the universal helper functions used across Unity's integration. Within the ShaderGraph implementation they are not exposed and solely used to implement the custom nodes. However, if the standard scripting with ShaderLab is used, they can be accessed and used for custom computations.

---

## The Code - Camera Matrix

``` hlsl
float3x3 computeCameraMatrix(float3 lookAtPosition, float3 eye, float3x3 mat)
{
    float3 forward = normalize(lookAtPosition - eye);
    float3 right = normalize(cross(forward, mul(float3(0, 1, 0), mat))); 
    float3 up = cross(right, forward);
    return float3x3(right, up, -forward); 
}
```

---

## The Parameters - Camera Matrix

### Inputs:
| Name | Type     | Description |
|-----------------------|----------|-------------|
| `lookAtPosition` <img width=50/>| float3   | Focal point of the camera |
| `eye`        | float3   | Position of the camera - It is generally recommended to use the global variable **_rayOrigin** for this computations |
| `mat`            | float3x3   | Transformation matrix |

### Outputs:
| Type     | Description |
|----------|-------------|
| float3x3   | Camera matrix |

---

## The Code - Rotation Matrix

``` hlsl
float3x3 computeRotationMatrix(float3 axis, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    float minusC = 1 - c;
    
    return float3x3(c + axis.x * axis.x * minusC, axis.x * axis.y * minusC - axis.z * s, axis.x * axis.z * minusC + axis.y * s,
    axis.y * axis.x * minusC + axis.z * s, c + axis.y * axis.y * minusC, axis.y * axis.z * minusC - axis.x * s,
    axis.z * axis.x * minusC - axis.y * s, axis.z * axis.y * minusC + axis.x * s, c + axis.z * axis.z * minusC);
}
```

---

## The Parameters - Rotation Matrix

### Inputs:
| Name | Type     | Description |
|-----------------------|----------|-------------|
| `axis`  | float3   | Axis around which to rotate |
| `angle`        | float3   | Angle at which to rotate |

### Outputs:
| Type     | Description |
|----------|-------------|
| float3x3   | Rotation matrix |

---

## Access

!Utku Input

If standard scripting is used, the helper functions can be included and used with: 
```
#include ...
```

