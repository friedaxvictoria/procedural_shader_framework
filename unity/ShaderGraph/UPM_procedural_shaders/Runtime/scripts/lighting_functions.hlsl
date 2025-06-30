#ifndef LIGHTING_FUNCTIONS
#define LIGHTING_FUNCTIONS

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

//from SDF shader
void applyPhongLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);
    float diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    float3 R = reflect(-lightDir, normal); // Reflected light direction
    float spec = pow(max(dot(R, viewDir), 0.0), _shininessFloat[hitID]); // Phong specular

    float3 colour = _sdfTypeFloat[hitID] == 3 ? getDolphinColor(hitPos, normal, lightPosition) : _baseColorFloat[hitID];
    float3 diffuse = diff * colour * lightColor;
    float3 specular = spec * _specularColorFloat[hitID] * _specularStrengthFloat[hitID];

    lightingColor = ambientColor + diffuse + specular;

    if (hitPos.z == 0)
    {
        lightingColor = float3(0, 0, 0);
    }
}

#endif