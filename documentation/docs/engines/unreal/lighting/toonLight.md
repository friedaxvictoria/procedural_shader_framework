<div class="container">
    <h1 class="main-heading">Toon Lighting</h1>
    <blockquote class="author">by Runtong Li</blockquote>
</div>

This function implements a stylized toon shading model using stepped diffuse bands instead of smooth gradients. It divides diffuse reflection into discrete levels and combines it with a minimal ambient term. This creates a cartoon-like appearance with clear lighting bands and no specular highlights.
    <figure markdown="span">
        ![Unreal PBR Lighting](../images/lighting/examples/toonLighting.png){ width="500" }
    </figure>
---

## The Code
```hlsl
void applyToonLighting(float4 hitPosition, float3 lightPosition, MaterialParams material, float3 normal, out float3 lightingColor)
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

    lightingColor = ambientColor + toonDiff * material.baseColor * lightColor;
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
    Find the node at ```ProcedrualShaderFramework/applyToonLighting```
    <figure markdown="span">
    ![Unreal toonLight](../images/lighting/toonLight.png){ width="500" }
    </figure>

=== "Standard Scripting"  
    Include - ```"/ProceduralShaderFramework/lighting_functions.ush"```

    Example Usage

    ```hlsl
    applyToonLighting(hitPos, lightPosition, mat, normal, color1);
    ```

---

This is an engine-specific implementation without a shader-basis.