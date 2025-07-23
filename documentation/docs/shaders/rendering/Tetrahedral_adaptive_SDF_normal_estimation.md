#  Surface Normal Estimation(advanced)

- **Category:** Rendering

- **Author:** Ruimin Ma

- **Shader Type:** Tetrahedral adaptive SDF normal estimation

- **Input:** 

  `pos`: World-space surface hit position
  
  `ray`: Incident ray direction (normalized)
  
  `t`: Hit distance from camera to surface

---

## 🧠 Algorithm

### 1. `calcNormal(vec3 pos, vec3 ray, float t)`
This function computes a surface normal by sampling the Signed Distance Field (SDF) at four off-axis positions around the hit point:

1. **Compute a sampling pitch that grows with the hit distance:**

```glsl
float pitch = 0.5 * t / iResolution.x;
pitch = max(pitch, 0.005);
```

2. **Define a tetrahedral stencil of four offset directions using pitch:**

```glsl
vec3 p0 = pos + vec3(-pitch, -pitch, -pitch);
vec3 p1 = pos + vec3(-pitch, +pitch, +pitch);
vec3 p2 = pos + vec3(+pitch, -pitch, +pitch);
vec3 p3 = pos + vec3(+pitch, +pitch, -pitch);
```

3. **Sample SDF values** at these four positions:

```glsl
float f0 = map(p0).x;
float f1 = map(p1).x;
float f2 = map(p2).x;
float f3 = map(p3).x;
```

4. **Compute weighted gradient using the tetrahedral stencil:**

$$
\mathbf{g} = f_0 \cdot \mathbf{p}_0 + f_1 \cdot \mathbf{p}_1 + f_2 \cdot \mathbf{p}_2 + f_3 \cdot \mathbf{p}_3 - (f_0 + f_1 + f_2 + f_3) \cdot \mathbf{pos}
$$

This formula estimates the SDF gradient vector from the weighted sample positions and values.

5. **Remove the backward-facing component** in the direction of the view ray:

$$
\mathbf{g} = \mathbf{g} - \max(0, \mathbf{g} \cdot \mathbf{ray}) \cdot \mathbf{ray}
$$

This ensures that the normal doesn't point back toward the camera, which could cause shading artifacts.

6. **Normalize the result** to produce the final unit surface normal:

$$
\hat{\mathbf{n}} = \frac{\mathbf{g}}{\|\mathbf{g}\|}
$$

---

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `pos` | World-space hit position | — | SDF value at this point should be close to zero |
| `ray` | Incident ray direction (normalized) | — | Used to remove back-facing gradient component |
| `t` | Hit distance from camera to surface | `>0` | Determines adaptive sampling pitch |
| `pitch` | Adaptive sample offset radius (derived from t) | `>0.005` | Scales with distance; clamped to avoid undersampling |

## 💻 Code
`calcNormal` estimates the surface normal at a hit point using a tetrahedral 4-sample stencil. The sampling radius adapts based on camera distance, improving sharpness close-up and reducing aliasing far away.

```glsl
vec3 calcNormal( vec3 pos, vec3 ray, float t )
{
    float pitch = 0.5 * t / iResolution.x;
    pitch = max(pitch, 0.005);

    vec2 d = vec2(-1.0, 1.0) * pitch;

    vec3 p0 = pos + d.xxx;
    vec3 p1 = pos + d.xyy;
    vec3 p2 = pos + d.yxy;
    vec3 p3 = pos + d.yyx;

    float f0 = map(p0).x;
    float f1 = map(p1).x;
    float f2 = map(p2).x;
    float f3 = map(p3).x;

    vec3 grad = p0*f0 + p1*f1 + p2*f2 + p3*f3
              - pos*(f0 + f1 + f2 + f3);

    grad -= max(0.0, dot(grad, ray)) * ray;

    return normalize(grad);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/rendering/Teteahedral_adaptive_SDF_normal_estimation.glsl)
