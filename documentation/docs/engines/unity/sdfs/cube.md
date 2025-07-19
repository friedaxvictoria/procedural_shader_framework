# SDF Round Box

This function creates an internal instance of an SDF-based cube with rounded corners. In order for the cube to be visible in the final output, [SDF Raymarching](...) and an arbitrary lighting function has to be included. 

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

float sdRoundBox(float3 position, float3 size, float radius)
{
    float3 q = abs(position) - size + radius;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - radius;
}

void addRoundBox_float(float index, float3 position, float3 size, float radius, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out float indexOut)
{
    addSDF(index, 1, position, size, radius, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}
```

---

## The Parameters

### Inputs:
- ```float index```: The index at which the cube is stored 
- ```float3 position```: The central position of the cube
- ```float3 size```: The size of the cube which can be specified for each dimension
> *ShaderGraph default value*: ```float3(1,1,1)```
- ```float3 axis```: The axis determining the orientation of the cube
> *ShaderGraph default value*: ```float3(0,1,0)```
- ```float angle```: The angle around the axis 
- Material parameters
    - ```float3 baseColor```: The underlying color of the cube
    > *ShaderGraph default value*: ```float3(0,1,0)```
    - ```float3 specularColor```: The color of the highlights
    - ```float3 specularStrength```: The intensity with which highlights are created
    > *ShaderGraph default value*: ```1```
    - ```float3 shininess```: The shape and sharpness of the highlights; the larger the value, the more focussed the highlight
    > *ShaderGraph default value*: ```32```
- ```float3 noise```: Noise that is added to the shape of the cube


### Outputs:
- ```float indexOut```: The incremented input index that can be used as either the input index to another SDF function or as the amount of SDFs in the scene to the [SDF Raymarching](...).  

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/SDFs/Cube`

    ![Unity Mouse-Based Camera Rotation](){ width="300" }

=== "Standard Scripting"
    Include ...

---

Find the original shader code [here](..).