# SDF Ellipsoid

This function creates an internal instance of an SDF-based ellipsoid. In order for the cube to be visible in the final output, [SDF Raymarching](...) and an arbitrary lighting function has to be included. 

For further information of the implementations of SDFs in Unity refer to [General Information](generalInformation.md).

---

## The Code

``` hlsl
void addSDF(float index, float type, float3 position, float3 size, float radius, float3 axis, float angle, float noise, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float timeOffset, float speed){
    for (int i = 0; i <= MAX_OBJECTS; i++)
    {
        if (i == index)
        {
            _sdfType[i] = type;
            _sdfPosition[i] = position;
            _sdfSize[i] = size;
            _sdfRadius[i] = radius;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noise;
            
            _objectBaseColor[i] = baseColor;
            _objectSpecularColor[i] = specularColor;
            _objectSpecularStrength[i] = specularStrength;
            _objectShininess[i] = shininess;

            _timeOffsetDolphin[i] = timeOffset;
            _speedDolphin[i] = speed;
            break;
        }
    }
}

float sdEllipsoid(float3 position, float3 r)
{
    float k0 = length(position / r);
    float k1 = length(position / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

void addEllipsoid_float(int index, float3 position, float3 size, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out int indexOut)
{
    addSDF(index, 3, position, size, 0, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}
```

---

## The Parameters

### Inputs:
- ```float index```: The index at which the ellipsoid is stored 
- ```float3 position```: The central position of the ellipsoid
- ```float3 size```: The size of the ellipsoid definable in each direction
> *ShaderGraph default value*: ```float3(1,1,1)```
- ```float3 axis```: The axis determining the orientation of the ellipsoid
> *ShaderGraph default value*: ```float3(0,1,0)```
- ```float angle```: The angle around the axis 
- Material parameters
    - ```float3 baseColor```: The underlying color of the ellipsoid
    > *ShaderGraph default value*: ```float3(0,1,0)```
    - ```float3 specularColor```: The color of the highlights
    - ```float3 specularStrength```: The intensity with which highlights are created
    > *ShaderGraph default value*: ```1```
    - ```float3 shininess```: The shape and sharpness of the highlights; the larger the value, the more focussed the highlight
    > *ShaderGraph default value*: ```32```
- ```float3 noise```: Noise that is added to the shape of the ellipsoid

> Naturally, the sphere can be imitated by the ellipsoid by setting its size to be uniform.


### Outputs:
- ```float indexOut```: The incremented input index that can be used as either the input index to another SDF function or as the amount of SDFs in the scene to the [SDF Raymarching](...).  

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/SDFs/Ellipsoid`

    ![Unity Mouse-Based Camera Rotation](){ width="300" }

=== "Standard Scripting"
    Include ...

---

This is an engine-specific implementation without a shader-basis.