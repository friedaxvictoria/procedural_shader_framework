#ifndef GLOBAL_VARIABLES
#define GLOBAL_VARIABLES

//uniforms
extern int _NoiseType = 0;
extern float2 _mousePoint;
float3 _rayOrigin;
extern float _GammaCorrect;

//half global variables
extern half _sdfTypeHalf[10];
half3 _sdfPositionHalf[10];
half3 _sdfSizeHalf[10];
half _sdfRadiusHalf[10];

half3 _baseColorHalf[10];
half3 _specularColorHalf[10];
half _specularStrengthHalf[10];
half _shininessHalf[10];
/*
half _roughnessHalf[10];
half _metallicHalf[10];
half _rimPowerHalf[10];
half _fakeSpecularPowerHalf[10];
half3 _fakeSpecularColorHalf[10];
half _iorHalf[10];
half _refractionStrengthHalf[10];
half3 _refractionTintHalf[10];*/

//floating point global variables
float _sdfTypeFloat[10];
float3 _sdfPositionFloat[10];
float3 _sdfSizeFloat[10];
float _sdfRadiusFloat[10];

float3 _baseColorFloat[10];
float3 _specularColorFloat[10];
float _specularStrengthFloat[10];
float _shininessFloat[10];
/*
float _roughnessFloat[10];
float _metallicFloat[10];
float _rimPowerFloat[10];
float _fakeSpecularPowerFloat[10];
float3 _fakeSpecularColorFloat[10];
float _iorFloat[10];
float _refractionStrengthFloat[10];
float3 _refractionTintFloat[10];*/

//dolphin stuff
float3 _positionDolphinFloat[10];
float _timeOffsetDolphinFloat[10];
float _speedDolphinFloat[10];
float3 _directionDolphinFloat[10];

#endif