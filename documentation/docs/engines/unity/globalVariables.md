<div class="container">
    <h1 class="main-heading">Global Variables</h1>
    <blockquote class="author">by Frieda Hentschel</blockquote>
</div>

The global variables are an essential part of the integration in Unity. They are defined in a separate file and included in all hlsl-files that require them. They can easily distinguished by their signature underscore **_variableName**.

The global variables define the maximum amount of SDFs that can be added to a single shader to be **20**. Read more about this setup in the [SDF General Information](sdfs/generalInformation.md). 

Additionally, the hit-index for the water surface is defined to be the first available index after the SDF indices. More environments can be added by incrementing the water's index for each added environment and increasing the material array's size by the amount of added environments. Read more about the importance of the hit-indices in [Lighting General Information](lighting/generalInformation.md).

---

## The Code

``` hlsl
#define MAX_OBJECTS 20
//water index is the first value possible after the object indices
#define WATER_INDEX 20

//uniforms
extern float2 _mousePoint;
extern float3 _rayOrigin;
extern float _raymarchStoppingCriterium;

//sdf arrays
int _sdfType[MAX_OBJECTS];
float3 _sdfPosition[MAX_OBJECTS];
float3 _sdfSize[MAX_OBJECTS];
float _sdfRadius[MAX_OBJECTS];
float3x3 _sdfRotation[MAX_OBJECTS];
float _sdfNoise[MAX_OBJECTS];

//material array --> number of sdfs + 1 for water shader
float3 _objectBaseColor[MAX_OBJECTS+1];
float3 _objectSpecularColor[MAX_OBJECTS+1];
float _objectSpecularStrength[MAX_OBJECTS+1];
float _objectShininess[MAX_OBJECTS+1];

//dolphin specific arrays
float _timeOffsetDolphin[MAX_OBJECTS];
float _speedDolphin[MAX_OBJECTS];
```