#ifndef HELPER_FILE
#define HELPER_FILE

int _NoiseType = 0;

float sdSphere(float3 position, float radius)
{
    return length(position) - radius;
}

float sdRoundBox(float3 p, float3 b, float r)
{
    float3 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

// radius.x is the major radius, radius.y is the minor radius
float sdTorus(float3 p, float2 radius)
{
    // length(p.xy) - radius.x measures how far this point is from the torus ring center in the XY-plane.
    float2 q = float2(length(p.xy) - radius.x, p.z);
    return length(q) - radius.y;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Evaluate the signed distance function for a given SDF shape
float evalSDF(float3 sdfPosition, float sdfRadius, float3 sdfSize, int sdfType, float3 p)
{
    if (sdfType == 0)
    {
        return sdSphere((p - sdfPosition), sdfRadius);
    }
    else if (sdfType == 1)
    {
        return sdRoundBox(p - sdfPosition, sdfSize, sdfRadius);
    }
    else if (sdfType == 2)
        return sdTorus(p - sdfPosition, sdfSize.yz);
    return 1e5;
}

void lightingContext(float3 hitPos, float3 rayOrigin, out float3 viewDir, out float3 lightDir, out float3 lightColor,
out float3 ambientColor)
{
    viewDir = normalize(rayOrigin - hitPos); // Direction from hit point to camera
    float3 baseLightDir = float3(5.0, 5.0, 5.0); // Light position in world space
    lightDir = normalize(baseLightDir - hitPos);
    lightColor = float3(1.0, 1.0, 1.0); // Light color (white)
    ambientColor = float3(0.1, 0.1, 0.1); // Ambient light color<
}

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
}

float get_noise(float3 p)
{
    if (_NoiseType == 1)
    {
        return fbmPseudo3D(p, 1);
    }
    return 0;
}

float3 get_normal(float3 position, float radius, float3 size, int type, float3 p)
{
    float h = 0.0001;
    float2 k = float2(1, -1);
    
    float normal1 = evalSDF(position, radius, size, type, p + k.xyy * h);
    float normal2 = evalSDF(position, radius, size, type, p + k.yyx * h);
    float normal3 = evalSDF(position, radius, size, type, p + k.yxy * h);
    float normal4 = evalSDF(position, radius, size, type, p + k.xxx * h);
    return normalize(k.xyy * normal1 + k.yyx * normal2 + k.yxy * normal3 + k.xxx * normal4);
}

#endif