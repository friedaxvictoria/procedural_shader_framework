#ifndef HELPER_FILE
#define HELPER_FILE

#include "global_variables.hlsl"

/*
float2 GetGradient(float2 intPos, float t)
{
    float rand = frac(sin(dot(intPos, float2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return float2(cos(angle), sin(angle));
}

float Pseudo3dNoise(float3 pos)
{
    float2 i = floor(pos.xy);
    float2 f = frac(pos.xy);
    float2 blend = f * f * (3.0 - 2.0 * f);

    float a = dot(GetGradient(i + float2(0, 0), pos.z), f - float2(0.0, 0.0));
    float b = dot(GetGradient(i + float2(1, 0), pos.z), f - float2(1.0, 0.0));
    float c = dot(GetGradient(i + float2(0, 1), pos.z), f - float2(0.0, 1.0));
    float d = dot(GetGradient(i + float2(1, 1), pos.z), f - float2(1.0, 1.0));

    float xMix = lerp(a, b, blend.x);
    float yMix = lerp(c, d, blend.x);
    return lerp(xMix, yMix, blend.y) / 0.7; // Normalize
}

float fbmPseudo3D(float3 p, int octaves)
{
    float result = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; ++i)
    {
        result += amplitude * Pseudo3dNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return result;
}*/

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