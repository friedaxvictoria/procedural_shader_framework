<div class="container">
    <h1 class="main-heading">Lambert Lighting</h1>
    <blockquote class="author">by Utku Alkan</blockquote>
</div>

This function applies simple Lambertian diffuse lighting with a fixed white light source. It computes the diffuse reflection based on the angle between the light direction and surface normal, and adds a small constant ambient term. This is a lightweight lighting model ideal for unlit or stylized shading.

---

## The Code
```hlsl
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
```

---

## Parameters

### Inputs

| Name            | Type     | Description |
|-----------------|----------|-------------|
| `hitPosition`   | float4   | World position of the surface hit; the w-component may be ignored |
| `normal`        | float3   | Surface normal at the hit point |
| `lightPosition` | float3   | World-space position of the directional light source |

The inputs are typically provided by the functions [SDF Raymarching](...) or [Water Surface](...).

#### **Output**
- `float3 lightingColor` — Final RGB lighting result using diffuse and ambient components.

---

## Implementation

=== "Visual Scripting"  
    Find the node at ```PSF/Lighting/LambertLight```

=== "Standard Scripting"  
    Include - ```#include "Packages/com.tudresden.proceduralshaderframeworkpackage/Runtime/scripts/lighting_functions.hlsl"```

    Example Usage

    ```hlsl
    float3 lightColor;
    applyLambertLighting_float(hitPos, surfaceNormal, float3(2, 5, -2), lightColor);
    ```
