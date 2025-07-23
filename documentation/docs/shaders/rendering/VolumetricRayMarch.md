#  VolumetricRayMarch

- **Category:** Rendering

- **Author:** Ruimin Ma

- **Shader Type:** Cloud-based volumetric integration using blue-noise dithering

- **Input:** 

  `ro`: Ray origin (world-space camera position)
  
  `rd`: Ray direction (normalized)
  
  `px`: Pixel coordinates (used for blue-noise dither)

---

## 🧠 Algorithm

### 1.`VolumetricRayMarch(vec3 ro, vec3 rd, ivec2 px)`
This function performs volumetric integration along a ray passing through a cloud slab between defined base and top altitudes:

---

1. **Compute ray entry/exit points with the cloud slab:**

$$
t_b = \frac{\text{CLOUD\_BASE} - r_o.y}{r_d.y}, \quad
t_t = \frac{\text{CLOUD\_TOP} - r_o.y}{r_d.y}
$$

The resulting integration segment\( [t_{min}, t_{max}]\) is derived depending on whether the ray starts above, inside, or below the cloud layer.

---

2. **Apply blue-noise dithering to the initial sampling location:**

```glsl
float t = tmin + 0.1 * texelFetch(iChannel1, px & 1023, 0).x;
```

This helps to eliminate visible banding patterns in the rendered cloud.

---

3. **Iteratively sample along the ray** using adaptive step sizes:

- **Step size increases with distance:**

```glsl
float dt = max(0.05, 0.02 * t);
```

- **At each sample point:**

  - Evaluate density via `map(pos, oct)`
  - If `density > 0.01`, accumulate color and opacity using premultiplied alpha:

    $$
    \alpha = \min(\text{clamp}(d, 0, 1) \cdot 8 \cdot dt,\ 1)
    $$

    $$
    \text{color} += \vec{c} \cdot \alpha \cdot (1 - A_{\text{sum}})
    $$

- **Early termination occurs when:**
  - \(t > t_{max}\)
  - or accumulated alpha exceeds `0.99`

---

4. **Return premultiplied result:**

```glsl
return clamp(sum, 0.0, 1.0);
```

---

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `ro` | Ray origin (camera position in world space) | — | Starting point of ray |
| `rd` | Ray direction (normalized) | — | Direction of marching |
| `px` | Pixel coordinates (for dithering via blue-noise texture) | screen resolution | Used to index into `iChannel1` |
| `iChannel1` | External uniform (1024×1024 noise texture) | — | Used for stochastic jitter |
| `CLOUD_BASE` | Lower bound of cloud slab in Y                           | typically < 0     |                                |
| `CLOUD_TOP` | Upper bound of cloud slab in Y                           | typically > 0     |                                |

## 💻 Code
`VolumetricRayMarch` simulates ray marching through a 3D cloud volume. It integrates density-based color and alpha along the ray path using adaptive steps and blue-noise dithering to avoid banding artifacts.

```glsl
#define CLOUD_BASE -3.0
#define CLOUD_TOP  0.6
uniform sampler2D iChannel1;  /* !!!1024 × 1024 single-channel (R) blue-noise or white-noise texture provided by the engine.!!! */

vec4 VolumeticRayMarch(vec3 ro, vec3 rd, ivec2 px) {
    float tb = (CLOUD_BASE - ro.y) / rd.y; 
    float tt = (CLOUD_TOP  - ro.y) / rd.y;

    float tmin, tmax; // integration segment
    if (ro.y > CLOUD_TOP)                   // camera above cloud
    {                                   
        if (tt < 0.0) return vec4(0.0);
        tmin = tt; tmax = tb;
    } 
    else if (ro.y < CLOUD_BASE)             // camera below cloud
    {
        if (tb < 0.0) return vec4(0.0);
        tmin = tb; tmax = tt;
    } 
    else                                    // camera inside cloud slab
    {
        tmin = 0.0;
        tmax = 60.0;
        if (tt > 0.0) tmax = min(tmax, tt);
        if (tb > 0.0) tmax = min(tmax, tb);
    }
    // Add blue-noise dither to the first sample position, helps break up banding artifacts
    float t = tmin + 0.1 * texelFetch(iChannel1, px & 1023, 0).x;
    vec4 sum = vec4(0.0);  // accumulated RGBA (premultiplied)
    const int oct = 5;       // FBM octave count (passed to map)

    for (int i = 0; i < 190; i++) {
        // adaptive step size: finer when close, coarser when fa
        float dt = max(0.05, 0.02 * t);
        vec3 pos = ro + t * rd;
        float den = map(pos, oct); /*!!! Density Function needed, Positive den → cloud/medium density  Negative or zero → empty air!!!*/

        if (den > 0.01) {
            float alpha = clamp(den, 0.0, 1.0);
            vec4 col = vec4(vec3(alpha), alpha);
            col.a = min(col.a * 8.0 * dt, 1.0);
            col.rgb *= col.a;
            sum += col * (1.0 - sum.a);
        }

        t += dt;
        // exit when outside the cloud or nearly opaque
        if (t > tmax || sum.a > 0.99) break;
    }
    // Clamp numeric drift and return premultiplied colour + alpha
    return clamp(sum, 0.0, 1.0);
}

/*
usage example:
    float map(vec3 p, int oct)
    ...
    void mainImage(out vec4 fragColor, in vec2 fragCoord)
    {
        ...
        // volume pass
        vec4 vol = VolumetricRayMarch(ro, rd, ivec2(fragCoord));

        // sky background
        vec3 sky = skyColour(rd);

        // compositing (premultiplied)
        vec3 col = mix(sky, vol.rgb, vol.a);

        fragColor = vec4(col, 1.0);
    } 
*/
```


🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/rendering/volumetric.glsl)
