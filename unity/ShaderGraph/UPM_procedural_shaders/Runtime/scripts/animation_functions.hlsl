#ifndef ANIMATION_FILE
#define ANIMATION_FILE

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

#define PI 3.1415926538

float3x3 rotateX(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return float3x3(1, 0, 0, 0, c, s, 0, -s, c);
}

float3x3 rotateY(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return float3x3(c, 0, -s, 0, 1, 0, s, 0, c);
}

float3x3 rotateZ(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return float3x3(c, s, 0, -s, c, 0, 0, 0, 1);
}

void orbitY_half(half speed, out half3x3 camMatrix)
{
    half angle = _Time.y * speed;
    camMatrix = rotateY(angle);
}

void orbitY_float(float speed, out float3x3 camMatrix)
{
    float angle = _Time.y * speed;
    camMatrix = rotateY(angle);
}

void backAndForth_half(half speed, out half3x3 camMatrix)
{
    half t = _Time.y * speed;
    camMatrix = half3x3(1, 0, 0, 0, 1, 0, 0, 0, sin(t));
}

void backAndForth_float(float speed, out float3x3 camMatrix)
{
    float t = _Time.y * speed;
    camMatrix = half3x3(1, 0, 0, 0, 1, 0, 0, 0, sin(t));
}

// from https://www.shadertoy.com/view/NsS3Ww
void moveViaMouse_half(out half3x3 camMatrix)
{
    half2 mouse = (_mousePoint.xy == half2(0.0, 0.0)) ? half2(0.0, 0.0) : _mousePoint.xy / _ScreenParams.xy;

    camMatrix = mul(rotateX(mouse.y * -PI), rotateY(lerp(-PI, PI, mouse.x)));

}

void moveViaMouse_float(out float3x3 camMatrix)
{
    float2 mouse = (_mousePoint.xy == float2(0.0, 0.0)) ? float2(0.0, 0.0) : _mousePoint.xy / _ScreenParams.xy;

    camMatrix = mul(rotateX(mouse.y * -PI), rotateY(lerp(-PI, PI, mouse.x)));
}

// an animation ALWAYS has to end with this node!!
void finishAnimation_half(half3x3 mat1, half3x3 mat2, half distance, half3 center, out half3x3 camMatrix)
{
    half3x3 combinedMat = mul(mat1, mat2);
    _rayOrigin = mul(combinedMat, half3(0, 0, distance));
    camMatrix = computeCameraMatrix(center, _rayOrigin);
}

void finishAnimation_float(float3x3 mat1, float3x3 mat2, float distance, float3 center, out float3x3 camMatrix)
{
    float3x3 combinedMat = mul(mat1, mat2);
    _rayOrigin = mul(combinedMat, float3(0, 0, distance));
    camMatrix = computeCameraMatrix(center, _rayOrigin);
}

#endif