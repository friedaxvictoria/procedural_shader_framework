#ifndef SUB_GRAPH_FILE
#define SUB_GRAPH_FILE

#include "helper_functions.hlsl"

static float3 _rayOrigin = float3(0, 0, 7); // Ray origin

float _sdfType[10];
float3 _sdfPosition[10];
float3 _sdfSize[10];
float _sdfRadius[10];

float3 baseColor[10];
float3 specularColor[10];
float specularStrength[10];
float shininess[10];
float roughness[10];
float metallic[10];
float rimPower[10];
float fakeSpecularPower[10];
float3 fakeSpecularColor[10];
float ior[10];
float refractionStrength[10];
float3 refractionTint[10];

void addSphere_half(half3 position, half radius, half index, out half indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfType[i] = 0;
            _sdfPosition[i] = position;
            _sdfSize[i] = half3(0, 0, 0);
            _sdfRadius[i] = radius;
        }
    }
    indexOut = index + 1;
}

void addTorus_half(half3 position, half radius, half thickness, half index, out half indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfType[i] = 2;
            _sdfPosition[i] = position;
            _sdfSize[i] = half3(0, radius, thickness);
            _sdfRadius[i] = 0;
        }
    }
    indexOut = index + 1;
}

void addCube_half(half3 position, half3 size, half radius, half index, out half indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfType[i] = 1;
            _sdfPosition[i] = position;
            _sdfSize[i] = size;
            _sdfRadius[i] = 0;
        }
    }
    indexOut = index + 1;
}

void computeUV_half(half2 fragCoord, out half2 uv)
{
    uv = (fragCoord.xy * 2.0 - 1.0) / float2(_ScreenParams.y / _ScreenParams.x, 1.);
}

void raymarch_half(half2 uv, half numSDF, out half t, out half3 hitPos, out half gHitID, out half3 normal)
{
    half3 rayDirection = normalize(half3(uv, -1)); // Ray direction

    t = 0.0;
    bool hit = false;
    for (int i = 0; i < 100; i++)
    {
        float3 p = _rayOrigin + rayDirection * t; // Current point in the ray
        half noise = get_noise(p);
        float d = 1e5;
        int bestID = -1;
        for (int i = 0; i < numSDF; ++i)
        {
            float di = evalSDF(_sdfPosition[i], _sdfRadius[i], _sdfSize[i], _sdfType[i], p);
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
            hit = true;
            normal = get_normal(_sdfPosition[gHitID], _sdfRadius[gHitID], _sdfSize[gHitID], _sdfType[gHitID], p);
            break;
        }
        if (t > 50.0)
            break;
        t += d;
    }
    if (!hit)
    {
        t = -1;
    }
}

void applyPhongLighting_half(half3 hitPos, half hitIndex, half3 normal, out half3 lightingColor)
{
    half3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, _rayOrigin, viewDir, lightDir, lightColor, ambientColor);
    half diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    half3 R = reflect(-lightDir, normal); // Reflected light direction
    half spec = pow(max(dot(R, viewDir), 0.0), shininess[hitIndex]); // Phong specular

    half3 diffuse = diff * baseColor[hitIndex] * lightColor;
    half3 specular = spec * specularColor[hitIndex] * specularStrength[hitIndex];

    lightingColor = ambientColor + diffuse + specular;
}

void scene_half(half3 colour, half t, out half4 FragCol)
{

    if (t > 0.0)
    {
        FragCol = half4(colour, 1.0);
    }
    else
    {
        FragCol = half4(0.0, 0.0, 0.0, 1.0);
    }
}

void createDefaultMaterialParams_half(half index, half3 baseColorIn, half3 specularColorIn, half specularStrengthIn,
half shininessIn, half roughnessIn, half metallicIn, half rimPowerIn, half fakeSpecularPowerIn, half3 fakeSpecularColorIn,
half iorIn, half refractionStrengthIn, half3 refractionTintIn, out half indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            baseColor[i] = baseColorIn;
            specularColor[i] = specularColorIn;
            specularStrength[i] = specularStrengthIn;
            shininess[i] = shininessIn;

            roughness[i] = roughnessIn;
            metallic[i] = metallicIn;
            rimPower[i] = rimPowerIn;
            fakeSpecularPower[i] = fakeSpecularPowerIn;
            fakeSpecularColor[i] = fakeSpecularColorIn;

            ior[i] = iorIn;
            refractionStrength[i] = refractionStrengthIn;
            refractionTint[i] = refractionTintIn;
            break;
        }
    }
    indexOut = index + 1;
}

void addSphere_float(float3 position, float radius, float index, out float indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfType[i] = 0;
            _sdfPosition[i] = position;
            _sdfSize[i] = float3(0, 0, 0);
            _sdfRadius[i] = radius;
        }
    }
    indexOut = index + 1;
}

void addTorus_float(float3 position, float radius, float thickness, float index, out float indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfType[i] = 2;
            _sdfPosition[i] = position;
            _sdfSize[i] = float3(0, radius, thickness);
            _sdfRadius[i] = 0;
        }
    }
    indexOut = index + 1;
}

void addCube_float(float3 position, float3 size, float radius, float index, out float indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _sdfType[i] = 1;
            _sdfPosition[i] = position;
            _sdfSize[i] = size;
            _sdfRadius[i] = 0;
        }
    }
    indexOut = index + 1;
}

void computeUV_float(float2 fragCoord, out float2 uv)
{
    uv = (fragCoord.xy * 2.0 - 1.0) / float2(_ScreenParams.y / _ScreenParams.x, 1.);
}

void raymarch_float(float2 uv, float numSDF, out float t, out float3 hitPos, out float gHitID, out float3 normal)
{
    float3 rayDirection = normalize(float3(uv, -1)); // Ray direction

    t = 0.0;
    bool hit = false;
    for (int i = 0; i < 100; i++)
    {
        float3 p = _rayOrigin + rayDirection * t; // Current point in the ray
        float noise = get_noise(p);
        gHitID = -1;
        float d = 1e5;
        int bestID = -1;
        for (int i = 0; i < numSDF; ++i)
        {
            float di = evalSDF(_sdfPosition[i], _sdfRadius[i], _sdfSize[i], _sdfType[i], p);
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
            hit = true;
            normal = get_normal(_sdfPosition[gHitID], _sdfRadius[gHitID], _sdfSize[gHitID], _sdfType[gHitID], p);
            break;
        }
        if (t > 50.0)
            break;
        t += d;
    }
    if (!hit)
    {
        t = -1;
    }
}

void applyPhongLighting_float(float3 hitPos, float hitIndex, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, _rayOrigin, viewDir, lightDir, lightColor, ambientColor);
    float diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    float3 R = reflect(-lightDir, normal); // Reflected light direction
    float spec = pow(max(dot(R, viewDir), 0.0), shininess[hitIndex]); // Phong specular

    float3 diffuse = diff * baseColor[hitIndex] * lightColor;
    float3 specular = spec * specularColor[hitIndex] * specularStrength[hitIndex];

    lightingColor = ambientColor + diffuse + specular;
}

void createDefaultMaterialParams_float(float index, float3 baseColorIn, float3 specularColorIn, float specularStrengthIn,
float shininessIn, float roughnessIn, float metallicIn, float rimPowerIn, float fakeSpecularPowerIn, float3 fakeSpecularColorIn,
float iorIn, float refractionStrengthIn, float3 refractionTintIn, out float indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (i == index)
        {
            baseColor[i] = baseColorIn;
            specularColor[i] = specularColorIn;
            specularStrength[i] = specularStrengthIn;
            shininess[i] = shininessIn;

            roughness[i] = roughnessIn;
            metallic[i] = metallicIn;
            rimPower[i] = rimPowerIn;
            fakeSpecularPower[i] = fakeSpecularPowerIn;
            fakeSpecularColor[i] = fakeSpecularColorIn;

            ior[i] = iorIn;
            refractionStrength[i] = refractionStrengthIn;
            refractionTint[i] = refractionTintIn;
            break;
        }
    }
    indexOut = index + 1;
}

void scene_float(float3 colour, float t, out float4 FragCol)
{

    if (t > 0.0)
    {
        FragCol = float4(colour, 1.0);
    }
    else
    {
        FragCol = float4(0.0, 0.0, 0.0, 1.0);
    }
}

#endif