<div class="container">
    <h1 class="main-heading">UV Gradient Lighting</h1>
    <blockquote class="author">by Runtong Li</blockquote>
</div>

This function applies Lambertian diffuse lighting with a color gradient based on the surface's UV coordinates. The gradient interpolates from blue to orange depending on the uv.y value, creating visually interesting color variation across a surface. Ambient light is added for minimal base illumination.
    <figure markdown="span">
        ![Unreal PBR Lighting](../images/lighting/examples/uvg.png){ width="500" }
    </figure>
---

## The Code
```hlsl
void applyUVGradientLighting(float4 hitPosition, float3 lightPosition, MaterialParams material, float3 normal, float2 uv, out float3 lightingColor)
{
    float3 viewDirection = normalize(_rayOrigin - hitPosition.xyz);
    float3 lightDirection = normalize(lightPosition - hitPosition.xyz);
    float3 lightColor = float3(1.0, 1.0, 1.0);
    float3 ambientColor = float3(0.1, 0.1, 0.1);

    float diffuseValue = max(dot(normal, lightDirection), 0.0);
    float3 gradientColor = lerp(float3(0.2, 0.4, 0.9), float3(1.0, 0.6, 0.0), uv.y);

    lightingColor = ambientColor + diffuseValue * gradientColor * lightColor;
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
| `uv`            | float2   | UV coordinates used to define local tangent direction; for this framework the [fragment coordinates](../utils/fragCoords.md) from Fragment Coordinates can be used|

The inputs are typically provided by the functions [SDF Raymarching](../sdfs/raymarchAll.md) or [Water Surface](../water/waterSurface.md).

### Output
| Name            | Type     | Description |
|-----------------|----------|-------------|
| `lightingColor`   | float3   | Final RGB lighting result using diffuse and ambient components |

---

## Implementation

=== "Visual Scripting"  
    Find the node at ```ProcedrualShaderFramework/applyGradientLighting```
    <figure markdown="span">
    ![Unreal uvAnisotropicLight](../images/lighting/uvGradientLight.png){ width="500" }
    </figure>

=== "Standard Scripting"  
    Include - ```"/ProceduralShaderFramework/lighting_functions.ush"```

    Example Usage

    ```hlsl
    applyUVGradientLighting(hitPos, lightPosition, mat, normal, uv, color1);
    ```

---

This is an engine-specific implementation without a shader-basis.