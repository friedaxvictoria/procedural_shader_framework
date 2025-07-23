# Ray Marching Function

- **Category:** Rendering

- **Author:** Ruimin Ma

- **Shader Type:** Signed Distance Function based ray traversal

- **Input:** 

  `ro`: world-space ray origin (camera position)

  `rd`: normalized ray direction

---

## 🧠 Algorithm

### 1. `RayMarch(vec3 ro, vec3 rd, out float dist)`
Performs ray marching using Signed Distance Fields (SDF):

- **Step forward along the ray** up to a maximum number of steps (`MAX_STEPS`).
- At each step:
  - Compute the distance from the current point to the closest surface using the `scene()` function.
  - If the distance is less than a small threshold (`SURF_DIST`), consider the surface hit and return `true`.
  - Otherwise, march forward by that distance.
- If the total marched distance exceeds `MAX_DIST`, assume no intersection and return `false`.

---

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `MAX_STEPS` | Step up to MAX_STEPS(100) times. If it hasn't hit the object yet, give up | constant       | Global Parameters                 |
| `MAX_DIST`  | If the light travels a total distance of more than 100 units, it is also considered not to have touched the object. | constant       | Global Parameters                 |
| `SURF_DIST` | If the current distance from the surface of the object is less than SURF_DIST(0.01), it is considered to have touched the surface. | constant       | Global Parameters                 |
| `ro`        | Ray origin (camera position)                                 | —              | world-space camera position       |
| `rd` | Ray direction (normalized) | — | normalized, from camera to object |
| `bool` | true  = surface hit, false = background | — | Output parameter |
| `dist` | Output distance along ray to surface | 0.0 - MAX_DIST | Output parameter |



## 💻 Code
**RayMarch** performs sphere tracing by repeatedly sampling the Signed Distance Field (SDF) along a ray. It returns whether the ray hits a surface and the distance traveled to reach it.

```glsl
#define MAX_STEPS 100 // Step up to 100 times. If it hasn't hit the object yet, give up
#define MAX_DIST 100.0 // If the light travels a total distance of more than 100 units, it is also considered not to have touched the object.
#define SURF_DIST 0.01 //If the current distance from the surface of the object is less than 0.01, it is considered to have touched the surface.

bool RayMarch(vec3 ro, vec3 rd, out float dist) 
{
    float dist = 0.0;                       
    for (int i = 0; i < MAX_STEPS; i++) 
    { 
        vec3 currentPos  = ro + rd * dist;           
        float distToSDF = scene(currentPos);              /* !!! Make sure the SDF for your object is provided through a global function named scene !!! */                         
        if (distToSDF < SURF_DIST) return true;
        dist = dist + distToSDF;
        if (dist > MAX_DIST) break;
    }
    return false;                            
}
/*
usage example:

float dist;
bool hit = RayMarch(ro, rd, dist);

vec3 color = vec3(0.0);
if (hit) {
    vec3 hitPos = ro + rd * dist;
    vec3 n = Normal(hitPos);
    color  = shadeLambert(n, baseColor, lightDir);
}
*/
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/rendering/Ray_Marching.glsl)
