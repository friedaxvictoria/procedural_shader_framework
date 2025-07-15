#ifndef HELPER_FILE
#define HELPER_FILE

#include "global_variables.hlsl"

float3x3 computeCameraMatrix(float3 lookAtPos, float3 eye, float3x3 mat)
{
    float3 f = normalize(lookAtPos - eye); // Forward direction
    float3 r = normalize(cross(f, mul(float3(0, 1, 0), mat))); // Right direction
    float3 u = cross(r, f); // Recomputed up
    return float3x3(r, u, -f); // Column-major: [right, up, -forward]
}

float3x3 computeRotationMatrix(float3 axis, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    float minusC = 1 - c;
    
    return float3x3(c + axis.x * axis.x * minusC, axis.x * axis.y * minusC - axis.z * s, axis.x * axis.z * minusC + axis.y * s,
    axis.y * axis.x * minusC + axis.z * s, c + axis.y * axis.y * minusC, axis.y * axis.z * minusC - axis.x * s,
    axis.z * axis.x * minusC - axis.y * s, axis.z * axis.y * minusC + axis.x * s, c + axis.z * axis.z * minusC);
}

#endif