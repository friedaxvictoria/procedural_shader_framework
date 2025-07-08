#ifndef SUB_GRAPH_FILE
#define SUB_GRAPH_FILE

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

void addSphere_float(float3 position, float radius, float index, float3 axis, float angle, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, float noiseIn, out float indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _sdfTypeFloat[i] = 0;
            _sdfPositionFloat[i] = position;
            _sdfSizeFloat[i] = float3(0, 0, 0);
            _sdfRadiusFloat[i] = radius;
            
            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noiseIn;
            break;
        }
    }
    indexOut = index + 1;
}

void addTorus_float(float3 position, float radius, float thickness, float index, float3 axis, float angle, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, float noiseIn, out float indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _sdfTypeFloat[i] = 2;
            _sdfPositionFloat[i] = position;
            _sdfSizeFloat[i] = float3(0, radius, thickness);
            _sdfRadiusFloat[i] = 0;
            
            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noiseIn;
            break;
        }
    }
    indexOut = index + 1;
}

void addCube_float(float3 position, float3 size, float radius, float index, float3 axis, float angle, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, float noiseIn, out float indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _sdfTypeFloat[i] = 1;
            _sdfPositionFloat[i] = position;
            _sdfSizeFloat[i] = size;
            _sdfRadiusFloat[i] = 0;
            
            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noiseIn;
            break;
        }
    }
    indexOut = index + 1;
}

void addDolphin_float(float index, float3 position, float timeOffset, float speed, float3 direction, out float indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _timeOffsetDolphinFloat[i] = timeOffset;
            _speedDolphinFloat[i] = speed;
            _directionDolphinFloat[i] = direction;
            _sdfTypeFloat[i] = 3;
            _sdfPositionFloat[i] = position;
            
            _specularColorFloat[i] = float3(0, 0, 0);
            _specularStrengthFloat[i] = 0;
            _shininessFloat[i] = 1e-5;
            _sdfRotation[i] = float3x3(1, 0, 0, 0, 1, 0, 0, 0, 1);
            _sdfNoise[i] = 0;
            break;
        }
    }
    indexOut = index + 1;
}

void addHexPrism_float(int index, float3 position, float height, float3 axis, float angle, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, float noiseIn, out int indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _sdfTypeFloat[i] = 4;
            _sdfPositionFloat[i] = position;
            _sdfSizeFloat[i] = float3(0.0, 0.0, 0.0);;
            _sdfRadiusFloat[i] = height;
            
            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noiseIn;
            break;
        }
    }
    indexOut = index + 1;
}

void addOctahedron_float(int index, float3 position, float size, float3 axis, float angle, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, float noiseIn, out int indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _sdfTypeFloat[i] = 5;
            _sdfPositionFloat[i] = position;
            _sdfSizeFloat[i] = float3(0.0, 0.0, 0.0);;
            _sdfRadiusFloat[i] = size;
            
            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noiseIn;
            break;
        }
    }
    indexOut = index + 1;
}

void addEllipsoid_float(int index, float3 position, float3 radius, float3 axis, float angle, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, float noiseIn, out int indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            _sdfTypeFloat[i] = 6;
            _sdfPositionFloat[i] = position;
            _sdfSizeFloat[i] = radius;
            _sdfRadiusFloat[i] = 0.0;
            
            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noiseIn;
            break;
        }
    }
    indexOut = index + 1;
}

void raymarch_float(float condition, float numSDF, float2 uv, float3x3 camMatrix, out float4 hitPos, out float3 normal, out float3 rayDirection)
{
    if (condition == 0)
    {
        camMatrix = computeCameraMatrix(float3(0, 0, 0), _rayOrigin, float3x3(1, 0, 0, 0, 1, 0, 0, 0, 1));
    }
    
    rayDirection = normalize(mul(float3(uv, -1), camMatrix));
    float t = 0.0;
    hitPos = float4(0, 0, 0, 0);
    for (int i = 0; i < 100; i++)
    {
        float3 p = _rayOrigin + rayDirection * t; // Current point in the ray
        float d = 1e5;
        int bestID = -1;
        for (int j = 0; j < numSDF; ++j)
        {
            float dj = evalSDF(j, p);
            if (dj < d)
            {
                d = dj; // Update the closest distance
                bestID = j; // Update the closest hit ID
            }
        }
        hitID = bestID; // Store the ID of the closest hit shape
        d += _sdfNoise[hitID] * 0.3; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001)
        {
            hitPos.xyz = p;
            normal = get_normal(hitID, p);
            break;
        }
        if (t > _raymarchStoppingCriterium)
            break;
        t += d;
    }
    hitPos.w = t;
}

#endif