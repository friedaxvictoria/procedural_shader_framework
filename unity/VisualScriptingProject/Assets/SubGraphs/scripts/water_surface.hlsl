#ifndef WATER_SURFACE_FILE
#define WATER_SURFACE_FILE

#include "global_variables.hlsl"
#include "helper_functions.hlsl"

//LOCAL HELPERS
float waveStrength = 0.0;

float2x2 compute2DRotationMatrix(float angle)
{
    float c = cos(angle), s = sin(angle);
    return float2x2(c, s, -s, c);
}

float hashNoise(float3 p)
{
    float3 f = floor(p), magic = float3(7, 157, 113);
    p -= f;
    float4 h = float4(0, magic.yz, magic.y + magic.z) + dot(f, magic);
    p *= p * (3.0 - 2.0 * p);
    h = lerp(frac(sin(h) * 43785.5), frac(sin(h + magic.x) * 43785.5), p.x);
    h.xy = lerp(h.xz, h.yw, p.y);
    return lerp(h.x, h.y, p.z);
}

float computeWave(float3 position)
{
    float3 warped = position - float3(0, 0, _Time.y % 62.83 * 3.0);

    float direction = sin(_Time.y * 0.15);
    float angle = 0.001 * direction;
    float2x2 rotation = compute2DRotationMatrix(angle);

    float accumulated = 0.0, amplitude = 3.0;
    for (int i = 0; i < 7; i++)
    {
        accumulated += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * (amplitude *= 0.51);
        warped.xy = mul(warped.xy, rotation);
        warped *= 1.75;
    }
    
    waveStrength = accumulated;

    float height = position.y + accumulated;
    height *= 0.5;
    height += 0.3 * sin(_Time.y + position.x * 0.3); // slight bobbing
    return height;
}

float3 getNormal(float3 position, float delta)
{
    return normalize(float3(
            computeWave(position + float3(delta, 0.0, 0.0)) -
            computeWave(position - float3(delta, 0.0, 0.0)),
            0.02,
            computeWave(position + float3(0.0, 0.0, delta)) -
            computeWave(position - float3(0.0, 0.0, delta))
        ));
}

float4 traceWater(float3 rayDirection)
{
    float d = 0;
    float t = 0;
    float3 hitPosition = float3(0, 0, 0);
    float3 outputPos;
    for (int i = 0; i < 100; i++)
    {
        float3 p = _rayOrigin + rayDirection * t;
        d = computeWave(p);
        if (d < 0.0001)
        {
            hitPosition = p;
            break;
        }
        t += d;
        if (t > _raymarchStoppingCriterium)
            break;
    }
    return float4(hitPosition, t);
}

//CUSTOM NODE FUNCTIONS
void computeWater_float(float condition, float3x3 cameraMatrix, float2 fragmentCoordinates, out float4 hitPosition, out float3 normal, out float hitIndex, out float3 rayDirection)
{
    if (condition == 0)
    {
        cameraMatrix = computeCameraMatrix(float3(0, 0, 0), _rayOrigin, float3x3(1, 0, 0, 0, 1, 0, 0, 0, 1));
    }
    
    rayDirection = normalize(mul(float3(fragmentCoordinates, -1), cameraMatrix));

    //default background color
    float3 baseColor = float3(0.05, 0.07, 0.1);
    float3 color = baseColor;

    hitPosition = traceWater(rayDirection);
    if (hitPosition.w < _raymarchStoppingCriterium)
    {
        normal = getNormal(hitPosition.xyz, 0.01);

        //fresnel-style highlight
        float fresnel = pow(1.0 - dot(normal, -rayDirection), 5.0);
        float highlight = clamp(fresnel * 1.5, 0.0, 1.0);

        //water shading: deep vs bright
        float3 deepColor = float3(0.05, 0.1, 0.6);
        float3 brightColor = float3(0.1, 0.3, 0.9);
        float shading = clamp(waveStrength * 0.1, 0.0, 1.0);
        float3 waterColor = lerp(deepColor, brightColor, shading);

        //add highlight
        waterColor += float3(1.0, 1, 1) * highlight * 0.4;

        //depth-based fog
        float fog = exp(-0.00005 * hitPosition.x * hitPosition.x * hitPosition.x);
        color = lerp(baseColor, waterColor, fog);
    }

    //gamma correction
    _objectBaseColor[MAX_OBJECTS] = pow(color, float3(0.55, 0.55, 0.55));
    _objectSpecularColor[MAX_OBJECTS] = pow(color, float3(0.55, 0.55, 0.55));
    _objectSpecularStrength[MAX_OBJECTS] = 1;
    _objectShininess[MAX_OBJECTS] = 32;
    //hard-coded hit index for the water
    hitIndex = MAX_OBJECTS;
}

void sampleHeightField_float(float3 position, out float3 heightPosition)
{
    float y = position.y;
    
    //binary search or Newton-Raphson style iteration
    float stepSize = 0.05; 

    for (int i = 0; i < 100; i++)
    {
        position.y = y;
        float height = computeWave(position);
        if (height < 0.01)
            break;
        y -= stepSize;
    }
    heightPosition = float3(position.x, y, position.z);
}

void adaptableNormal_float(float3 position, float3 offset, float influence, float sampleRadius, out float3 normal)
{
    float3 normal1 = getNormal(position + float3(sampleRadius, 0.0, 0.0), 1);
    float3 normal2 = getNormal(position - float3(sampleRadius, 0.0, 0.0), 1);
    float3 normal3 = getNormal(position + float3(0, 0.0, sampleRadius), 1);
    float3 normal4 = getNormal(position - float3(0, 0.0, sampleRadius), 1);
    normal = influence * (normal1 + normal2 + normal3 + normal4)/4 + offset;
}

#endif