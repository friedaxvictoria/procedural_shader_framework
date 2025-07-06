#ifndef LIGHTING_FUNCTIONS
#define LIGHTING_FUNCTIONS

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

float2 totalDepthRM;
float3 I_R, I_M;


struct SunriseLight
{
    float3 sundir;
    float3 earthCenter;
    float earthRadius;
    float atmosphereRadius;
    float sunIntensity;
};

float2 densitiesRM(float3 p, SunriseLight light)
{
    float h = max(0., length(p - light.earthCenter) - light.earthRadius);
    return float2(exp(-h / 8e3), exp(-h / 12e2));
}

float escape(float3 p, float3 d, float R, float3 earthCenter)
{
    float3 v = p - earthCenter;
    float b = dot(v, d);
    float det = b * b - dot(v, v) + R * R;
    if (det < 0.)
        return -1.;
    det = sqrt(det);
    float t1 = -b - det, t2 = -b + det;
    return (t1 >= 0.) ? t1 : t2;
}

float2 scatterDepthInt(float3 o, float3 d, float L, float steps, SunriseLight light)
{
    float2 depthRMs = float2(0.,0);
    L /= steps;
    d *= L;

    for (float i = 0.; i < steps; ++i)
        depthRMs += densitiesRM(o + d * i, light);

    return depthRMs * L;
}

void scatterIn(float3 o, float3 d, float L, float steps, SunriseLight light)
{
    L /= steps;
    d *= L;
    const float3 bR = float3(58e-7, 135e-7, 331e-7); // Rayleigh scattering coefficient
    const float3 bMs = float3(2e-5, 2e-5, 2e-5); // Mie scattering coefficients
    const float3 bMe = float3(2e-5, 2e-5, 2e-5) * 1.1;

    for (float i = 0.; i < steps; ++i)
    {
        float3 p = o + d * i;
        float2 dRM = densitiesRM(p, light) * L;
        totalDepthRM += dRM;
        float2 depthRMsum = totalDepthRM + scatterDepthInt(p, light.sundir, escape(p, light.sundir, light.atmosphereRadius, light.earthCenter), 4., light);
        float3 A = exp(-bR * depthRMsum.x - bMe * depthRMsum.y);
        I_R += A * dRM.x;
        I_M += A * dRM.y;
    }
}

float3 applySunriseLighting(float3 o, float3 d, float L, float3 Lo, SunriseLight light)
{
    const float3 bR = float3(58e-7, 135e-7, 331e-7); // Rayleigh scattering coefficient
    const float3 bMs = float3(2e-5, 2e-5, 2e-5); // Mie scattering coefficients
    const float3 bMe = float3(2e-5, 2e-5, 2e-5) * 1.1;
    totalDepthRM = float2(0.,0);
    I_R = I_M = float3(0.,0,0);
    scatterIn(o, d, L, 16., light);

    float mu = dot(d, light.sundir);
    return Lo + Lo * exp(-bR * totalDepthRM.x - bMe * totalDepthRM.y)
        + light.sunIntensity * (1. + mu * mu) * (
            I_R * bR * .0597 +
            I_M * bMs * .0196 / pow(1.58 - 1.52 * mu, 1.5));
}

void sunriseLight_float(float index, float3 inputColor, float4 hitPos, float3 normal, float3 rayDir, out float outIndex, out float3 lightingColor)
{   
    outIndex = index + 1;
        
    SunriseLight sunrise;
    sunrise.sundir = normalize(float3(.5, .4 * (1. + sin(.5 * time)), -1.));
    sunrise.earthCenter = float3(0., -6360e3, 0.);
    sunrise.earthRadius = 6360e3;
    sunrise.atmosphereRadius = 6380e3;
    sunrise.sunIntensity = 10.0;
    
    float3 materialColor = _sdfTypeFloat[hitID] == 3 ? getDolphinColor(hitPos.xyz, normal, sunrise.sundir) : _baseColorFloat[hitID];

    float atmosphereDist = escape(hitPos.xyz, rayDir, sunrise.atmosphereRadius, sunrise.earthCenter);
    float3 lightColor = applySunriseLighting(hitPos.xyz, rayDir, atmosphereDist, float3(0, 0, 0), sunrise);
        
    if (hitPos.w > _raymarchStoppingCriterium)
    {
        lightingColor = lerp(inputColor, lightColor, 1 / outIndex);
        return;
    }
        
    float3 lightDir = sunrise.sundir;
    float3 viewDir = normalize(_rayOrigin - hitPos.xyz); 
    float3 reflectedDir = reflect(-lightDir, normal);
    
    float3 ambientColor = float3(0,0,0);

    float diffuseValue = max(dot(normal, lightDir), 0.0);
    float specularValue = pow(max(dot(reflectedDir, viewDir), 0.0), _shininessFloat[hitID]);
    
    float3 diffuseColor = diffuseValue * (0.5 * materialColor + 0.5 * lightColor);
    float3 specularColor = specularValue * _specularColorFloat[hitID] * _specularStrengthFloat[hitID];
    
    float attenuation = 1;
    
    float3 currentColor = attenuation * (ambientColor + diffuseColor + specularColor);
    lightingColor = lerp(inputColor, currentColor, 1 / outIndex);
}


void pointLight_float(float index, float3 inputColor, float4 hitPos, float3 normal, float3 lightPosition, float3 lightColor, out float outIndex, out
float3 lightingColor)
{
    outIndex = index + 1;
    float3 materialColor = _sdfTypeFloat[hitID] == 3 ? getDolphinColor(hitPos.xyz, normal, lightPosition) : _baseColorFloat[hitID];

    if (hitPos.w > _raymarchStoppingCriterium)
    {
        materialColor = float3(0, 0, 0);
    }
    
    float3 lightDir = normalize(lightPosition - hitPos.xyz);
    float3 viewDir = normalize(_rayOrigin - hitPos.xyz);
    float3 reflectedDir = reflect(-lightDir, normal);
    
    float3 ambientColor = float3(0,0,0); 
    
    float diffuseValue = max(dot(normal, lightDir), 0.0);
    float specularValue = pow(max(dot(reflectedDir, viewDir), 0.0), _shininessFloat[hitID]); 

    float3 diffuseColor = diffuseValue * (0.5 * materialColor + 0.5 * lightColor);
    float3 specularColor = specularValue * _specularColorFloat[hitID] * _specularStrengthFloat[hitID];

    float attenuation = clamp(10.0 / distance(lightPosition, hitPos.xyz), 0.0, 1.0);
    
    float3 currentColor = attenuation * (ambientColor + diffuseColor + specularColor);
    lightingColor = lerp(inputColor, currentColor, 1 / outIndex);
}

#endif