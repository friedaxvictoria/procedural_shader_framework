#ifndef SDF_FILE
#define SDF_FILE

#include "helper_functions.hlsl"
#include "global_variables.hlsl"
#include "dolphin_helper_functions.hlsl"

//LOCAL HELPERS
void addSDF(float index, float type, float3 position, float3 size, float radius, float3 axis, float angle, float noise, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float timeOffset, float speed){
    for (int i = 0; i <= MAX_OBJECTS; i++)
    {
        if (i == index)
        {
            _sdfType[i] = type;
            _sdfPosition[i] = position;
            _sdfSize[i] = size;
            _sdfRadius[i] = radius;
            _sdfRotation[i] = computeRotationMatrix(normalize(axis), angle * PI / 180);
            _sdfNoise[i] = noise;
            
            _objectBaseColor[i] = baseColor;
            _objectSpecularColor[i] = specularColor;
            _objectSpecularStrength[i] = specularStrength;
            _objectShininess[i] = shininess;

            _timeOffsetDolphin[i] = timeOffset;
            _speedDolphin[i] = speed;
            break;
        }
    }
}

float sdSphere(float3 position, float radius)
{
    return length(position) - radius;
}

float sdRoundBox(float3 position, float3 b, float r)
{
    float3 q = abs(position) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

// radius.x is the major radius, radius.y is the thickness
float sdTorus(float3 position, float2 radius)
{
    float2 q = float2(length(position.xy) - radius.x, position.z);
    return length(q) - radius.y;
}

float sdHexPrism(float3 position, float2 height)
{
    const float3 k = float3(-0.8660254, 0.5, 0.57735);
    position = abs(position);
    position.xy -= 2.0 * min(dot(k.xy, position.xy), 0.0) * k.xy;
    float2 d = float2(
       length(position.xy - float2(clamp(position.x, -k.z * height.x, k.z * height.x), height.x)) * sign(position.y - height.x),
       position.z - height.y);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdOctahedron(float3 position, float s)
{
    position = abs(position);
    return (position.x + position.y + position.z - s) * 0.57735027;
}

float sdEllipsoid(float3 position, float3 r)
{
    float k0 = length(position / r);
    float k1 = length(position / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

float evalSDF(int index, float3 position)
{
    int sdfType = _sdfType[index];
    float3 probePt = mul((position - _sdfPosition[index]), _sdfRotation[index]);
    
    if (sdfType == 0)
        return sdSphere(probePt, _sdfRadius[index]);
    else if (sdfType == 1)
        return sdRoundBox(probePt, _sdfSize[index], _sdfRadius[index]);
    else if (sdfType == 2)
        return sdTorus(probePt, _sdfSize[index].yz);
    else if (sdfType == 3)
        return sdEllipsoid(probePt, _sdfSize[index]);
    else if (sdfType == 4)
        return sdHexPrism(probePt, _sdfRadius[index]);
    else if (sdfType == 5)
        return sdOctahedron(probePt, _sdfRadius[index]);
    else if (sdfType == 6)
        return dolphinDistance(probePt, _sdfPosition[index], _timeOffsetDolphin[index], _speedDolphin[index]).x;
    return 1e5;
}

float3 getNormal(int i, float3 p)
{
    float h = 0.0001;
    float2 k = float2(1, -1);
    
    float normal1 = evalSDF(i, p + k.xyy * h);
    float normal2 = evalSDF(i, p + k.yyx * h);
    float normal3 = evalSDF(i, p + k.yxy * h);
    float normal4 = evalSDF(i, p + k.xxx * h);
    return normalize(k.xyy * normal1 + k.yyx * normal2 + k.yxy * normal3 + k.xxx * normal4);
}

//CUSTOM NODE FUNCTIONS
void addSphere_float(float index, float3 position, float radius, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out float indexOut)
{
    addSDF(index, 0, position, float3(0,0,0), radius, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}

void addCube_float(float index, float3 position, float3 size, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out float indexOut)
{
    addSDF(index, 1, position, size, 0, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}

void addTorus_float(float index, float3 position, float radius, float thickness, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out float indexOut)
{
    addSDF(index, 2, position, float3(0, radius, thickness), 0, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}

void addEllipsoid_float(int index, float3 position, float3 size, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out int indexOut)
{
    addSDF(index, 3, position, size, 0, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}

void addHexPrism_float(int index, float3 position, float height, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out int indexOut)
{
    addSDF(index, 4, position, float3(0.0, 0.0, 0.0), height, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}

void addOctahedron_float(int index, float3 position, float radius, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, float noise, out int indexOut)
{
    addSDF(index, 5, position, float3(0.0, 0.0, 0.0), radius, axis, angle, noise, baseColor, specularColor, specularStrength, shininess, 0, 0);
    indexOut = index + 1;
}

void addDolphin_float(float index, float3 position, float timeOffset, float speed, float3 axis, float angle, float3 baseColor, float3 specularColor, float specularStrength,
float shininess, out float indexOut)
{
    addSDF(index, 6, position, float3(0.0, 0.0, 0.0), 9, axis, angle, 0, baseColor, specularColor, specularStrength, shininess, timeOffset, speed);
    indexOut = index + 1;
}

void raymarch_float(float condition, float3x3 cameraMatrix, float numberSDFs, float2 uv, out float4 hitPosition, out float3 normal, out int hitIndex, out float3 rayDirection)
{
    if (condition == 0)
    {
        cameraMatrix = computeCameraMatrix(float3(0, 0, 0), _rayOrigin, float3x3(1, 0, 0, 0, 1, 0, 0, 0, 1));
    }
    
    rayDirection = normalize(mul(float3(uv, -1), cameraMatrix));
    float t = 0.0;
    hitPosition = float4(0, 0, 0, 0);
    for (int i = 0; i < 100; i++)
    {
        float3 currentPosition = _rayOrigin + rayDirection * t; 
        float d = 1e5;
        int bestIndex = -1;
        for (int j = 0; j < numberSDFs; ++j)
        {
            float dj = evalSDF(j, currentPosition);
            if (dj < d)
            {
                d = dj; 
                bestIndex = j;
            }
        }
        hitIndex = bestIndex;
        d += _sdfNoise[hitIndex] * 0.3;
        if (d < 0.001)
        {
            hitPosition.xyz = currentPosition;
            normal = getNormal(hitIndex, currentPosition);
            break;
        }
        if (t > _raymarchStoppingCriterium)
        {
            hitPosition.xyz = currentPosition;
            break;
        }
        t += d;
    }
    hitPosition.w = t;
}

#endif