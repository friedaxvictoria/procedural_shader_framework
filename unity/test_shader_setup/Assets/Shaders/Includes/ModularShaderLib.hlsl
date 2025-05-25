#ifndef MODULAR_SHADER_LIB
#define MODULAR_SHADER_LIB

float SimpleNoise(float2 p)
{
    return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

float PerlinNoise(float2 p)
{
    return (SimpleNoise(p) + SimpleNoise(p * 2.0) * 0.5 + SimpleNoise(p * 4.0) * 0.25);
}

float3 ApplyPerlinNoise(float3 color, float2 uv, float time)
{
    float n = PerlinNoise(uv * 5.0 + time);
    return color * n;
}

float3 ApplySimpleNoise(float3 color, float2 uv, float time)
{
    float n = SimpleNoise(uv * 10.0 + time);
    return color * n;
}

float3 ApplyPulse(float3 color, float time)
{
    float pulse = abs(sin(time * 2.0));
    return color * pulse;
}

float3 ApplyVerticalStripes(float3 color, float2 uv, float time)
{
    float stripe = step(0.5, frac(uv.y * 10 + time));
    return color * stripe;
}

float3 ApplyHorizontalStripes(float3 color, float2 uv, float time)
{
    float stripe = step(0.5, frac(uv.x * 10 + time));
    return color * stripe;
}

float3 ApplyRippleGeometry(float3 pos, float time, float rippleStrength)
{
    pos.y += sin(pos.x * 10 + time) * rippleStrength;
    return pos;
}

float3 ApplyTwistGeometry(float3 pos, float twistStrength)
{
    float angle = pos.y * twistStrength;
    float c = cos(angle);
    float s = sin(angle);
    float2 xz = float2(c * pos.x - s * pos.z, s * pos.x + c * pos.z);
    pos.x = xz.x;
    pos.z = xz.y;
    return pos;
}

float3 ApplySpinGeometry(float3 pos, float time, float spinSpeed)
{
    float angle = time * spinSpeed;
    float c = cos(angle);
    float s = sin(angle);
    float2 xz = float2(c * pos.x - s * pos.z, s * pos.x + c * pos.z);
    pos.x = xz.x;
    pos.z = xz.y;
    return pos;
}

#endif
