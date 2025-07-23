<div class="container">
    <h1 class="main-heading">Blinn Phong Lighting</h1>
    <blockquote class="author">by Runtong Li</blockquote>
</div>

This function implements the Blinn-Phong lighting model using per-pixel calculations. 
    <figure markdown="span">
        ![Unreal PBR Lighting](../images/lighting/examples/BlinnPhongLighting.png){ width="500" }
    </figure>
---

## The Code
```hlsl
void applyBlinnPhongLighting(float4 hitPosition, float3 lightPosition, MaterialParams material, float3 normal, out float3 lightingColor)
{
    if (hitPosition.w > _raymarchStoppingCriterium)
    {
        lightingColor = float3(0, 0, 0);
        return;
    }

    float3 viewDir, lightDir, lightColor, ambientColor;
    
    viewDir = normalize(_rayOrigin - hitPosition.xyz);
    lightDir = normalize(lightPosition - hitPosition.xyz);
    lightColor = float3(1.0, 1.0, 1.0);
    ambientColor = float3(0.05, 0.05, 0.05);
    
    float diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    float3 H = normalize(lightDir + viewDir); // Halfway vector
    float spec = pow(max(dot(normal, H), 0.0), material.shininess); // Specular term

    float3 diffuse = diff * material.baseColor * lightColor;
    float3 specular = spec * material.specularColor * material.specularStrength;

    lightingColor = ambientColor + diffuse + specular;
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
    Find the node at ```ProcedrualShaderFramework/ApplyBlinnPhongLighting```
    <figure markdown="span">
    ![Unreal PhongLighting Lighting](../images/lighting//blinnPhongLight.png){ width="500" }
    </figure>

=== "Standard Scripting"  
    Include - ```"/ProceduralShaderFramework/lighting_functions.ush"```
    Example Usage
    ```hlsl
    applyBlinnPhongLighting(hitPos, lightPosition, mat, normal, color1);
    ```

---

Find the original shader code [here](../../../shaders/lighting/lighting_functions.md).