<div class="container">
    <h1 class="main-heading">Procedural Water Surface Shader</h1>
    <blockquote class="author">by Xuetong Fu</blockquote>
</div>

<img src="../../../static/images/images4Shaders/water_surface.png" alt="Water Surface" width="400" height="225">

---

- **Category:** Scene
- **Shader Type:** Animated water surface with hash noise and SDF raymarching
- **Input Requirements:** `fragCoord`, `iTime`, `iMouse`, `iResolution`, `iChannel0 (noise texture)`
- **Output:**  `fragColor` RGBA color (animated water surface with highlights and depth-based fog)

---

## 🧠 Algorithm

### 🔷 Core Concept
This demo raymarches a signed‑distance field whose height is driven by multi‑octave hash noise to mimic waves.

| Stage | Function | Purpose |
|-------|----------|---------|
| **Wave Height** | `computeWave()` | Generates multi‑octave hash‑noise shaped by a sine function, with time‑varying rotation to create wave patterns. |
| **Distance Field** | `evaluateDistanceField()` | Wraps the signed height from `computeWave()` into a `vec2(dist, matID)` for raymarching (`matID = 5.0` marks water). |
| **Raymarching** | `traceWater()` | Performs up to 128 steps of sphere tracing, stopping early if the distance to the surface is below a small threshold (ε) or the ray exceeds the maximum depth. |
| **Normal Estimate** | computed directly in `mainImage()` | Uses central differences in x and z over the wave height field (and a constant in y) to build the surface‐normal gradient. |
| **Detail & Tint** | `sampleNoiseTexture()` | Samples iChannel0 at four different texture scales to add small ripples and uses the aggregated value to blend between deep and bright water colors. |
| **Lighting** | Fresnel term + view fog | Produces a Fresnel highlight —`(1‑N·V)^5`— for edge‑on sparkle, then fades the water colour with a cubic exponential. |

Result: A moving water surface with dark low waves, bright wave tops, and a camera that can orbit around it.

---
## 🎛️ Parameters

| Name            | Description                                | Range / Unit          | Default |
|-----------------|--------------------------------------------|-----------------------|---------|
| `iTime`         | Global time                                | seconds               | —       |
| `iMouse.xy`     | Yaw / pitch for orbit camera               | pixels (0–`iResolution`)  | (0, 0)  |
| `iResolution`   | Viewport resolution                        | pixels                | —       |
| `iChannel0`     | RG noise texture (uses `.r` only)   | sampler2D             | vec4(0.0) if unbound      |
| `CAMERA_POSITION` | Start pos (world space)                  | vec3                  | (0,2.5,8) |
| `iterationCount` | Octaves in `computeWave()`                | int ≥ 1               | 7       |

To use this shader outside ShaderToy (e.g., in **Unity** or  **Godot**):

- `iTime` → `_Time.y` in Unity / `TIME` in Godot
- `iResolution` → screen resolution vector
- `iChannel0` → supply your own 4-octave noise texture
- `iMouse` → remap to your camera controller input

Make sure to adjust the entry point from `mainImage(out vec4 fragColor, in vec2 fragCoord)` to match your rendering pipeline.

---

## 💻 Shader Code & Includes

### 1. Wave Height Field Function
The `computeWave()` function generates a signed height field using multi-octave hash-based noise combined with time-varying rotation, simulating fractal waveforms. It returns positive values above the surface and negative below. The `evaluateDistanceField()` wraps this into a `vec2(dist, 0.5)`, enabling any 3D point to be evaluated as a signed distance to the water surface—providing a compact SDF for efficient sphere tracing.

```glsl
// ---------- Wave Generation ----------
float computeWave(vec3 pos, int iterationCount, float writeOut) {
    vec3 warped = pos - vec3(0, 0, globalTimeWrapped * 3.0);

    float direction = sin(iTime * 0.15);
    float angle = 0.001 * direction;
    mat2 rotation = computeRotationMatrix(angle);

    float accum = 0.0, amplitude = 3.0;
    for (int i = 0; i < iterationCount; i++) {
        accum += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * (amplitude *= 0.51);
        warped.xy *= rotation;
        warped *= 1.75;
    }

    if (writeOut > 0.0) {
        controlPoint = warped;
        waveStrength = accum;
    }

    float height = pos.y + accum;
    height *= 0.5;
    height += 0.3 * sin(iTime + pos.x * 0.3);  // slight bobbing

    return height;
}

// ---------- SDF Mapping ----------
vec2 evaluateDistanceField(vec3 pos, float writeOut) {
    return vec2(computeWave(pos, 7, writeOut), 5.0);
}
```

### 2. Sphere‑Tracing Function
`traceWater()` marches a ray through the scene using sphere tracing: at each step it queries the SDF for the nearest‑surface distance and “jumps” exactly that far, guaranteeing it never penetrates geometry. The loop terminates when the ray is closer than ε ( 1 × 10⁻⁴ ) to the water surface or when it exceeds a safety depth of 43 units. It returns a packed `vec2(hitDist, matID)` where `matID = 0.0` marks a miss and any non‑zero value identifies water.

```glsl
// ---------- Sphere Tracing ----------
vec2 traceWater(vec3 rayOrigin, vec3 rayDir) {
    vec2 d, hit = vec2(0.1);
    for (int i = 0; i < 128; i++) {
        d = evaluateDistanceField(rayOrigin + rayDir * hit.x, 1.0);
        if (d.x < 0.0001 || hit.x > 43.0) break;
        hit.x += d.x;
        hit.y = d.y;
    }
    if (hit.x > 43.0) hit.y = 0.0;
    return hit;
}
```

### 3. Normal Estimation & Fresnel Highlight
After the ray hits the water surface, we need a surface normal for lighting. Because the water is defined implicitly by an SDF (height field), we approximate the normal with a central‐difference gradient of the same `computeWave()` function. Once the normalized gradient N is known, we compute a view‐dependent Fresnel term `F = (1 − N·V)^5`, producing a realistic glancing‑angle sparkle that is clamped and scaled into a highlight factor.

```glsl
// ---------- Gradient-based normal estimation ----------
vec3 grad = normalize(vec3(
    computeWave(surfacePos + vec3(0.01, 0.0, 0.0), 7, 0.0) - computeWave(surfacePos - vec3(0.01, 0.0, 0.0), 7, 0.0),
    0.02,
    computeWave(surfacePos + vec3(0.0, 0.0, 0.01), 7, 0.0) - computeWave(surfacePos - vec3(0.0, 0.0, 0.01), 7, 0.0)
    ));

// ---------- Fresnel-style highlight ----------
float fresnel = pow(1.0 - dot(grad, -rayDir), 5.0);
float highlight = clamp(fresnel * 1.5, 0.0, 1.0);

```

### **Full Code**

??? note "📄 WaterSurface.glsl"
    ```glsl
    // ---------- Global Configuration ----------
    #define CAMERA_POSITION vec3(0.0, 2.5, 8.0)

    // ---------- Global State ----------
    vec2 offsetA, offsetB = vec2(0.00035, -0.00035), dummyVec = vec2(-1.7, 1.7);
    float waveTime, globalTimeWrapped, noiseBias = 0.0, waveStrength = 0.0, globalAccum = 0.0;
    vec3 controlPoint, rotatedPos, wavePoint, surfacePos, surfaceNormal, texSamplePos;

    // ---------- Utilities ----------
    mat2 computeRotationMatrix(float angle) {
        float c = cos(angle), s = sin(angle);
        return mat2(c, s, -s, c);
    }

    const mat2 rotationMatrixSlow = mat2(cos(0.023), sin(0.023), -cos(0.023), sin(0.023));

    float hashNoise(vec3 p) {
        vec3 f = floor(p), magic = vec3(7, 157, 113);
        p -= f;
        vec4 h = vec4(0, magic.yz, magic.y + magic.z) + dot(f, magic);
        p *= p * (3.0 - 2.0 * p);
        h = mix(fract(sin(h) * 43785.5), fract(sin(h + magic.x) * 43785.5), p.x);
        h.xy = mix(h.xz, h.yw, p.y);
        return mix(h.x, h.y, p.z);
    }

    // ---------- Wave Generation ----------

    float computeWave(vec3 pos, int iterationCount, float writeOut) {
        vec3 warped = pos - vec3(0, 0, globalTimeWrapped * 3.0);

        float direction = sin(iTime * 0.15);
        float angle = 0.001 * direction;
        mat2 rotation = computeRotationMatrix(angle);

        float accum = 0.0, amplitude = 3.0;
        for (int i = 0; i < iterationCount; i++) {
            accum += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * (amplitude *= 0.51);
            warped.xy *= rotation;
            warped *= 1.75;
        }

        if (writeOut > 0.0) {
            controlPoint = warped;
            waveStrength = accum;
        }

        float height = pos.y + accum;
        height *= 0.5;
        height += 0.3 * sin(iTime + pos.x * 0.3);  // slight bobbing

        return height;
    }

    vec2 evaluateDistanceField(vec3 pos, float writeOut) {
        return vec2(computeWave(pos, 7, writeOut), 5.0);
    }

    vec2 traceWater(vec3 rayOrigin, vec3 rayDir) {
        vec2 d, hit = vec2(0.1);
        for (int i = 0; i < 128; i++) {
            d = evaluateDistanceField(rayOrigin + rayDir * hit.x, 1.0);
            if (d.x < 0.0001 || hit.x > 43.0) break;
            hit.x += d.x;
            hit.y = d.y;
        }
        if (hit.x > 43.0) hit.y = 0.0;
        return hit;
    }

    mat3 computeCameraBasis(vec3 forward, vec3 up) {
        vec3 right = normalize(cross(forward, up));
        vec3 camUp = cross(right, forward);
        return mat3(right, camUp, forward);
    }

    vec4 sampleNoiseTexture(vec2 uv, sampler2D tex) {
        float f = 0.0;
        f += texture(tex, uv * 0.125).r * 0.5;
        f += texture(tex, uv * 0.25).r * 0.25;
        f += texture(tex, uv * 0.5).r * 0.125;
        f += texture(tex, uv * 1.0).r * 0.125;
        f = pow(f, 1.2);
        return vec4(f * 0.45 + 0.05);
    }

    // ---------- Main Image ----------
    void mainImage(out vec4 fragColor, in vec2 fragCoord) {
        vec2 uv = (fragCoord.xy / iResolution.xy - 0.5) / vec2(iResolution.y / iResolution.x, 1.0);
        globalTimeWrapped = mod(iTime, 62.83);

        // Orbit camera: yaw/pitch from mouse
        vec2 m = (iMouse.xy == vec2(0.0)) ? vec2(0.0) : iMouse.xy / iResolution.xy;
        float yaw = 6.2831 * (m.x - 0.5);
        float pitch = 1.5 * 3.1416 * (m.y - 0.5);
        float cosPitch = cos(pitch);

        vec3 viewDir = normalize(vec3(
            sin(yaw) * cosPitch,
            sin(pitch),
            cos(yaw) * cosPitch
        ));

        vec3 rayOrigin = CAMERA_POSITION;
        mat3 cameraBasis = computeCameraBasis(viewDir, vec3(0, 1, 0));
        vec3 rayDir = cameraBasis * normalize(vec3(uv, 1.0));

        // Default background color
        vec3 baseColor = vec3(0.05, 0.07, 0.1);
        vec3 color = baseColor;

        // Raymarching
        vec2 hit = traceWater(rayOrigin, rayDir);
        if (hit.y > 0.0) {
            surfacePos = rayOrigin + rayDir * hit.x;

            // Gradient-based normal estimation
            vec3 grad = normalize(vec3(
                computeWave(surfacePos + vec3(0.01, 0.0, 0.0), 7, 0.0) -
                computeWave(surfacePos - vec3(0.01, 0.0, 0.0), 7, 0.0),
                0.02,
                computeWave(surfacePos + vec3(0.0, 0.0, 0.01), 7, 0.0) -
                computeWave(surfacePos - vec3(0.0, 0.0, 0.01), 7, 0.0)
            ));

            // Fresnel-style highlight
            float fresnel = pow(1.0 - dot(grad, -rayDir), 5.0);
            float highlight = clamp(fresnel * 1.5, 0.0, 1.0);

            // Texture detail sampling
            float texNoiseVal = sampleNoiseTexture(controlPoint.xz * 0.0005, iChannel0).r +
                                sampleNoiseTexture(controlPoint.xz * 0.005, iChannel0).r * 0.5;

            // Water shading: deep vs bright
            vec3 deepColor = vec3(0.05, 0.1, 0.2);
            vec3 brightColor = vec3(0.1, 0.3, 0.9);
            float shading = clamp(waveStrength * 0.1 + texNoiseVal * 0.8, 0.0, 1.0);
            vec3 waterColor = mix(deepColor, brightColor, shading);

            // Add highlight
            waterColor += vec3(1.0) * highlight * 0.4;

            // Depth-based fog
            float fog = exp(-0.00005 * hit.x * hit.x * hit.x);
            color = mix(baseColor, waterColor, fog);
        }

        // Gamma correction
        fragColor = vec4(pow(color + globalAccum * 0.2 * vec3(0.7, 0.2, 0.1), vec3(0.55)), 1.0);
    }
    ```

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/WaterSurface.glsl)

---

## Engine Integrations

<div class="button-row">
  <a class="md-button" href="../../../engines/unity/water/waterSurface">Unity</a>
</div>
