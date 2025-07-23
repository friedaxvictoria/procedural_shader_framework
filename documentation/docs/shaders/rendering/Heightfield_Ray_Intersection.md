#  Heightfield Raycast

- **Category:** Rendering

- **Author:** Ruimin Ma

- **Shader Type:** Height-based terrain raymarcher

- **Input:** 

  `ro`: Ray origin (camera position)
  
  `rd`: Ray direction (normalized)
  
  `tmin`: Starting distance along the ray
  
  `tmax`: Maximum raymarch distance

---

## 🧠 Algorithm

### 1.`heightfield_raycast(vec3 ro, vec3 rd, float tmin, float tmax)`
This function iteratively finds the intersection of a ray with a single-valued terrain heightfield defined by `terrainM(xz)`.

---

1. **Initialize raymarching:**

```glsl
float t = tmin;
```

---

2. **Iteratively refine intersection:**

For up to 300 steps:

- **Compute current position:**

$$
\mathbf{p} = \mathbf{ro} + t \cdot \mathbf{rd}
$$

- **Compute height difference:**

$$
h = p_y - \text{terrainM}(p_{xz})
$$

- **Convergence check:**

$$
|h| < 0.0015 \cdot t \quad \text{or} \quad t > t_{\text{max}}
$$

- **Advance step:**

$$
t \leftarrow t + 0.4 \cdot h
$$

---

3. **Return `t` as the hit distance:**

- If \( t \geq t_{max} \): the ray missed the terrain.
- If \( t < t_{max}\): the ray hit the surface.

---

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `ro` | Ray origin (camera position in world space) | — | Starting point of ray |
| `rd` | Ray direction (normalized) | — | Direction of marching |
| `tmin` | Near-plane or terrain entry distance | — | Used to index into `iChannel1` |
| `tmax` | Maximum tracing distance (e.g. far-plane) | — | Defines bounding volume for the search |
| output | Distance to terrain intersection (or ≥ tmax) | —     | Used to test hit vs miss |

## 💻 Code
`heightfield_raycast` finds the first intersection point between a ray and a terrain defined by a height function `terrainM(xz)`. It uses iterative refinement with adaptive steps and returns the distance along the ray to the hit point.

```glsl
float heightfield_raycast(in vec3 ro, in vec3 rd, in float tmin, in float tmax)
{
    float t = tmin;                       // start from tmin

    for (int i = 0; i < 300; i++)
    {
        vec3 pos = ro + t * rd;           // current position along the ray
        float h   = pos.y - terrainM(pos.xz);
                                           // h = current point altitude − terrain height at (x, z)
        // if |h| < 0.0015 * t or t > tmax, stop
        if (abs(h) < (0.0015 * t) || t > tmax)
            break;

        // otherwise advance by 0.4 * h
        t += 0.4 * h;
    }

    return t;
}
/*
Usage example (inside a render function):

float terrainM(vec2 xz) {
    // ... user-defined height field ...
}

vec4 render(in vec3 ro, in vec3 rd)
{
    // 1. Determine ray–terrain bounding distance
    float tmin = 1.0;
    float tmax = FAR_DISTANCE; // some large value or computed from sky plane intersection

    // 2. Call heightfield_raycast to get hit distance
    float t = heightfield_raycast(ro, rd, tmin, tmax);

    vec3 color;
    if (t >= tmax) {
        // no hit → render sky
        color = skyColour(rd);
    } else {
        // hit at t < tmax → render terrain surface
        vec3 pos = ro + rd * t;             // intersection point
        vec3 nor = calcNormalHF(pos);       // compute normal from height field
        color = shadeTerrain(pos, nor, rd); // lighting/material for terrain
    }

    return vec4(color, 1.0);
}
*/
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/rendering/height_field_raycast.glsl)
