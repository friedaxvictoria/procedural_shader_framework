#ifndef ANIMATION_FILE
#define ANIMATION_FILE

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

void rotateCamera_float(float3 axis, float speed, out float3x3 mat)
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
void getCameraMatrix_float(float3x3 mat1, float3x3 mat2, float distance, float3 lookAtPos, out float3x3 camMatrix)
{
    float3x3 combinedMat = mul(mat1, mat2);
    _rayOrigin = mul(float3(0, 0, distance), combinedMat);
    camMatrix = computeCameraMatrix(lookAtPos, _rayOrigin, combinedMat);
}

float applyTimeMode(float t, int mode)
{
    if (mode == 1)
        return sin(t);
    else if (mode == 2)
        return abs(sin(t));
    return t;
}

void translateObject_float(float3 seedPosition, float3 dir, float speed, int mode, out float3 position)
{
    float t = applyTimeMode(_Time.y, mode);
    position = seedPosition + dir * sin(t * speed);
}

void orbitObjectAroundPoint_float(float3 seedPosition, float3 center, float3 axis, float radius, float speed, float angleOffset, out float3 position, out float angle)
{
    axis = normalize(axis);
    angle = _Time.y * speed + angleOffset * PI / 180;
        
    float3 radiusAxis = (float3(1, 1, 1) - axis) * radius;
    
    float3 p = seedPosition + radiusAxis - center;
    position = center + cos(angle) * p + sin(angle) * cross(axis, p) + (1 - cos(angle)) * dot(axis, p) * axis;
    
    angle = angle * 180 / PI;
}

void pulseObject_float(float3 seedSize, float seedRadius, float freq, float amp, int mode, out float3 size, out float radius)
{
    float t = applyTimeMode(_Time.y, mode);
    float scale = 1.0 + sin(t * freq) * amp;
    
    size = seedSize * scale;
    radius = seedRadius * scale;
}
#endif