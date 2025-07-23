<div class="container">
    <h1 class="main-heading">Volume Lighting Functions</h1>
    <blockquote class="author">by Xuetong Fu</blockquote>
</div>

---

- **Category:** Lighting
- **Shader Type:** Lighting function library
- **Input Requirements:** `VolCtxLocal`, `VolMaterialParams`, `VolumeSample`
---

### 🔷 Core Concept
This module contains volumetric lighting computation functions for rendering clouds and fog, supporting:

- Light scattering phase functions (`computePhaseIsotropic`, `computePhaseHG`, etc.)
- Local lighting models for clouds and fog (`applyVolLitCloud`, `applyVolLitFog`)
- Volumetric integration (`integrateCloud`, `integrateFog`)
- Occlusion estimation (`computeCloudOcclusion`, `computeFogOcclusion`)

---
## 🎛️ Parameters

| Name       | Description            | Type             | Role      |
|------------|------------------------|------------------|----------|
| `s`        | Volume sample (density, emission) | VolumeSample      | Input     |
| `ctx`      | Lighting context input | VolCtxLocal      | Input     |
| `mat`      | Volumetric material parameters    | VolMaterialParams | Input     |



## 💻 Shader Code & Includes

### 1.Light scattering phase functions
- `computePhaseIsotropic`: Models uniform scattering in all directions.
- `computePhaseHG`: Models anisotropic scattering based on a single anisotropy parameter g[-1, 1].
- `computePhaseSchlick`: Fast approximation of HG phase function.
- `computePhaseRayleigh`: Models scattering of very small particles (e.g. air molecules) producing blue sky and atmospheric glow.
- `computePhaseMie`: Simulates scattering by larger particles like smoke, dust, or mist using HG as an approximation.

🔗 [View Source on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/volume_lighting/phase.glsl)

### 2.Local lighting models
- `applyVolLitCloud`: Computes lighting for a sample in a cloud volume, supporting scattering, emission, ambient, and absorption.
<!--
if you want to put small code snippet and make it appereable and dissapear
-->
??? note "📄 vol_lit.glsl"
    ```glsl
    vec4 applyVolLitCloud(
        VolumeSample s,
        VolumeLightingContextI ctx,
        VolumeMaterialParams mat
    ) {
        // === Phase Function Selection ===
        float cosTheta = dot(ctx.viewDir, ctx.lightDir);
        float phase = computePhaseIsotropic();

        // === Scattering ===
        vec3 scatter = vec3(0.0);
        if (mat.scatteringCoeff > 0.0 && s.density > 0.0) {
            scatter = mat.baseColor * ctx.lightColor * phase * mat.scatteringCoeff * s.density;
        }

        // === Emission ===
        vec3 emission = vec3(0.0);
        if (mat.emissionStrength > 0.0 && s.emission > 0.0) {
            emission = mat.emissionColor * mat.emissionStrength * s.emission;
        }

        return vec4((scatter + emission + ambient) * alpha, alpha);
        // === Ambient ===
        vec3 ambient = mat.baseColor * ctx.ambient * (0.2 + 0.8 * s.density);

        // === Absorption / Alpha ===
        float alpha = 1.0 - exp(-s.density * mat.absorptionCoeff * ctx.stepSize * 30.0);

        return vec4((scatter + emission + ambient) * (1.8 - alpha), alpha);
    }
    ```
<!--
if we want to link the github repo
-->

- `applyVolLitFog`: Computes lighting for fog using isotropic scattering, softer ambient contribution, and beam enhancements.

??? note "📄 vol_lit.glsl"
    ```glsl
    vec4 applyVolLitFog(
        VolumeSample s,
        VolCtxLocal ctx,
        VolMaterialParams mat
    ) {
        // === Phase Function Selection ===
        float cosTheta = dot(ctx.viewDir, ctx.lightDir);
        float phase = computePhaseIsotropic(); 

        // === Scattering ===
        vec3 scatter = vec3(0.0);
        if (mat.scatteringCoeff > 0.0 && s.density > 0.0) {
            scatter = mat.baseColor * ctx.lightColor * phase * mat.scatteringCoeff * s.density;
        }

        // === Emission ===
        vec3 emission = vec3(0.0);
        if (mat.emissionStrength > 0.0 && s.emission > 0.0) {
            emission = mat.emissionColor * mat.emissionStrength * s.emission;
        }

        // === Ambient ===
        vec3 ambient = mat.baseColor * ctx.ambient * (0.1 + 0.3 * s.density); // 比云更稀薄、柔和

        // === Absorption / Alpha ===
        float alpha = 1.0 - exp(-s.density * mat.absorptionCoeff * ctx.stepSize * 10.0);

        // === Beam Enhancement ===
        vec3 beam = vec3(0.0);
        if (mat.beamBoost > 0.0) {
            beam = applyVolLitBeam(s.density, ctx, mat.anisotropy, mat.beamBoost);
        }

        // === Final Color Composition ===
        vec3 color = scatter + emission + ambient + beam;

        return vec4(color * (1.2 - alpha), alpha);
    }
    ```

🔗 [View Source on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/volume_lighting/vol_lit.glsl)

### 3.Volumetric integration
- `integrateCloud`: Performs step-based integration along a ray inside a bounded cloud layer using `applyVolLitCloud`.

??? note "📄 vol_integration.glsl"
    ```glsl
    vec4 integrateCloud(
        vec3 rayOrigin, vec3 rayDir, float rayLength,
        float stepCount, vec3 lightDir, vec3 lightColor, 
        vec3 ambient, VolMaterialParams mat
    ) {
        const float yb = CLOUD_BASE;
        const float yt = CLOUD_TOP;
        float tb = (yb - rayOrigin.y) / rayDir.y;
        float tt = (yt - rayOrigin.y) / rayDir.y;

        float tmin, tmax;
        if (rayOrigin.y > yt) {
            if (tt < 0.0) return vec4(0.0);
            tmin = tt; tmax = tb;
        }
        else if (rayOrigin.y < yb) {
            if (tb < 0.0) return vec4(0.0);
            tmin = tb; tmax = tt;
        }
        else {
            tmin = 0.0;
            tmax = rayLength;
            if (tt > 0.0) tmax = min(tmax, tt);
            if (tb > 0.0) tmax = min(tmax, tb);
        }

        vec4 accum = vec4(0.0);

        vec2 uv = gl_FragCoord.xy / Resolution;
        float jitter = texture(NoiseTex, uv).x;
        float t = tmin + 0.1 * jitter;

        for (int i = 0; i < int(stepCount); ++i) {
            float dt = max(0.05, 0.02 * t);
            vec3 p = rayOrigin + t * rayDir;

            float density = map(p, 5);
            if (density > 0.01) {
                VolumeSample s;
                s.density = density * mat.densityScale;
                s.emission = 0.0;

                VolCtxLocal ctx = createVolCtxLocal(
                    p, -rayDir, lightDir, lightColor, ambient, dt
                );

                vec4 local = applyVolLitCloud(s, ctx, mat);       
                
                accum.rgb += (1.0 - accum.a) * local.a * local.rgb;
                accum.a += (1.0 - accum.a) * local.a;
            }

            t += dt;
            if (t > tmax || accum.a > 0.99) break;
        }

        return clamp(accum, 0.0, 1.0);
    }
    ```

- `integrateFog`: Integrates fog volume using constant step raymarching, suitable for ground-level haze.

??? note "📄 vol_integration.glsl"
    ```glsl
    vec4 integrateFog(
        vec3 rayOrigin, vec3 rayDir, float rayLength,
        float stepCount, vec3 lightDir, vec3 lightColor, 
        vec3 ambient, VolMaterialParams mat
    ) {
        vec4 accum = vec4(0.0);

        float jitter = fract(sin(dot(rayOrigin.xz, vec2(12.9898, 78.233))) * 43758.5453 + iTime);
        float t = 0.1 + 0.2 * jitter;

        for (int i = 0; i < int(stepCount); ++i) {
            float dt = 0.2;
            vec3 p = rayOrigin + t * rayDir;

            float density = FogDensity(p, rayOrigin);
            if (density > 0.001) {
                VolumeSample s;
                s.density = density * mat.densityScale;
                s.emission = 0.0;

                VolCtxLocal ctx = createVolCtxLocal(
                    p, -rayDir, lightDir, lightColor, ambient, dt
                );

                vec4 local = applyVolLitFog(s, ctx, mat);

                accum.rgb += (1.0 - accum.a) * local.a * local.rgb;
                accum.a += (1.0 - accum.a) * local.a;
            }

            t += dt;
            if (t > rayLength || accum.a > 0.99) break;
        }

        return clamp(accum, 0.0, 1.0);
    }
    ```

🔗 [View Source on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/volume_lighting/vol_integration.glsl)

### 4.Occlusion estimation
- `computeCloudOcclusion`: Estimates how much light is blocked by a cloud between a point and a light source.

??? note "📄 vol_occlusion.glsl"
    ```glsl
    float computeCloudOcclusion(vec3 startPos, vec3 lightDir) {
        const float maxDistance = 10.0;  
        const float stepSize = 0.3;  
        const float extinctionScale = 2.0;

        float t = 0.1;                 
        float accumulatedDensity = 0.0;

        for (int i = 0; i < 32; ++i) {
            vec3 samplePos = startPos + t * lightDir;
            float density = map(samplePos, 5); 
            accumulatedDensity += density * stepSize;

            t += stepSize;
            if (t > maxDistance) break;
        }

        float occlusion = 1.0 - exp(-accumulatedDensity * extinctionScale);
        return clamp(occlusion, 0.0, 1.0);
    }
    ```

- `computeFogOcclusion`: Estimates how much light is blocked by fog between a point and a light source.

??? note "📄 vol_occlusion.glsl"
    ```glsl
    float computeFogOcclusion(vec3 startPos, vec3 lightDir, vec3 rayOrigin) {
        const float maxDistance = 8.0; 
        const float stepSize = 0.25;
        const float extinctionScale = 1.2;

        float t = 0.1;
        float accumulatedDensity = 0.0;

        for (int i = 0; i < 32; ++i) {
            vec3 samplePos = startPos + t * lightDir;
            float fogDensity = FogDensity(samplePos, rayOrigin);
            accumulatedDensity += fogDensity * stepSize;

            t += stepSize;
            if (t > maxDistance) break;
        }

        float occlusion = 1.0 - exp(-accumulatedDensity * extinctionScale);
        return clamp(occlusion, 0.0, 1.0);
    }
    ```

🔗 [View Source on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/lighting/volume_lighting/vol_occlusion.glsl)


---
