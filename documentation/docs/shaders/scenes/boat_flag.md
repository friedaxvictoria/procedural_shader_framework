<div class="container">
    <h1 class="main-heading">Boat and Flag Shader</h1>
    <blockquote class="author">by Xuetong Fu</blockquote>
</div>

<img src="../../../static/images/images4Shaders/boat_flag.png" alt="Boat and Flag" width="400" height="225">

---

- **Category:** Scene
- **Shader Type:** raymarch (SDF-based geometry)
- **Input Requirements:** `fragCoord`, `iTime`, `iMouse`, `iResolution`
- **Output:**  `fragColor` RGBA color

---

## 🧠 Algorithm

### 🔷 Core Concept
This shader renders a signed distance field (SDF) scene featuring a boat hull and flagpole using sphere tracing. The model is visualized with orbit camera controls and shaded using pseudo diffuse and rim lighting techniques.

| Stage | Function / Code | Purpose |
|-------|-----------------|---------|
| **Geometry SDF** | `evaluateShip()` | Defines boat hull, pole, and flag via SDF primitives. |
| **Raymarcher** | `raymarch()` | Traces view rays through SDF until a hit or max distance. |
| **Normal Estimate** | `estimateNormal()` | Approximates surface normals using central differences. |
| **Shading Model** | inline in `mainImage()` | Combines base color, pseudo diffuse, and rim lighting for stylized shading. |

Result:  a clear SDF-based preview of a stylized boat with orbit camera control and emphasis on silhouette contours.

---
## 🎛️ Parameters

| Name | Description | Range / Unit | Default |
|------|-------------|--------------|---------|
| `iTime` | Global time | seconds | — |
| `iMouse.xy` | Orbit camera yaw / pitch | pixels (0 – `iResolution`) | (0, 0) |
| `iResolution` | Viewport resolution | pixels | — |
| `CAMERA_DIST` | Camera radius from center | float | 7.0 |
| `MODEL_ROT` | Axis remapping for boat orientation | mat3 | rotates boat to +Z |

To use this shader outside ShaderToy (e.g., in **Unity** or  **Godot**):

- `iTime` → `_Time.y` in Unity / `TIME` in Godot
- `iResolution` → screen resolution vector
- `iChannel1` → supply your own blue-noise texture
- `iMouse` → remap to your camera controller input

Make sure to adjust the entry point from `mainImage(out vec4 fragColor, in vec2 fragCoord)` to match your rendering pipeline.

---

## 💻 Shader Code & Includes

### 1. Boat and Flag SDF Construction
Defines boat hull, waving flag, and pole using SDF operations.

```glsl
vec2 evaluateShip(vec3 worldPos, float time) {
    vec2 result = vec2(1e5, -1.0);

    mat3 modelRot = mat3(
        vec3(1,0,0),
        vec3(0,0,1),
        vec3(0,1,0)
    );
    vec3 localPos = worldPos * modelRot;

    float cose = cos(localPos.y * 0.5);
    float hull = sdfEllipsoidClamped(localPos, 0.48, vec3(cose * 0.75, 2.9, cose));
    hull = abs(hull) - 0.15;
    hull = max(hull, localPos.z - 1.0 + cos(localPos.y * 0.4) * 0.5);
    hull = min(hull, max(length(localPos.xy - vec2(0, 2.6)) - 0.2, abs(localPos.z - 2.3) - 2.7));
    hull *= 0.8;
    result = vec2(hull, 3.0);

    vec3 flagPos = localPos;
    flagPos.y = abs(flagPos.y) - 3.2;
    float flag = length(flagPos) - 0.2;
    if (flag < result.x) result = vec2(flag, 6.0);

    vec3 polePos = localPos - vec3(
        sin(localPos.z * localPos.y * 0.4 + time * 4.0) * max(0.0, localPos.y - 2.5) * 0.2,
        3.6,
        3.8
    );
    float pole = sdfBox(polePos, vec3(0.02, 1.0, 1.0)) * 0.7;
    if (pole < result.x) result = vec2(pole, 6.0);

    return result;
}
```

### 2. Raymarch and Normal Estimation

```glsl
vec2 raymarch(vec3 rayOrigin, vec3 rayDir) {
    float totalDist = 0.0;
    vec2 result = vec2(-1.0);
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 currentPos = rayOrigin + rayDir * totalDist;
        vec2 dist = sceneMap(currentPos);
        if (dist.x < SURF_DIST) {
            result = vec2(totalDist, dist.y);
            break;
        }
        if (totalDist > MAX_DIST) break;
        totalDist += dist.x;
    }
    return result;
}
```

### **Full Code**

??? note "📄 BoatAndFlag.glsl"
    ```glsl
    // ---------- Raymarching Constants ----------
    #define MAX_STEPS 128
    #define MAX_DIST 100.0
    #define SURF_DIST 0.001

    // ---------- SDF Primitives ----------
    float sdfBox(vec3 p, vec3 r) {
        p = abs(p) - r;
        return max(max(p.x, p.y), p.z);
    }

    float sdfEllipsoidClamped(vec3 p, float radius, vec3 bounds) {
        vec3 q = p - clamp(p, -bounds, bounds);
        return length(q) - radius;
    }

    // ---------- Boat + Flag SDF Model ----------
    vec2 evaluateShip(vec3 worldPos, float time) {
        vec2 result = vec2(1e5, -1.0);

        mat3 modelRot = mat3(
            vec3(1,0,0),
            vec3(0,0,1),
            vec3(0,1,0)
        );
        vec3 localPos = worldPos * modelRot;

        float cose = cos(localPos.y * 0.5);
        float hull = sdfEllipsoidClamped(localPos, 0.48, vec3(cose * 0.75, 2.9, cose));
        hull = abs(hull) - 0.15;
        hull = max(hull, localPos.z - 1.0 + cos(localPos.y * 0.4) * 0.5);
        hull = min(hull, max(length(localPos.xy - vec2(0, 2.6)) - 0.2, abs(localPos.z - 2.3) - 2.7));
        hull *= 0.8;
        result = vec2(hull, 3.0);

        vec3 flagPos = localPos;
        flagPos.y = abs(flagPos.y) - 3.2;
        float flag = length(flagPos) - 0.2;
        if (flag < result.x) result = vec2(flag, 6.0);

        vec3 polePos = localPos - vec3(
            sin(localPos.z * localPos.y * 0.4 + time * 4.0) * max(0.0, localPos.y - 2.5) * 0.2,
            3.6,
            3.8
        );
        float pole = sdfBox(polePos, vec3(0.02, 1.0, 1.0)) * 0.7;
        if (pole < result.x) result = vec2(pole, 6.0);

        return result;
    }

    // ---------- Scene Distance Wrapper ----------
    vec2 sceneMap(vec3 p) {
        return evaluateShip(p, iTime);
    }

    // ---------- Surface Normal Approximation ----------
    vec3 estimateNormal(vec3 p) {
        vec2 e = vec2(0.001, 0.0);
        return normalize(vec3(
            sceneMap(p + e.xyy).x - sceneMap(p - e.xyy).x,
            sceneMap(p + e.yxy).x - sceneMap(p - e.yxy).x,
            sceneMap(p + e.yyx).x - sceneMap(p - e.yyx).x
        ));
    }

    // ---------- Sphere Tracing Core ----------
    vec2 raymarch(vec3 rayOrigin, vec3 rayDir) {
        float totalDist = 0.0;
        vec2 result = vec2(-1.0);
        for (int i = 0; i < MAX_STEPS; i++) {
            vec3 currentPos = rayOrigin + rayDir * totalDist;
            vec2 dist = sceneMap(currentPos);
            if (dist.x < SURF_DIST) {
                result = vec2(totalDist, dist.y);
                break;
            }
            if (totalDist > MAX_DIST) break;
            totalDist += dist.x;
        }
        return result;
    }

    // ---------- Main Shader Entry ----------
    void mainImage(out vec4 fragColor, in vec2 fragCoord) {
        vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

        // Mouse-based orbit camera
        vec2 m = (iMouse.xy == vec2(0.0)) ? vec2(0.25 * iResolution.x, 0.5 * iResolution.y) : iMouse.xy;
        vec2 mouseNorm = m / iResolution.xy;

        float yaw = 6.2831 * (mouseNorm.x - 0.5);
        float pitch = 3.1416 * 0.4 * (mouseNorm.y - 0.5);

        vec3 target = vec3(0.0, 1.5, 0.0);
        float cameraDist = 7.0;
        vec3 camPos = target + cameraDist * vec3(
            cos(pitch) * sin(yaw),
            sin(pitch),
            cos(pitch) * cos(yaw)
        );

        vec3 viewDir = normalize(target - camPos);
        vec3 right = normalize(cross(vec3(0, 1, 0), viewDir));
        vec3 up = cross(viewDir, right);
        mat3 cameraBasis = mat3(right, up, viewDir);
        vec3 rayDir = cameraBasis * normalize(vec3(uv, 1.0));

        // Light gray background
        vec3 color = vec3(0.85);

        // Shading logic
        vec2 res = raymarch(camPos, rayDir);
        if (res.x > 0.0) {
            vec3 hitPos = camPos + rayDir * res.x;
            vec3 normal = estimateNormal(hitPos);

            float rim = pow(1.0 - dot(normal, -rayDir), 4.0);
            float pseudoDiffuse = 0.2 + 0.3 * dot(normal, vec3(0, 1, 0));

            vec3 baseColor = vec3(0.3);
            if (res.y == 6.0) baseColor = vec3(0.9, 0.2, 0.2); // flag
            if (res.y == 3.0) baseColor = vec3(0.4, 0.3, 0.2); // boat

            color = baseColor * pseudoDiffuse + vec3(1.0) * rim * 0.8;
        }

        fragColor = vec4(color, 1.0);
    }
    ```

🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/BoatAndFlag.glsl)

---
