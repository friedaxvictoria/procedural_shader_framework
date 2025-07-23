<div class="container">
    <h1 class="main-heading">Noise System Shader</h1>
    <blockquote class="author">by Saeed Shamseldin</blockquote>
</div>

<img src="../../../static/images/images4Shaders/noise_SDFs.png" alt="general scene" width="500" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
---

## Overview
The noise system in this shader provides procedural pattern generation for textures, terrain, and effects. It includes some noise algorithms that integrate seamlessly with the SDF geometry and lighting systems to create organic, dynamic visuals.

## Example Noise Function

### Fractal Brownian Motion (fbmPseudo3D)
```glsl
void fbmPseudo3D(vec3 p, int octaves, out float result) {
    result = 0.0;
    float amp = 0.5, freq = 1.0;
    for (int i = 0; i < octaves; ++i) {
        float noise;
        Pseudo3dNoise(p * freq, noise);
        result += amp * noise;
        freq *= 2.0; amp *= 0.5; // Higher frequency, lower amplitude
    }
}
```

- **Purpose**: Adds detail by layering noise at multiple frequencies.

- **Parameters**:
    - **octaves**: Number of layers (typically 3–6).
    - **p**: Input coordinate.

---


## Integration with Other Systems
### Raymarching (SDF Perturbation)
Noise modifies SDF distances to create natural imperfections:

```glsl
float d = evaluateScene(p) + fbmPseudo3D(p, 3) * 0.3; // Adds surface detail
```
---

You can find different noise functions in the [noise shaders](../shaderPage.md#️-noise-shaders)