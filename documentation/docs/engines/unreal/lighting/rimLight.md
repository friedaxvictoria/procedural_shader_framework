<div class="container">
    <h1 class="main-heading">Rim Lighting</h1>
    <blockquote class="author">by Runtong Li</blockquote>
</div>

This function applies rim lighting with a fixed light source. It adds a soft glow around the edges of objects by highlighting areas where the surface normal is nearly perpendicular to the view direction.
    <figure markdown="span">
        ![Unreal PBR Lighting](../images/lighting/examples/rimLighting.png){ width="500" }
    </figure>
---

## The Code
```hlsl
void applyRimLighting(float3 rimColor, float4 hitPosition, float3 lightPosition, MaterialParams material, float3 normal, out float3 lightingColor)
{
    float3 viewDir, lightDir, lightColor, ambientColor;
    
    viewDir = normalize(_rayOrigin - hitPosition.xyz);
    lightDir = normalize(lightPosition - hitPosition.xyz);
    lightColor = float3(1.0, 1.0, 1.0);
    ambientColor = float3(0.05, 0.05, 0.05);
    
    float rim = pow(1.0 - max(dot(normal, viewDir), 0.0), material.rimPower);
    lightingColor = rim * rimColor;
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
| `rimColor`      | float3   | The rim color you want to show |

The inputs are typically provided by the functions [SDF Raymarching](../sdfs/raymarchAll.md) or [Water Surface](../water/waterSurface.md).

### Output
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `lightingColor`   | float3   | Final RGB lighting result using diffuse and ambient components |

---

## Implementation

=== "Visual Scripting"  
    Find the node at ```ProcedrualShaderFramework/applyRimLighting```
    <figure markdown="span">
    ![Unreal rimLight](../images/lighting/rimLight.png){ width="500" }
    </figure>

=== "Standard Scripting"  
    Include - ```"/ProceduralShaderFramework/lighting_functions.ush"```

    Example Usage

    ```hlsl
    applyPhongLighting(hitPos, lightPosition, mat, normal, color1);
    ```

---

Find the original shader code [here](../../../shaders/lighting/lighting_functions.md).