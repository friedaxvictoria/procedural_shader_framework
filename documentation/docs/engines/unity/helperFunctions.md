# Helper Functions

This sections gives an overview of the universal helper functions used across Unity's integration. Within the ShaderGraph implementation they are not accessible and solely used to implement the custom nodes. However, if the standard scripting is used, they can be accessed and used for custom computations.

---

## The Code - Camera Matrix

``` 
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
- ```float3 lookAtPosition```: The focal point of the camera
> *ShaderGraph value*: world origin
- ```float3 eye```: The position of the camera - It is generally recommended to use the global variable **_rayOrigin** for this computations. 
> *ShaderGraph value*: _rayOrigin
- ```float3x3 mat```: A transformation matrix

### Outputs:
- ```float3x3```: The camera matrix 

---

## The Code - Rotation Matrix

``` 
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
- ```float3 axis```: The axis around which to rotate
- ```float3 angle```: The angle at which to rotate
### Outputs:
- ```float3x3```: The rotation matrix 

---

## Access

If standard scripting is used, the helper functions can be included and used with: 
```
#include ...
```

