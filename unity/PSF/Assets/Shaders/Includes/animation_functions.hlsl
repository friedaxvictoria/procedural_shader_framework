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

void orbitY_float(float speed, out float3x3 mat)
{
    float angle = _Time.y * speed;
    mat = rotateY(angle);
}

void backAndForth_float(float speed, out float3x3 mat)
{
    float t = _Time.y * speed;
    mat = half3x3(1, 0, 0, 0, 1, 0, 0, 0, abs(sin(t)));
}

// from https://www.shadertoy.com/view/NsS3Ww

void moveViaMouse_float(out float3x3 mat)
{
    float2 mouse = _mousePoint.xy / _ScreenParams.xy;
    //mouse.y = mouse.y-1;

    mat = mul(rotateY(lerp(-PI, PI, mouse.x)), rotateX(mouse.y * -PI));

}



void _animateUpDown(float3 pos, float amplitude, float frequency, out float3 outPos)
{
    outPos = pos;
    outPos.y += sin(_Time.y * frequency) * amplitude;
}

// an animation ALWAYS has to end with this node!!
void finishAnimation_float(float3x3 mat1, float3x3 mat2, float distance, float3 lookAtPos, out float3x3 camMatrix)
{
    float3x3 combinedMat = mul(mat1, mat2);
    _rayOrigin = mul(float3(0, 0, distance), combinedMat);
    camMatrix = computeCameraMatrix(lookAtPos, _rayOrigin);
}

#endif