<div class="container">
    <h1 class="main-heading">SDF Raymarching</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

This function performs raymarching considering all previously instantiated SDFs.

For further information of the implementations of SDFs in Unity refer to [General Information](generalInformation.md).

---

## The Code

``` hlsl
float evalSDF(int index, float3 position)
{
    int sdfType = _sdfType[index];
    float3 probePt = mul((position - _sdfPosition[index]), _sdfRotation[index]);
    
    if (sdfType == 0)
        return sdSphere(probePt, _sdfRadius[index]);
    else if (sdfType == 1)
        return sdRoundBox(probePt, _sdfSize[index], _sdfRadius[index]);
    else if (sdfType == 2)
        return sdTorus(probePt, _sdfSize[index].yz);
    else if (sdfType == 3)
        return sdEllipsoid(probePt, _sdfSize[index]);
    else if (sdfType == 4)
        return sdHexPrism(probePt, _sdfRadius[index]);
    else if (sdfType == 5)
        return sdOctahedron(probePt, _sdfRadius[index]);
    else if (sdfType == 6)
        return dolphinDistance(probePt, _sdfPosition[index], _timeOffsetDolphin[index], _speedDolphin[index]).x;
    return 1e5;
}

void raymarch_float(float condition, float3x3 cameraMatrix, float numberSDFs, float2 fragmentCoordinates, out float4 hitPosition, out float3 normal, out int hitIndex, out float3 rayDirection)
{
    if (condition == 0)
    {
        cameraMatrix = computeCameraMatrix(float3(0, 0, 0), _rayOrigin, float3x3(1, 0, 0, 0, 1, 0, 0, 0, 1));
    }
    
    rayDirection = normalize(mul(float3(fragmentCoordinates, -1), cameraMatrix));
    float t = 0.0;
    hitPosition = float4(0, 0, 0, 0);
    for (int i = 0; i < 100; i++)
    {
        float3 currentPosition = _rayOrigin + rayDirection * t; 
        float d = 1e5;
        int bestIndex = -1;
        for (int j = 0; j < numberSDFs; ++j)
        {
            float dj = evalSDF(j, currentPosition);
            if (dj < d)
            {
                d = dj; 
                bestIndex = j;
            }
        }
        hitIndex = bestIndex;
        d += _sdfNoise[hitIndex] * 0.3;
        if (d < 0.001)
        {
            hitPosition.xyz = currentPosition;
            normal = getNormal(hitIndex, currentPosition);
            break;
        }
        if (t > _raymarchStoppingCriterium)
        {
            hitPosition.xyz = currentPosition;
            break;
        }
        t += d;
    }
    hitPosition.w = t;
}
```

---

## The Parameters

float condition, float3x3 cameraMatrix, float numberSDFs, float2 fragmentCoordinates, out float4 hitPosition, out float3 normal, out int hitIndex, out float3 rayDirection

### Inputs:
- ```float condition```: A value that is used to check whether the default camera matrix should be computed or a custom camera matrix has been put in.
    - condition = 0: The default camera matrix should be computed
    - condition = 1: A custom camera matrix has been added
- ```float3x3 cameraMatrix```: The camera matrix
> Can be aquired using [Camera Matrix](../camera/cameraMatrix.md)
- ```float numberSDFs```: The amount of SDFs that are in the scene
> Should be aquired as the output of the SDF which is instanciated last.
- ```float2 fragCoordinates```: The fragment's coordinates
> Can be aquired using [Fragment Coordinates](unity/cameraMatrix.md)

### Outputs:
- ```float4 hitPosition```: The first three dimensions contain the position at which the water has been hit. The w-component contains the raymarching parameter at which the hit occured. This is required in order to be able to combine the water with other visual elements.
- ```float3 normal```: The normal at the hit position
- ```float hitIndex```: A value determining what surface has been hit. The water gets a hard-coded hitIndex.
- ```float3 rayDirection```: The ray direction from the camera to the hit position

---

## Implementation

=== "Visual Scripting"
    Find the node at `PSF/SDFs/Raymarching`

    ![Unity Mouse-Based Camera Rotation](){ width="300" }

    >Due to internal workings of the node, the condition-input is not required. Within the SubGraph a *Branch On Input Connection* node is used to determine whether a camera matrix was connected to its respective input. This in turn determines the condition-value.

    ![Unity Move Camera With Mouse](images/mouseMovementCamera.png){ width="500" }

=== "Standard Scripting"
    Include ...

---

Find the original shader code [here](..).