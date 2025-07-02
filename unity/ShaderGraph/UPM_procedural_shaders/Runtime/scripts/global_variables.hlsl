#ifndef GLOBAL_VARIABLES
#define GLOBAL_VARIABLES

#define IDENTITY_MATRIX (1, 0, 0, 0, 1, 0, 0, 0, 1)

//uniforms
extern int _NoiseType = 0;
extern float2 _mousePoint;
float3 _rayOrigin;
extern float _GammaCorrect;

float hitID;

//floating point global variables
float _sdfTypeFloat[10];
float3 _sdfPositionFloat[10];
float3 _sdfSizeFloat[10];
float _sdfRadiusFloat[10];
float3x3 _sdfRotation[10];

float3 _baseColorFloat[10];
float3 _specularColorFloat[10];
float _specularStrengthFloat[10];
float _shininessFloat[10];

//dolphin stuff
float _timeOffsetDolphinFloat[10];
float _speedDolphinFloat[10];
float3 _directionDolphinFloat[10];

#endif