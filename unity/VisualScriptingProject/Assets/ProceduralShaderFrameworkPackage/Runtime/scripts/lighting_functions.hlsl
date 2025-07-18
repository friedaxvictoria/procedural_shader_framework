#ifndef LIGHTING_FUNCTIONS
#define LIGHTING_FUNCTIONS

#include "global_variables.hlsl"

//LOCAL HELPERS
struct SunriseLight
{
    float3 sundir;
    float3 earthCenter;
    float earthRadius;
    float atmosphereRadius;
    float sunIntensity;
};

float2 densitiesRM(float3 position, SunriseLight light)
{
    float h = max(0., length(position - light.earthCenter) - light.earthRadius);
    return float2(exp(-h / 8e3), exp(-h / 12e2));
}

float escape(float3 position, float3 direction, float atmosphereRadius, float3 earthCenter)
{
    float3 v = position - earthCenter;
    float b = dot(v, direction);
    float det = b * b - dot(v, v) + atmosphereRadius * atmosphereRadius;
    if (det < 0.)
        return -1.;
    det = sqrt(det);
    float t1 = -b - det;
    float t2 = -b + det;
    return (t1 >= 0.) ? t1 : t2;
}

float2 scatterDepthInt(float3 position, float3 direction, float atmosphericDistance, float steps, SunriseLight light)
{
    float2 depthRMs = float2(0., 0);
    atmosphericDistance /= steps;
    direction *= atmosphericDistance;

    for (float i = 0.; i < steps; ++i)
        depthRMs += densitiesRM(position + direction * i, light);

    return depthRMs * atmosphericDistance;
}

float3 applySunriseLighting(float3 position, float3 direction, float atmosphericDistance, float3 Lo, SunriseLight light)
{
    float3 bR = float3(58e-7, 135e-7, 331e-7); // Rayleigh scattering coefficient
    float3 bMs = float3(2e-5, 2e-5, 2e-5); // Mie scattering coefficients
    float3 bMe = float3(2e-5, 2e-5, 2e-5) * 1.1;
    float2 totalDepthRM = float2(0., 0);
    float3 I_R = float3(0., 0, 0);
    float3 I_M = float3(0., 0, 0);
    float3 oldDirection = direction;
    atmosphericDistance /= 16.0;
    direction *= atmosphericDistance;

    for (float i = 0.; i < 16.0; ++i)
    {
        float3 currentPosition = position + direction * i;
        float2 dRM = densitiesRM(currentPosition, light) * atmosphericDistance;
        totalDepthRM += dRM;
        float2 depthRMsum = totalDepthRM + scatterDepthInt(currentPosition, light.sundir, escape(currentPosition, light.sundir, light.atmosphereRadius, light.earthCenter), 4., light);
        float3 A = exp(-bR * depthRMsum.x - bMe * depthRMsum.y);
        I_R += A * dRM.x;
        I_M += A * dRM.y;
    }

    float mu = dot(oldDirection, light.sundir);
    return Lo + Lo * exp(-bR * totalDepthRM.x - bMe * totalDepthRM.y)
        + light.sunIntensity * (1. + mu * mu) * (
            I_R * bR * .0597 +
            I_M * bMs * .0196 / pow(1.58 - 1.52 * mu, 1.5));
}


//CUSTOM NODE FUNCTIONS
void sunriseLight_float(float4 hitPosition, float3 normal, float hitIndex, float3 rayDirection, out float3 lightingColor)
{
    SunriseLight sunrise;
    sunrise.sundir = normalize(float3(0.5, 0.4 * (1. + sin(0.5 * _Time.y)), -1.));
    sunrise.earthCenter = float3(0., -6360e3, 0.);
    sunrise.earthRadius = 6360e3;
    sunrise.atmosphereRadius = 6380e3;
    sunrise.sunIntensity = 10.0;
    
    float atmosphereDist = escape(hitPosition.xyz, rayDirection, sunrise.atmosphereRadius, sunrise.earthCenter);
    float3 lightColor = applySunriseLighting(hitPosition.xyz, rayDirection, atmosphereDist, float3(0, 0, 0), sunrise);
        
    if (hitPosition.w > _raymarchStoppingCriterium)
    {
        lightingColor = lightColor;
        return;
    }
        
    float3 lightDirection = sunrise.sundir;
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 reflectedDirection = reflect(-lightDirection, normal);
    
    float3 ambientColor = float3(0, 0, 0);

    float diffuseValue = max(dot(normal, lightDirection), 0.0);
    float specularValue = pow(max(dot(reflectedDirection, viewDirection), 0.0), _objectShininess[hitIndex]);
    
    float3 diffuseColor = diffuseValue * (0.5 * _objectBaseColor[hitIndex] + 0.5 * lightColor);
    float3 specularColor = specularValue * _objectSpecularColor[hitIndex] * _objectSpecularStrength[hitIndex];
        
    lightingColor = ambientColor + diffuseColor + specularColor;
}


void pointLight_float(float4 hitPosition, float3 normal, float hitIndex, float3 rayDirection, float3 lightPosition, float3 lightColor, float dropPower, float atmosphericDecay, out float3 lightingColor)
{
    //raymarch the environment    
    float t = 0;
    float3 pixelLightColor = float3(0, 0, 0);
    while (t < hitPosition.w)
    {
        float3 pt = _rayOrigin + t * rayDirection;
        float dist = distance(pt, lightPosition);
    
        float attenuation = clamp(1.0 / (pow(dist, dropPower)), 0.0, 1.0);
        float absorption = exp(-t * atmosphericDecay);
        
        pixelLightColor += attenuation * lerp(lightColor, float3(1.0, 1.0, 1.0), attenuation) * absorption;

        t += 1;
    }

    if (hitPosition.w > _raymarchStoppingCriterium)
    {
        lightingColor = pixelLightColor;
        return;
    }
    
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 reflectedDirection = reflect(-lightDirection, normal);
    
    float3 ambientColor = float3(0, 0, 0);
    
    float diffuseValue = max(dot(normal, lightDirection), 0.0);
    float specularValue = pow(max(dot(reflectedDirection, viewDirection), 0.0), _objectShininess[hitIndex]);

    float3 diffuseColor = diffuseValue * _objectBaseColor[hitIndex] * pixelLightColor;
    float3 specularColor = specularValue * _objectSpecularColor[hitIndex] * _objectSpecularStrength[hitIndex];
    
    lightingColor = ambientColor + diffuseColor + specularColor;
}

void applyLambertLighting_float(float4 hitPosition, float3 normal, float3 lightPosition, out float3 lightingColor)
{
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float diffuseValue = max(dot(normal, lightDirection), 0.0);
    float3 diffuseColor = diffuseValue * lightColor;

    lightingColor = ambientColor + diffuseColor;
}

void applyBlinnPhongLighting_float(float4 hitPosition, float3 normal, float hitIndex, float3 lightPosition, out
float3 lightingColor)
{
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float3 halfVec = normalize(viewDirection + lightDirection);
    float diffuseValue = max(dot(normal, lightDirection), 0.0);
    float specularValue = pow(max(dot(normal, halfVec), 0.0), _objectShininess[hitIndex]);

    float3 diffuseColor = diffuseValue * _objectBaseColor[hitIndex] * lightColor;
    float3 specular = specularValue * _objectSpecularColor[hitIndex] * _objectSpecularStrength[hitIndex];

    lightingColor = ambientColor + diffuseColor + specular;
}

void applyToonLighting_float(float4 hitPosition, float3 normal, float hitIndex, float3 lightPosition, out
float3 lightingColor)
{
    if (hitPosition.w > _raymarchStoppingCriterium)
    {
        lightingColor = float3(0, 0, 0);
        return;
    }
    
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float diffuseValue = max(dot(normal, lightDirection), 0.0);

    float step1 = 0.3;
    float step2 = 0.6;
    float step3 = 0.9;

    float toonDiff =
        diffuseValue > step3 ? 1.0 :
        diffuseValue > step2 ? 0.7 :
        diffuseValue > step1 ? 0.4 : 0.1;

    lightingColor = ambientColor + toonDiff * _objectBaseColor[hitIndex] * lightColor;
}

void applyRimLighting_float(float4 hitPosition, float3 normal, float hitIndex, float3 lightPosition, out
float3 lightingColor)
{
    if (hitPosition.w > _raymarchStoppingCriterium)
    {
        lightingColor = float3(0, 0, 0);
        return;
    }
    
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float rim = 1.0 - saturate(dot(viewDirection, normal));
    rim = pow(rim, 4.0);

    float3 baseColor = _objectBaseColor[hitIndex];
    lightingColor = ambientColor + baseColor * lightColor + rim * _objectSpecularColor[hitIndex];
}

void applySoftSSLighting_float(float4 hitPosition, float3 normal, float hitIndex, float3 lightPosition, out
float3 lightingColor)
{
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float diffuseValue = max(dot(normal, lightDirection), 0.0);
    float backLight = max(dot(-normal, lightDirection), 0.0);

    float3 baseColor = _objectBaseColor[hitIndex];
    float3 sssColor = float3(1.0, 0.5, 0.5);

    float3 diffuseColor = diffuseValue * baseColor * lightColor;
    float3 sss = backLight * sssColor * 0.25;

    lightingColor = ambientColor + diffuseColor + sss;
}

void applyFresnelLighting_float(float4 hitPosition, float3 normal, float hitIndex, float3 lightPosition, out float3 lightingColor)
{
    if (hitPosition.w > _raymarchStoppingCriterium)
    {
        lightingColor = float3(0, 0, 0);
        return;
    }

    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    
    float3 baseColor = _objectBaseColor[hitIndex];
    float3 specularColor = _objectSpecularColor[hitIndex];

    float3 ambientColor = float3(0.05, 0.05, 0.05);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float NdotL = saturate(dot(normal, lightDirection));
    float3 diffuse = baseColor * lightColor * NdotL;

    // Schlick's approximation
    float3 F0 = specularColor;
    float cosTheta = saturate(dot(viewDirection, normal));
    float3 fresnel = F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);

    lightingColor = ambientColor + diffuse + fresnel;
}

void applyUVGradientLighting_float(float4 hitPosition, float3 normal, float2 uv, float3 lightPosition, out float3 lightingColor)
{
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.1, 0.1, 0.1);

    float diffuseValue = max(dot(normal, lightDirection), 0.0);
    float3 gradientColor = lerp(float3(0.2, 0.4, 0.9), float3(1.0, 0.6, 0.0), uv.y);

    lightingColor = ambientColor + diffuseValue * gradientColor * lightColor;
}

void applyUVAnisotropicLighting_float(float4 hitPosition, float3 normal, float hitIndex, float2 uv, float3 lightPosition, out
float3 lightingColor)
{
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 halfVec = normalize(viewDirection + lightDirection);

    float angle = uv.x * 6.2831853; // 2π
    float3 localTangent = float3(cos(angle), sin(angle), 0.0);
    float3 tangent = normalize(localTangent - normal * dot(localTangent, normal));
    float3 bitangent = cross(normal, tangent);

    float TdotH = dot(tangent, halfVec);
    float BdotH = dot(bitangent, halfVec);
    float spectralAnisotropic = pow(TdotH * TdotH + BdotH * BdotH, 8.0);
    float diffuseValue = max(dot(normal, lightDirection), 0.0);

    float3 ambientColor = float3(0.1, 0.1, 0.1);

    lightingColor = ambientColor + diffuseValue * _objectBaseColor[hitIndex] + spectralAnisotropic * _objectSpecularColor[hitIndex];
}
#endif