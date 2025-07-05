#ifndef ANIMATION_FILE
#define ANIMATION_FILE

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

#define PI 3.1415926538

void orbitY_float(float3 axis, float speed, out float3x3 mat)
{
    float angle = _Time.y * speed;
    mat = computeRotationMatrix(normalize(axis), angle);
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

    mat = mul(computeRotationMatrix(float3(0, 1, 0), lerp(-PI, PI, mouse.x)), computeRotationMatrix(float3(1, 0, 0), mouse.y * -PI));

}

// a camera animation ALWAYS has to end with this node!!
void finishAnimation_float(float3x3 mat1, float3x3 mat2, float distance, float3 lookAtPos, out float3x3 camMatrix)
{
    float3x3 combinedMat = mul(mat1, mat2);
    _rayOrigin = mul(float3(0, 0, distance), combinedMat);
    camMatrix = computeCameraMatrix(lookAtPos, _rayOrigin, combinedMat);
}

float applyTimeMode(float t, int mode)
{
    if (mode == 1)
        return sin(t);
    if (mode == 2)
        return abs(sin(t));
    return t;
}

void translate_float(int index, float3 dir, float speed, int mode, out int outIndex)
{
    float t = applyTimeMode(_Time.y, mode);
    for (int i = 0; i <= 10; i++)
    {
        if (i == index-1)
        {
            _sdfPositionFloat[i] += dir * sin(t * speed);
            break;
        }
    }
    outIndex = index;
}

void orbitPoint_float(int index, float3 center, float3 axis, float radius, float speed, float angleOffset, out int outIndex)
{
    axis = normalize(axis);
    float angle = _Time.y * speed + angleOffset * PI/180;
    
    float3x3 rotationMatrix = computeRotationMatrix(axis, angle);
    
    float3 radiusAxis = (float3(1, 1, 1) - axis) * radius;

    for (int i = 0; i <= 10; i++)
    {
        if (i == index-1)
        {
            float3 p = _sdfPositionFloat[i] + radiusAxis - center;
            _sdfPositionFloat[i] = center + cos(angle) * p + sin(angle) * cross(axis, p) + (1 - cos(angle)) * dot(axis, p) * axis;
            _sdfRotation[i] = rotationMatrix;
            break;
        }
    }
    outIndex = index;
}

void pulse_float(int index, float freq, float amp, int mode, out int outIndex)
{
    float t = applyTimeMode(_Time.y, mode);
    float scale = 1.0 + sin(t * freq) * amp;
    for (int i = 0; i <= 10; i++)
    {
        if (i == index-1)
        {
            _sdfSizeFloat[i] *= scale;
            _sdfRadiusFloat[i] *= scale;
            break;
        }
    }
    outIndex = index;
}


void cycleColor_float(int index, float speed, out int outIndex)
{
    float t = _Time.y * speed;
    float3 color = float3(sin(t), sin(t + 2.094), sin(t + 4.188)) * 0.5 + 0.5; // RGB phase shifted
    for (int i = 0; i <= 10; i++)
    {
        if (i == index - 1)
        {
            _baseColorFloat[i] = color;
            break;
        }
    }
    outIndex = index;
}


float hash11(float x)
{
    return frac(sin(x * 17.23) * 43758.5453);
}

void shake_float(int index, float intensity, float speed, out int outIndex)
{
    float t = _Time.y * speed * 0.00001;
    float3 offset = float3(
        hash11(t + index * 1.1) - 0.5,
        hash11(t + index * 2.3) - 0.5,
        hash11(t + index * 3.7) - 0.5
    ) * intensity;
    
    for (int i = 0; i <= 10; i++)
    {
        if (i == index - 1)
        {
            _sdfPositionFloat[i] += offset;
            break;
        }
    }
    outIndex = index;
}




#endif