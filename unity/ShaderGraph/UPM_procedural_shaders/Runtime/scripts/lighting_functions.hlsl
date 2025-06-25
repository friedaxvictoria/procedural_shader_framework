#ifndef LIGHTING_FUNCTIONS
#define LIGHTING_FUNCTIONS

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

//from SDF shader
void applyPhongLighting_half(half3 hitPos, float3 lightPosition, half hitIndex, half3 normal, out half3 lightingColor)
{
    half3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    half diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    half3 R = reflect(-lightDir, normal); // Reflected light direction
    float spec = pow(max(dot(R, viewDir), 0.0), _shininessHalf[hitIndex]); // Phong specular

    float3 diffuse = diff * _baseColorHalf[hitIndex] * lightColor;
    float3 specular = spec * _specularColorHalf[hitIndex] * _specularStrengthHalf[hitIndex];
    
    lightingColor = ambientColor + diffuse + specular;
    
    if (hitPos.z == 0)
    {
        lightingColor = half3(0, 0, 0);
    }
}

void applyPhongLighting_float(float3 hitPos, float3 lightPosition, float hitIndex, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    float diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    float3 R = reflect(-lightDir, normal); // Reflected light direction
    float spec = pow(max(dot(R, viewDir), 0.0), _shininessFloat[hitIndex]); // Phong specular

    float3 diffuse = diff * _baseColorFloat[hitIndex] * lightColor;
    float3 specular = spec * _specularColorFloat[hitIndex] * _specularStrengthFloat[hitIndex];

    lightingColor = ambientColor + diffuse + specular;

    if (hitPos.z == 0)
    {
        lightingColor = float3(0, 0, 0);
    }
}

/*
void applyBlinnPhongLighting_half(half3 hitPos, float3 lightPosition, half hitIndex, half3 normal, out half3 lightingColour)
{
    half3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    half diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    half3 H = normalize(lightDir + viewDir); // Halfway vector
    half spec = pow(max(dot(normal, H), 0.0), _shininessHalf[hitIndex]); // Specular term

    half3 diffuse = diff * _baseColorHalf[hitIndex] * lightColor;
    half3 specular = spec * _specularColorHalf[hitIndex] * _specularStrengthHalf[hitIndex];

    lightingColour = ambientColor + diffuse + specular;
}

void applyBlinnPhongLighting_float(float3 hitPos, float3 lightPosition, float hitIndex, float3 normal, out float3 lightingColour)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    float diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    float3 H = normalize(lightDir + viewDir); // Halfway vector
    half spec = pow(max(dot(normal, H), 0.0), _shininessFloat[hitIndex]); // Specular term

    half3 diffuse = diff * _baseColorFloat[hitIndex] * lightColor;
    half3 specular = spec * _specularColorFloat[hitIndex] * _specularStrengthFloat[hitIndex];

    lightingColour = ambientColor + diffuse + specular;
}

//from Ruimin Ma
void blinnLighting_half(half3 hitPos, half3 lightPosition, half hitIndex, half3 n, out half3 lightingColour)
{
    half3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    half ndl = clamp(dot(n, lightDir), 0., 1.); // diffuse/lambert / N⋅L
    
    half ndh;
    half3 h = normalize(lightDir - viewDir); // half vector
    ndh = dot(n, h); // N⋅H
    ndh = max(ndh, 0.);
    
    // ggx / Trowbridge and Reitz specular model approximation
    half g = ndh * ndh * (_roughnessHalf[hitIndex] * _roughnessHalf[hitIndex] - 1.) + 1.;
    half ggx = _roughnessHalf[hitIndex] * _roughnessHalf[hitIndex] / (3.141592 * g * g);

    // shlick approximation
    half fre = 1. + dot(viewDir, n); // fresnel
    // fresnel amount
    half f0 = (_iorHalf[hitIndex] - 1.) / (_iorHalf[hitIndex] + 1.);
    f0 = f0 * f0;
    half kr = f0 + (1. - f0) * (1. - _roughnessHalf[hitIndex]) * (1. - _roughnessHalf[hitIndex]) * pow(fre, 5.); // reflectivity
    
    lightingColour = lightColor * ndl * (_baseColorHalf[hitIndex] + _specularColorHalf[hitIndex] * kr * ggx); // diffuse + specular
}

void blinnLighting_float(float3 hitPos, float3 lightPosition, float hitIndex, float3 n, out float3 lightingColour)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    float ndl = clamp(dot(n, lightDir), 0., 1.); // diffuse/lambert / N⋅L
    
    float ndh;
    float3 h = normalize(lightDir - viewDir); // half vector
    ndh = dot(n, h); // N⋅H
    ndh = max(ndh, 0.);
    
    // ggx / Trowbridge and Reitz specular model approximation
    half g = ndh * ndh * (_roughnessFloat[hitIndex] * _roughnessFloat[hitIndex] - 1.) + 1.;
    half ggx = _roughnessFloat[hitIndex] * _roughnessFloat[hitIndex] / (3.141592 * g * g);

    // shlick approximation
    half fre = 1. + dot(viewDir, n); // fresnel
    // fresnel amount
    half f0 = (_iorFloat[hitIndex] - 1.) / (_iorFloat[hitIndex] + 1.);
    f0 = f0 * f0;
    half kr = f0 + (1. - f0) * (1. - _roughnessFloat[hitIndex]) * (1. - _roughnessFloat[hitIndex]) * pow(fre, 5.); // reflectivity
    
    lightingColour = lightColor * ndl * (_baseColorFloat[hitIndex] + _specularColorFloat[hitIndex] * kr * ggx); // diffuse + specular
}

//from Ruimin Ma
void phongLighting_half(half3 hitPos, half3 lightPosition, half hitIndex, half3 n, out half3 lightingColour)
{
    half3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    half ndl = clamp(dot(n, lightDir), 0., 1.); // diffuse/lambert / N⋅L
    
    half ndh;
    half3 r = reflect(viewDir, n); // reflected vector
    ndh = dot(r, lightDir); // R⋅L
    ndh = max(ndh, 0.);
    
    // ggx / Trowbridge and Reitz specular model approximation
    half g = ndh * ndh * (_roughnessHalf[hitIndex] * _roughnessHalf[hitIndex] - 1.) + 1.;
    half ggx = _roughnessHalf[hitIndex] * _roughnessHalf[hitIndex] / (3.141592 * g * g);

    // shlick approximation
    half fre = 1. + dot(viewDir, n); // fresnel
    // fresnel amount
    half f0 = (_iorHalf[hitIndex] - 1.) / (_iorHalf[hitIndex] + 1.);
    f0 = f0 * f0;
    half kr = f0 + (1. - f0) * (1. - _roughnessHalf[hitIndex]) * (1. - _roughnessHalf[hitIndex]) * pow(fre, 5.); // reflectivity
    
    lightingColour = lightColor * ndl * (_baseColorHalf[hitIndex] + _specularColorHalf[hitIndex] * kr * ggx); // diffuse + specular
}

void phongLighting_float(float3 hitPos, float3 lightPosition, float hitIndex, float3 n, out float3 lightingColour)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    float ndl = clamp(dot(n, lightDir), 0., 1.); // diffuse/lambert / N⋅L
    
    float ndh;
    float3 r = reflect(viewDir, n); // reflected vector
    ndh = dot(r, lightDir); // R⋅L
    ndh = max(ndh, 0.);
    
    // ggx / Trowbridge and Reitz specular model approximation
    half g = ndh * ndh * (_roughnessFloat[hitIndex] * _roughnessFloat[hitIndex] - 1.) + 1.;
    half ggx = _roughnessFloat[hitIndex] * _roughnessFloat[hitIndex] / (3.141592 * g * g);

    // shlick approximation
    half fre = 1. + dot(viewDir, n); // fresnel
    // fresnel amount
    half f0 = (_iorFloat[hitIndex] - 1.) / (_iorFloat[hitIndex] + 1.);
    f0 = f0 * f0;
    half kr = f0 + (1. - f0) * (1. - _roughnessFloat[hitIndex]) * (1. - _roughnessFloat[hitIndex]) * pow(fre, 5.); // reflectivity
    
    lightingColour = lightColor * ndl * (_baseColorFloat[hitIndex] + _specularColorFloat[hitIndex] * kr * ggx); // diffuse + specular
}*/

#endif