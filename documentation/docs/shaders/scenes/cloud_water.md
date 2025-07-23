<div class="container">
    <h1 class="main-heading">Cloud and Water Integration Shader</h1>
    <blockquote class="author">by Xuetong Fu</blockquote>
</div>

<img src="../../../static/images/images4Shaders/cloud_water.png" alt="Cloud And Water" width="400" height="225">

---

- **Category:** Scene
- **Author:** Xuetong Fu
- **Shader Type:** Volumetric cloud & fog rendering integrated with surface lighting
- **Input Requirements:** `fragCoord`, `iTime`, `iMouse`, `iResolution`, `iChannel0` (noise texture)
- **Output:**  `fragColor` RGBA color (volumetric cloud with light occlusion and dynamic terrain shading)

---

## 🧠 Algorithm

### 🔷 Core Concept
This shader combines three procedural effects in a single raymarch pipeline:

- **FBM-based volumetric clouds**
- **Distance‑ & height‑attenuated ground fog**
- **Hash‑noise height‑field water**

and uses reusable modules from the project to handle:

- **Procedural Components**
    - Noise
    - Water surface (hash-based heightfield)

- **Volumetric Modules**
    - Cloud volume
    - Volume material system
    - Volume lighting context
    - Volume lighting functions

- **Surface Modules**
    - Material systems
    - Lighting context
    - Lighting functions

---

## 🔗 Integration Strategy

This shader demonstrates how **lighting**, **surface material**, and **volumetric cloud** modules are combined into a cohesive rendering pipeline. Each module is responsible for a distinct visual effect, but they are integrated through a shared lighting context and coordinated call order.

### 1. Shared Setup: Consistent Lighting Across Modules

A global lighting configuration is defined at the top of `mainImage()` — including `lightDir`, `lightColor`, and `ambient`. These values are reused throughout the pipeline by both:

- **Surface lighting functions** (Blinn-Phong lighting)
- **Volumetric functions** (cloud and fog raymarching)

This ensures visual consistency in light direction and tone across water, fog and clouds.

### 2. Independent Evaluation: Surface and Volume Modules

The shader evaluates each visual domain separately:

- **Water Surface**  
  When the ray hits the water surface:
    - Surface color is defined with a `makeWater()` material
    - Lighting is computed using `applyBlinnPhongLighting()`
    - Cloud density above the surface is queried via `computeCloudOcclusion()` and used to darken the water surface

- **Cloud Volume**  
  Regardless of ray direction:
    - A volumetric cloud material is created using `makeCloud()`
    - Cloud density is integrated using `integrateCloud()`

- **Fog Volume**  
  Regardless of ray direction:
    - A volumetric fog material is created using `makeFog()`
    - Fog density is integrated using `integrateFog()`

Each module operates independently, but uses the **same light input** to ensure global coherence.

### 3. Unified Output: Layered Blending

Finally, the water surface, cloud, fog, and sky contributions are blended based on ray direction and medium presence:

- If the ray hits water, base water color is blended with fog and optionally with cloud if visible
- If the ray goes to sky, base sky color is blended with cloud and fog depending on their density
- Cloud and fog alpha (`.a`) values control the blending strength for smooth visual transitions

This produces a unified output that reflects layered atmosphere effects based on view direction and scene content.

### **Summary of Interactions**

| Module             | Input Shared                   | Interaction Type                          |
|--------------------|-------------------------------|-------------------------------------------|
| Lighting (core)    | `lightDir`, `lightColor`, `ambient` | Shared between surface and volume modules |
| Surface Material     | `MaterialParams`               | Affects water shading via Blinn-Phong         |
| Volume Material    | `VolMaterialParams`            | Affects cloud and fog scattering & absorption     |
| Bridge (Occlusion) | Density via `computeCloudOcclusion()` | Volume affects ground via shadowing  |

> This structure enables reusable, swappable modules while maintaining synchronized lighting and unified rendering.

---

## 🎛️ Parameters

### Universal Constants

| Name            | Value     | Description                                    |
|-----------------|-----------|------------------------------------------------|
| `PI`                 | `3.14159265359` | Mathematical constant used in phase calculations and normalization     |

### ☁️ Cloud Configuration

| Name            | Value     | Description                                    |
|-----------------|-----------|------------------------------------------------|
| `planetRadius` | `6360.0`   | Ground Y-position, defines sea/ground base |
| `atmosphereTop`| `6420.0`   | Scene top Y-position |
| `mieScaleHeight`     | `1.2`     | Vertical decay factor for Mie scattering                                    |
| `rayleighScaleHeight`| `8.0`     | Vertical decay factor for Rayleigh scattering                               |
| `cloudBase`     | `3.0`     | Height above planet where cloud begins         |
| `cloudThickness`| `8.0`     | Total vertical thickness of the cloud volume   |
| `CLOUD_BASE`    | `planetRadius + cloudBase`  | World height for cloud bottom |
| `CLOUD_TOP`     | `planetRadius + cloudBase + cloudThickness`  | World height for cloud top                     |
| `stepCount`     | `96.0` & `72.0` | Total steps for volume integration(different for cloud and fog)             |

### 💡 Lighting Configuration

| Name            | Value                     | Description                          |
|-----------------|---------------------------|--------------------------------------|
| `lightDir`      | `vec3(0.3, 0.5, 0.2)`     | Direction of the light               |
| `lightColor`    | `vec3(2.0, 2.2, 2.8)`     | Bright bluish daylight               |
| `ambient`       | Same as `lightColor`      | Used for both cloud and terrain      |

### 🌍 Scene Bounds & Camera

| Name           | Value                  | Description                                |
|----------------|------------------------|--------------------------------------------|
| `camPos`       | `vec3(0.0, planetRadius + 2.5, 0.0)` | Below the cloud layer initially |
| `boxMin`       | `vec3(-10.0, 0.0, -10.0)`    | Minimum bounds for any potential SDF geometry in the scene |
| `boxMax`       | `vec3(10.0, 5.0, 10.0)`      | Maximum bounds for potential SDF geometry in the scene     |


---

## 🧱 Shader Code & Includes

This shader imports or assumes the following headers:

```glsl
#include "noise/simplex_noise.glsl"
#include "material/volume_material/vol_mat_params.glsl"
#include "material/volume_material/vol_mat_presets.glsl"
#include "lighting/volume_lighting/vol_lit_context.glsl"
#include "lighting/volume_lighting/phase.glsl"
#include "lighting/volume_lighting/vol_lit.glsl"
#include "lighting/volume_lighting/vol_integration.glsl"
#include "lighting/volume_lighting/vol_occlusion.glsl"

#include "material/material/material_params.glsl"
#include "material/material/material_presets.glsl"
#include "lighting/surface_lighting/lighting_context.glsl"
#include "lighting/surface_lighting/blinn_phong.glsl"
```

### Main Entry
```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // === Time ===
    globalTimeWrapped = mod(iTime, 62.83);
    
    // === Camera Position ===
    vec3 camPos = vec3(0.0, planetRadius + 2.5, 0.0);

    // === Camera Orientation from Mouse ===
    vec2 m = (iMouse.xy == vec2(0.0)) ? vec2(0.5, 0.1) : iMouse.xy / iResolution.xy;
    float yaw = 6.2831 * (m.x - 0.5);
    float pitch = 1.5 * 3.1416 * (m.y - 0.5);

    float cosPitch = cos(pitch);
    vec3 forward = vec3(
        cosPitch * sin(yaw),
        sin(pitch),
        cosPitch * cos(yaw)
    );
    vec3 right = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
    vec3 up = normalize(cross(right, forward));
    mat3 camMat = mat3(right, up, forward);

    // === Ray Setup ===
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec3 rayDir = normalize(camMat * vec3(uv, 1.5));

    // === Light & Ambient Settings ===
    vec3 lightDir = normalize(vec3(0.3, 0.5, 0.2));
    vec3 lightColor = vec3(2.0, 2.2, 2.8);
    vec3 ambient = lightColor;

    // === Sky Background ===
    vec3 baseSky = mix(vec3(0.690, 0.878, 0.902), vec3(0.529, 0.808, 0.922), smoothstep(0.0, 0.5, rayDir.y));
    
    // === Water Surface Intersect ===
    vec2 waterHit = traceWater(camPos, rayDir);
    bool hitWater = waterHit.y > 0.0;
    vec3 baseWater;
    vec3 lighting;
    
    if (hitWater) {
        vec3 hitPos = camPos + rayDir * waterHit.x;
        
     // === Fake normal from gradient ===
        float delta = 0.05;
        vec3 grad = normalize(vec3(computeWave(hitPos + vec3(delta, 0.0, 0.0), 7, 0.0) - computeWave(hitPos - vec3(delta, 0.0, 0.0), 7, 0.0), 
                                   0.5,
                                   computeWave(hitPos + vec3(0.0, 0.0, delta), 7, 0.0) - computeWave(hitPos - vec3(0.0, 0.0, delta), 7, 0.0)
                                   ));
        
        // === Occlusion ===
        float occCloud = computeCloudOcclusion(hitPos + grad * 0.1, lightDir);
        // float occFog = computeFogOcclusion(hitPos + grad * 0.1, lightDir, camPos);
        // float occ = clamp(occCloud + occFog, 0.0, 0.5); 
        
        // === Construct LightingContext ===
        LightingContext waterCtx = createLightingContext(hitPos, grad, -rayDir, normalize(lightDir), lightColor, vec3(0.05));

        // === Construct MaterialParams for Water ===
        MaterialParams waterMat = makeWater(vec3(0.05, 0.1, 0.2));

        // === Sample texture-based detail noise ===
        float texNoiseVal = sampleNoiseTexture(controlPoint.xz * 0.005, iChannel0).r +
                            sampleNoiseTexture(controlPoint.xz * 0.05, iChannel0).r * 0.5;

        // === Compute color from geometry + noise ===
        float shadingFactor = clamp(waveStrength * 0.1 + texNoiseVal * 0.8, 0.0, 1.0);
        vec3 baseColor = mix(waterMat.baseColor, vec3(0.1, 0.3, 0.9), shadingFactor);

        // === Compute Lighting ===
        // vec3 specular = computeFakeSpecular(waterCtx, waterMat);
        // baseWater = baseColor + specular;
        baseWater = applyBlinnPhongLighting(waterCtx, waterMat);
        
        // === Mix with occlusion shadow ===
        vec3 shadowColor = vec3(0.22, 0.28, 0.35);
        baseWater = mix(baseWater, shadowColor, occCloud * 0.3);
    }
    
    // === Cloud Volume Rendering ===
    VolMaterialParams cloudMat = makeCloud(vec3(1.0));
    vec4 cloudCol = integrateCloud(camPos, rayDir, 80.0, 96.0, lightDir, lightColor, ambient, cloudMat);

    // === Fog Volume Rendering ===
    VolMaterialParams fogMat = makeFog(vec3(0.95, 0.94, 0.90));
    vec4 fogCol = integrateFog(camPos, rayDir, 60.0, 72.0, lightDir, lightColor, ambient, fogMat);

    // === Final Color Blending ===
    vec3 finalColor = vec3(0.0);
    if (hitWater) {
        finalColor = baseWater;
        finalColor = mix(baseWater, fogCol.rgb, fogCol.a * 0.2);
        if (cloudCol.a > 0.01) {
            finalColor = mix(finalColor, cloudCol.rgb, cloudCol.a * 0.3);
        }
    }
    else {
        finalColor = baseSky;
        if (cloudCol.a> 0.01) {
            finalColor = mix(finalColor, cloudCol.rgb, cloudCol.a);
        }
        finalColor = mix(finalColor, fogCol.rgb, fogCol.a);
    }

    fragColor = vec4(clamp(finalColor, 0.0, 1.0), 1.0);
}
```

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/example_CloudsWater.glsl)
