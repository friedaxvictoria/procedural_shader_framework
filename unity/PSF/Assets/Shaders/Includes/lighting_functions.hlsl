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

void applyLambertLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);

    float diff = max(dot(normal, lightDir), 0.0);
    float3 diffuse = diff * lightColor;

    lightingColor = ambientColor + diffuse;
}


void applyBlinnPhongLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);

    float3 halfVec = normalize(viewDir + lightDir);
    float diff = max(dot(normal, lightDir), 0.0);
    float spec = pow(max(dot(normal, halfVec), 0.0), _shininessFloat[hitID]);

    float3 colour = _baseColorFloat[hitID];
    float3 diffuse = diff * colour * lightColor;
    float3 specular = spec * _specularColorFloat[hitID] * _specularStrengthFloat[hitID];

    lightingColor = ambientColor + diffuse + specular;
}


void applyToonLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);

    float diff = max(dot(normal, lightDir), 0.0);

    float step1 = 0.3;
    float step2 = 0.6;
    float step3 = 0.9;

    float toonDiff =
        diff > step3 ? 1.0 :
        diff > step2 ? 0.7 :
        diff > step1 ? 0.4 : 0.1;

    float3 baseColor = _baseColorFloat[hitID];
    lightingColor = ambientColor + toonDiff * baseColor * lightColor;
}


void applyRimLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);

    float rim = 1.0 - saturate(dot(viewDir, normal));
    rim = pow(rim, 4.0);

    float3 baseColor = _baseColorFloat[hitID];
    lightingColor = ambientColor + baseColor * lightColor + rim * _specularColorFloat[hitID];
}


void applySoftSSLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, lightPosition, viewDir, lightDir, lightColor, ambientColor);

    float diff = max(dot(normal, lightDir), 0.0);
    float backLight = max(dot(-normal, lightDir), 0.0);

    float3 baseColor = _baseColorFloat[hitID];
    float3 sssColor = float3(1.0, 0.5, 0.5);

    float3 diffuse = diff * baseColor * lightColor;
    float3 sss = backLight * sssColor * 0.25;

    lightingColor = ambientColor + diffuse + sss;
}

void applyFresnelLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);
    
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float fresnel = pow(1.0 - saturate(dot(viewDir, normal)), 3.0);
    float rimStrength = 1.2;

    float3 baseColor = _baseColorFloat[hitID];
    lightingColor = ambientColor + baseColor * lightColor + rimStrength * fresnel * _specularColorFloat[hitID];
}


void applyUVGradientLighting_float(float3 hitPos, float3 lightPosition, float3 normal, float2 _uv, out float3 lightingColor)
{
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);

    float diff = max(dot(normal, lightDir), 0.0);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.1, 0.1, 0.1);

    float3 gradientColor = lerp(float3(0.2, 0.4, 0.9), float3(1.0, 0.6, 0.0), _uv.y); // vertical blend
    lightingColor = ambientColor + diff * gradientColor * lightColor;
}

void applyUVAnisotropicLighting_float(float3 hitPos, float3 lightPosition, float3 normal, float2 _uv, out float3 lightingColor)
{
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);
    float3 halfVec = normalize(viewDir + lightDir);

    // Build tangent frame from UV
    float angle = _uv.x * 6.2831853; // rotate 360° by u
    float3 localTangent = float3(cos(angle), sin(angle), 0.0);
    float3 tangent = normalize(localTangent - normal * dot(localTangent, normal));
    float3 bitangent = cross(normal, tangent);

    // Anisotropic specular term using half-vector projection
    float TdotH = dot(tangent, halfVec);
    float BdotH = dot(bitangent, halfVec);
    float specAniso = pow(TdotH * TdotH + BdotH * BdotH, 8.0);

    float diff = max(dot(normal, lightDir), 0.0);
    float3 baseColor = _baseColorFloat[hitID];
    float3 ambientColor = float3(0.1, 0.1, 0.1);

    lightingColor = ambientColor + diff * baseColor + specAniso * _specularColorFloat[hitID];
}



float dolphinShadow(float3 ro, float3 rd, float mint, float k, float dist)
{
    float result = 1.0;
    float t = mint;
    for (int i = 0; i < 25; ++i)
    {
        float3 p = ro + t * rd;
        result = min(result, k * dist / t);
        t += clamp(dist, 0.05, 0.5);
        if (dist < 0.0001)
            break;
    }
    return saturate(result);
}

void _dolphinColor(float3 pos, float3 nor, float3 rd, float glossy, float glossy2, float shadows,  float occlusion, float3 light, out float3 finalColor)
{
    float3 halfWay = normalize(light - rd);
    float3 reflection = reflect(rd, nor);

    float sky = saturate(nor.y);
    float ground = saturate(-nor.y);
    float diff = max(0.0, dot(nor, light));
    float back = max(0.3 + 0.7 * dot(nor, -float3(light.x, 0.0, light.z)), 0.0);

    float shadow = 1.0 - shadows;
    if (shadows * diff > 0.001)
    {
        shadow = dolphinShadow(pos + 0.01 * nor, light, 0.0005, 32.0, pos.z);
    }

    float fresnel = pow(saturate(1.0 + dot(nor, rd)), 5.0);
    float specular = pow(saturate(dot(halfWay, nor)), 0.01 + glossy);
    float sss = pow(saturate(1.0 + dot(nor, rd)), 2.0);

    float sh = 1.0;
    if (shadows > 0.0)
    {
        float3 reflDir = normalize(reflection + float3(0.0, 1.0, 0.0));
        sh = dolphinShadow(pos + 0.01 * nor, reflDir, 0.0005, 8.0, pos.z);
    }

    float3 BRDF = 0.0;
    

    BRDF += 1.0 * diff * float3(4.00, 2.20, 1.40) * float3(sh, sh * 0.5 + 0.5 * sh * sh, sh * sh);
    BRDF += 5.5 * sky * float3(0.20, 0.40, 0.55) * (0.5 + 0.5 * occlusion);
    BRDF += 1.0 * back * float3(0.40, 0.60, 0.70);
    BRDF += 11.0 * ground * float3(0.05, 0.30, 0.50);
    BRDF += 5.0 * sss * float3(0.40, 0.40, 0.40) * (0.3 + 0.7 * diff * sh) * glossy * occlusion;
    BRDF += 0.8 * specular * float3(1.30, 1.00, 0.90) * sh * diff * (0.1 + 0.9 * fresnel) * glossy * glossy;
    BRDF += sh * 40.0 * glossy * float3(1.0, 1.0, 1.0) * occlusion *
            smoothstep(-0.3 + 0.3 * glossy2, 0.2, reflection.y) *
            (0.5 + 0.5 * smoothstep(-0.2 + 0.2 * glossy2, 1.0, reflection.y)) *
            (0.04 + 0.96 * fresnel);

    finalColor = _baseColorFloat[hitID] * BRDF;
    finalColor += sh * (0.1 + 1.6 * fresnel) * occlusion * glossy2 * glossy2 * 40.0 * float3(1.0, 0.9, 0.8) *
                  smoothstep(0.0, 0.2, reflection.y) *
                  (0.5 + 0.5 * smoothstep(0.0, 1.0, reflection.y));

    finalColor += 1.2 * glossy * pow(specular, 4.0) * float3(1.4, 1.1, 0.9) * sh * diff * (0.04 + 0.96 * fresnel) * occlusion;

}

#endif