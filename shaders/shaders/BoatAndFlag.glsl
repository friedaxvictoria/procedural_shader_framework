// ==========================================
// Shader: Boat and Flag SDF Viewer
// Author: Xuetong Fu
// Category: Modeling & Orbit Camera Visualization
// Description: Renders a 3D boat and flag model using SDF raymarching with rim lighting and orbit controls.
// Screenshot: screenshots/BoatAndFlag.png
// ==========================================

/*
 * This shader visualizes a boat and flag composed with signed distance functions (SDFs).
 * It includes orbit camera control using the mouse and applies pseudo-lighting techniques for silhouette clarity.
 *
 * Main Components:
 * - evaluateShip(): Defines the boat and flag geometry using SDF primitives.
 * - estimateNormal(): Approximates normals for shading.
 * - raymarch(): Performs sphere tracing to locate surface intersections.
 * - mainImage(): Controls camera setup, shading, and output.
 *
 * Visual Features:
 * - Pseudo diffuse shading and rim lighting for non-photorealistic clarity
 * - Mouse-controlled orbit camera with side-view default
 * - Light gray background for strong silhouette contrast
 *
 * Notes:
 * - Scene is centered at origin, aligned so the boat faces +Z
 * - Designed for geometry preview and modular reuse
 */

// ---------- Raymarching Constants ----------
#define MAX_STEPS 128
#define MAX_DIST 100.0
#define SURF_DIST 0.001

// ---------- SDF Primitives ----------

// Box SDF
float sdfBox(vec3 p, vec3 r) {
    p = abs(p) - r;
    return max(max(p.x, p.y), p.z);
}

// Ellipsoid clipped inside a box
float sdfEllipsoidClamped(vec3 p, float radius, vec3 bounds) {
    vec3 q = p - clamp(p, -bounds, bounds);
    return length(q) - radius;
}

// ---------- Boat + Flag SDF Model ----------

/*
 * Evaluate combined boat and flag SDF
 * 
 * Input:
 *   worldPos - vec3 : point to evaluate in world space
 *   time     - float: current time for flag animation
 *
 * Output:
 *   vec2 : (signed distance, material id)
 *          id = 3 (boat), 6 (flag)
 */
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

/*
 * Finite difference normal estimation
 */
vec3 estimateNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        sceneMap(p + e.xyy).x - sceneMap(p - e.xyy).x,
        sceneMap(p + e.yxy).x - sceneMap(p - e.yxy).x,
        sceneMap(p + e.yyx).x - sceneMap(p - e.yyx).x
    ));
}

// ---------- Sphere Tracing Core ----------

/*
 * Basic sphere tracing to intersect SDF geometry
 */
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
