# Global Variables

The global variables are an essential part of the integration in Unity. They are defined in a separate file and included in all hlsl-files that require them. They can easily distinguished by their signature underscore **_variableName**.

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
float _sdfType[MAX_OBJECTS];
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