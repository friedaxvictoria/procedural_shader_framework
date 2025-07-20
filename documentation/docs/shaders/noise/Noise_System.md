# Noise System Shader

<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added -->

<!-- this is for locally stored images -->
<!-- <img src="image directory stored locally inside project" alt="TIE Fighter" width="400" height="225"> -->
<!-- this is for external  link  -->
<!-- <img src="https://......." width="400" alt="TIE Fighter Animation"> -->



<!-- this is for locally stored videos -->
<!-- <video controls width="640" height="360" > -->
  <!-- <source src="video path stored locally" type="video/mp4"> -->
  <!-- Your browser does not support the video tag. -->
<!-- </video> -->

<!-- this is for external link, copy the embed code for given video and paste it here -->
<!-- <iframe width="640" height="360"  -->
  <!-- src="https://www.youtube.com/embed/VIDEO_ID" 
  title="TIE Fighter Shader Demo"
  frameborder="0" allowfullscreen></iframe> -->



<div class="container">
    <h1 class="main-heading">
    <blockquote class="author">by Saeed Shamseldin</blockquote>
    </h1>
</div> 

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