#ifndef SUB_GRAPH_FILE
#define SUB_GRAPH_FILE

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

void addSphere_half(half3 position, half radius, half index, half3 baseColorIn, half3 specularColorIn, half specularStrengthIn,
half shininessIn, out half indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfTypeHalf[i] = 0;
            _sdfPositionHalf[i] = position;
            _sdfSizeHalf[i] = half3(0, 0, 0);
            _sdfRadiusHalf[i] = radius;
            
            _baseColorHalf[i] = baseColorIn;
            _specularColorHalf[i] = specularColorIn;
            _specularStrengthHalf[i] = specularStrengthIn;
            _shininessHalf[i] = shininessIn;
        }
    }
    indexOut = index + 1;
}

void addTorus_half(half3 position, half radius, half thickness, half index, half3 baseColorIn, half3 specularColorIn, half specularStrengthIn,
half shininessIn, out half indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfTypeHalf[i] = 2;
            _sdfPositionHalf[i] = position;
            _sdfSizeHalf[i] = half3(0, radius, thickness);
            _sdfRadiusHalf[i] = 0;
            
            _baseColorHalf[i] = baseColorIn;
            _specularColorHalf[i] = specularColorIn;
            _specularStrengthHalf[i] = specularStrengthIn;
            _shininessHalf[i] = shininessIn;
        }
    }
    indexOut = index + 1;
}

void addCube_half(half3 position, half3 size, half radius, half index, half3 baseColorIn, half3 specularColorIn, half specularStrengthIn,
half shininessIn, out half indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfTypeHalf[i] = 1;
            _sdfPositionHalf[i] = position;
            _sdfSizeHalf[i] = size;
            _sdfRadiusHalf[i] = 0;
            
            _baseColorHalf[i] = baseColorIn;
            _specularColorHalf[i] = specularColorIn;
            _specularStrengthHalf[i] = specularStrengthIn;
            _shininessHalf[i] = shininessIn;
        }
    }
    indexOut = index + 1;
}

void moveCamera_half(half2 uv, out half3 rayDirection)
{
    half2 mouse = (_mousePoint.xy == half2(0.0, 0.0)) ? half2(0.0, 0.0) : _mousePoint.xy / _ScreenParams.xy;

	// camera
    half xCameraAngle = 1.2 - 12.0 * (mouse.x - 0.5); // camera angle around the dolphin (animated with time and affected by mouse
    half yCameraAngle = 1.2 - 12.0 * (mouse.y - 0.5); // camera angle around the dolphin (animated with time and affected by mouse
    _rayOrigin = half3(sin(xCameraAngle), sin(yCameraAngle), 3);

	// camera matrix
    half3 forward = normalize(-_rayOrigin); // Forward vector (looking direction)
    half3 right = normalize(float3(-forward.z, 0.0, forward.x)); // Right vector (perpendicular to forward)
    half3 up = normalize(cross(right, forward)); // Up vector (perpendicular to both forward and right)
	
	// view ray direction
    rayDirection = normalize(uv.x * right + uv.y * up + 2.0 * forward);
}

void raymarch_half(half numSDF, half2 uv, half3x3 camMatrix, out half3 hitPos, out half gHitID, out half3 normal)
{
    half3 rayDirection = normalize(mul(half3(uv, -1.0), camMatrix));
    half t = 0.0;
    for (int i = 0; i < 100; i++)
    {
        half3 p = _rayOrigin + rayDirection * t; // Current point in the ray
        half noise = get_noise(p);
        half d = 1e5;
        int bestID = -1;
        for (int i = 0; i < numSDF; ++i)
        {
            half di = evalSDF(_sdfPositionHalf[i], _sdfRadiusHalf[i], _sdfSizeHalf[i], _sdfTypeHalf[i], p);
            if (di < d)
            {
                d = di; // Update the closest distance
                bestID = i; // Update the closest hit ID
            }
        }
        gHitID = bestID; // Store the ID of the closest hit shape
        d = d + noise * 0.3; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001)
        {
            hitPos = p;
            normal = get_normal(_sdfPositionHalf[i], _sdfRadiusHalf[i], _sdfSizeHalf[i], _sdfTypeHalf[i], p);
            break;
        }
        if (t > 50.0)
            break;
        t += d;
    }
}

void addSphere_float(float3 position, float radius, float index, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, out float indexOut)
{

    for (int i = 0; i <= index; i++)
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
        }
    }
    indexOut = index + 1;
}

void addTorus_float(float3 position, float radius, float thickness, float index, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, out float indexOut)
{
    for (int i = 0; i <= index; i++)
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
        }
    }
    indexOut = index + 1;
}

void addCube_float(float3 position, float3 size, float radius, float index, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, out float indexOut)
{
    for (int i = 0; i <= index; i++)
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
        }
    }
    indexOut = index + 1;
}



void moveCamera_float(float2 uv, out float3 rayDirection)
{
    
    float2 mouse = (_mousePoint.xy == float2(0.0, 0.0)) ? float2(0.0, 0.0) : _mousePoint.xy / _ScreenParams.xy;

	// camera
    float xCameraAngle = 1.2 - 12.0 * (mouse.x - 0.5); // camera angle around the dolphin (animated with time and affected by mouse
    float yCameraAngle = 1.2 - 12.0 * (mouse.y - 0.5); // camera angle around the dolphin (animated with time and affected by mouse
    _rayOrigin = float3(4*sin(xCameraAngle), 4*sin(yCameraAngle), 10);

	// camera matrix
    float3 forward = normalize(-_rayOrigin); // Forward vector (looking direction)
    float3 right = normalize(float3(-forward.z, 0.0, forward.x)); // Right vector (perpendicular to forward)
    float3 up = normalize(cross(right, forward)); // Up vector (perpendicular to both forward and right)
	
	// view ray direction
    rayDirection = normalize(uv.x * right + uv.y * up + 2.0 * forward);
}

void raymarch_float(float numSDF, float2 uv, float3x3 camMatrix, out float3 hitPos, out float gHitID, out float3 normal)
{
    //_rayOrigin = float3(6, 0, 10);
    float3 rayDirection = normalize(mul(half3(uv, -1.0), camMatrix));
    float t = 0.0;
    hitPos = float3(0, 0, 0);
    for (int i = 0; i < 100; i++)
    {
        float3 p = _rayOrigin + rayDirection * t; // Current point in the ray
        half noise = get_noise(p);
        float d = 1e5;
        int bestID = -1;
        for (int i = 0; i < numSDF; ++i)
        {
            float di = evalSDF(_sdfPositionFloat[i], _sdfRadiusFloat[i], _sdfSizeFloat[i], _sdfTypeFloat[i], p);
            if (di < d)
            {
                d = di; // Update the closest distance
                bestID = i; // Update the closest hit ID
            }
        }
        gHitID = bestID; // Store the ID of the closest hit shape
        d = d + noise * 0.3; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001)
        {
            hitPos = p;
            normal = get_normal(_sdfPositionFloat[gHitID], _sdfRadiusFloat[gHitID], _sdfSizeFloat[gHitID], _sdfTypeFloat[gHitID], p);
            break;
        }
        if (t > 50.0)
            break;
        t += d;
    }
}

#endif