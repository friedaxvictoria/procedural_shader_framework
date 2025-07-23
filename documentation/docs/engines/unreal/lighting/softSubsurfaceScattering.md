<div class="container">
    <h1 class="main-heading">Soft Subsurface Scattering Lighting</h1>
    <blockquote class="author">by Runtong Li</blockquote>
</div>

This function simulates a simple soft subsurface scattering (SSS) effect by adding light transmitted through the object’s surface. It enhances realism by combining standard Lambertian diffuse shading with a soft backlighting term.
    <figure markdown="span">
        ![Unreal PBR Lighting](../images/lighting/examples/softSubsurfaceScattering.png){ width="500" }
    </figure>
---

## The Code
```hlsl
void applySoftSSLighting(float4 hitPosition, float3 lightPosition, MaterialParams material, float3 normal, out float3 lightingColor)
{
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.05, 0.05, 0.05);

    float diffuseValue = max(dot(normal, lightDirection), 0.0);
    float backLight = max(dot(-normal, lightDirection), 0.0);

    float3 baseColor = material.baseColor;
    float3 sssColor = float3(1.0, 0.5, 0.5);

    float3 diffuseColor = diffuseValue * baseColor * lightColor;
    float3 sss = backLight * sssColor * 0.25;

    lightingColor = ambientColor + diffuseColor + sss;
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
| `material`      | MaterialParams | The material which the SDF is rendered with|

The inputs are typically provided by the functions [SDF Raymarching](../sdfs/raymarchAll.md) or [Water Surface](../water/waterSurface.md).

### Output
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `lightingColor`   | float3   | Final RGB lighting result using diffuse and ambient components |

---

## Implementation

=== "Visual Scripting"  
    Find the node at ```ProcedrualShaderFramework/applySoftSSLighting```
    <figure markdown="span">
    ![Unreal softSubsurfaceScattering Lighting](../images/lighting/softSubsurfaceScattering.png){ width="500" }
    </figure>

=== "Standard Scripting"  
    Include - ```"/ProceduralShaderFramework/lighting_functions.ush"```

    Example Usage

    ```hlsl
    applySoftSSLighting(hitPos, lightPosition, mat, normal, color1);
    ```

---

This is an engine-specific implementation without a shader-basis.