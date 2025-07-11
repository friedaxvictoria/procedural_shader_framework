#ifndef GLOBAL_VARIABLES
#define GLOBAL_VARIABLES

#define MAX_NUM_SDFS 10

//uniforms
extern float2 _mousePoint;
float3 _rayOrigin;
extern float _GammaCorrect;

float _raymarchStoppingCriterium = 50;

const static int maxNumSDFs = 10;

//floating point global variables
float _sdfTypeFloat[10];
float3 _sdfPositionFloat[10];
float3 _sdfSizeFloat[10];
float _sdfRadiusFloat[10];
float3x3 _sdfRotation[10];
float _sdfNoise[10];


float3 _baseColorFloat[11];
float3 _specularColorFloat[11];
float _specularStrengthFloat[11];
float _shininessFloat[11];

//dolphin stuff
float _timeOffsetDolphinFloat[10];
float _speedDolphinFloat[10];
#endif