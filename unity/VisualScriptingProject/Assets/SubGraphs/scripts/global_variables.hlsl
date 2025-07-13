#ifndef GLOBAL_VARIABLES
#define GLOBAL_VARIABLES

//uniforms
extern float2 _mousePoint;
extern float3 _rayOrigin;
extern float _raymarchStoppingCriterium;

//sdf arrays
float _sdfType[10];
float3 _sdfPosition[10];
float3 _sdfSize[10];
float _sdfRadius[10];
float3x3 _sdfRotation[10];
float _sdfNoise[10];

//material array --> number of sdfs + 1 for water shader
float3 _baseColor[11];
float3 _specularColor[11];
float _specularStrength[11];
float _shininess[11];

//dolphin specific arrays
float _timeOffsetDolphin[10];
float _speedDolphin[10];
#endif