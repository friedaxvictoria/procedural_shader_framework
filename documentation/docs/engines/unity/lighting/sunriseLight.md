# Sunrise Lighting

This function computes realistic atmospheric lighting based on a simplified earth-sun model. It simulates sunlight scattering through the atmosphere and includes diffuse and specular reflections using a Phong lighting model. If the ray hits the sky (escapes before hitting geometry), it returns the atmospheric color.

---

## The Code
```hlsl
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
```

---

## Parameters

### Inputs

| Name           | Type     | Description |
|----------------|----------|-------------|
| `hitPosition`  | float4   | World position of the surface hit; the w-component holds the raymarch step or distance |
| `normal`       | float3   | Surface normal at the hit point |
| `hitIndex`     | float    | Object/material index used to fetch shading parameters |
| `rayDirection` | float3   | Direction of the incoming ray |

The inputs are typically provided by the functions [SDF Raymarching](...) or [Water Surface](...).

#### **Output**
- `float3 lightingColor` — Final RGB lighting result, including sunrise sky or surface lighting.

---

## Implementation

=== "Visual Scripting"  
    Find the node at `PSF/Lighting/SunriseLight`

=== "Standard Scripting"  
    Include - `#include "Assets/Shaders/Includes/lighting_functions.hlsl"`

    Example Usage

    ```hlsl
    float3 lightColor;
    sunriseLight_float(hitPos, surfaceNormal, objectIndex, rayDir, lightColor);
    ```
---
