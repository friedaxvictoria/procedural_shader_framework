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

void sunriseLight_float(float4 hitPos, float3 normal, float3 rayDir, out float3 lightingColor)
{   
        
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
        lightingColor = lightColor;
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
    lightingColor = currentColor;
}


void pointLight_float(float4 hitPos, float3 normal, float3 lightPosition, float3 lightColor, out float3 lightingColor)
{
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
    lightingColor = currentColor;
}






void applyLambertLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float diff = max(dot(normal, lightDir), 0.0);
    float3 diffuse = diff * lightColor;

    lightingColor = ambientColor + diffuse;
}

void applyBlinnPhongLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

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
    if (hitPos.z == 0)
    {
        lightingColor = float3(0, 0, 0);
        return;
    }
    
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

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
    if (hitPos.z == 0)
    {
        lightingColor = float3(0, 0, 0);
        return;
    }
    
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float rim = 1.0 - saturate(dot(viewDir, normal));
    rim = pow(rim, 4.0);

    float3 baseColor = _baseColorFloat[hitID];
    lightingColor = ambientColor + baseColor * lightColor + rim * _specularColorFloat[hitID];
}

void applySoftSSLighting_float(float3 hitPos, float3 lightPosition, float3 normal, out float3 lightingColor)
{
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

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
    if (hitPos.z == 0)
    {
        lightingColor = float3(0, 0, 0);
        return;
    }
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
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.1, 0.1, 0.1);

    float diff = max(dot(normal, lightDir), 0.0);
    float3 gradientColor = lerp(float3(0.2, 0.4, 0.9), float3(1.0, 0.6, 0.0), _uv.y);

    lightingColor = ambientColor + diff * gradientColor * lightColor;
}

void applyUVAnisotropicLighting_float(float3 hitPos, float3 lightPosition, float3 normal, float2 _uv, out float3 lightingColor)
{
    float3 viewDir = normalize(_rayOrigin - hitPos);
    float3 lightDir = normalize(lightPosition - hitPos);
    float3 halfVec = normalize(viewDir + lightDir);

    float angle = _uv.x * 6.2831853; // 2π
    float3 localTangent = float3(cos(angle), sin(angle), 0.0);
    float3 tangent = normalize(localTangent - normal * dot(localTangent, normal));
    float3 bitangent = cross(normal, tangent);

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

void _dolphinColor(float3 pos, float3 nor, float3 rd, float glossy, float glossy2, float shadows, float occlusion, float3 light, out float3 lightingColor)
{
    if (pos.z == 0)
    {
        lightingColor = float3(0, 0, 0);
        return;
    }
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

    lightingColor = _baseColorFloat[hitID] * BRDF;
    lightingColor += sh * (0.1 + 1.6 * fresnel) * occlusion * glossy2 * glossy2 * 40.0 * float3(1.0, 0.9, 0.8) *
                  smoothstep(0.0, 0.2, reflection.y) *
                  (0.5 + 0.5 * smoothstep(0.0, 1.0, reflection.y));

    lightingColor += 1.2 * glossy * pow(specular, 4.0) * float3(1.4, 1.1, 0.9) * sh * diff * (0.04 + 0.96 * fresnel) * occlusion;

}

#endif