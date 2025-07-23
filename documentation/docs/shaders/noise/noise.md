
<div class="container">
    <h1 class="main-heading">Noise Shader Collection</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

- **Category:** Noise
- **Shader Type:** noise functions
- **Input Requirements:** `float`, `vec2`, `vec3`, `time`

---

## 🧠 Algorithm

### 🔷 Core Concept

This shader module combines multiple fundamental noise generation methods into a single file.  
It depends on `hash.glsl` and provides both classic and advanced procedural noise techniques:

- `noise(float)` — 1D interpolated value noise  
- `noise(vec2)` — 2D grid-based value noise  
- `Pseudo3dNoise(vec3)` — 2D gradient noise animated over time (pseudo-3D)  
- `n31(vec3)` — 3D → 1D value noise using Shane’s hash44 technique  
- `voronoi(vec2, float)` — 2D Voronoi cell noise with adjustable distortion

These functions support animation, spatial structure, and fractal combination.

---

## 🎛️ Parameters

| Name         | Description                           | Type     | Range         | Example     |
|--------------|---------------------------------------|----------|---------------|-------------|
| `x`          | Input for 1D value noise              | `float`  | –             | `0.5`       |
| `uv`         | Input for 2D value noise or voronoi   | `vec2`   | UV range      | `vec2(0.3)` |
| `pos`        | Input for 3D value or pseudo noise    | `vec3`   | –             | `vec3(x,y,t)`|
| `distortion` | Voronoi distortion factor             | `float`  | `[0.0, 1.0]`  | `0.8`       |

---

## 💻 Shader Code & Includes

### 1. Overview & Includes
```glsl
#include "shaders/noise/noise.glsl"

float n1 = noise(uv);                    // 2D value noise
float n2 = Pseudo3dNoise(vec3(uv, t));   // animated pseudo-3D noise
float n3 = n31(vec3(x, y, z));           // 3D-to-1D value noise
vec2 v  = voronoi(uv, 0.5);              // Voronoi result: (colorID, borderDist)
```
### 2. 1D value noise

Interpolated 1D value noise based on the fractional position of `x`.

- `x`: 1D coordinate  
- Returns a smooth pseudo-random float in `[0, 1]`  
- Uses Hermite interpolation between `hash(floor(x))` and `hash(floor(x)+1)`
  
```glsl
float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}
```
### 3. 2D value noise

Interpolated 2D value noise based on surrounding hashed corners.

- `x`: 2D coordinate  
- Returns a smooth pseudo-random float in `[0, 1]`  
- Uses bilinear interpolation across 4 corners with `hash(vec2)`
  
```glsl
float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}
```

### 4. Generates gradient vector for Perlin-style noise

Generates a pseudo-random unit gradient vector for Perlin-style noise.

- `intPos`: Grid cell integer coordinate  
- `t`: Time parameter for animation  
- Returns a unit-length direction vector  
- Used internally by `Pseudo3dNoise(...)`
  
```glsl
vec2 GetGradient(vec2 intPos, float t) {
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return vec2(cos(angle), sin(angle));
}
```

### 5. Pseudo-3D noise

Implements a Perlin-style gradient noise by interpolating time-varying 2D gradient contributions.

- `pos.xy`: Spatial coordinate  
- `pos.z`: Time variable  
- Returns float noise in `[-1, 1]`  
- Implements Perlin-style interpolation over animated gradients
  
```glsl
float Pseudo3dNoise(vec3 pos) {
    vec2 i = floor(pos.xy);
    vec2 f = fract(pos.xy);
    vec2 blend = f * f * (3.0 - 2.0 * f);

    float a = dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0.0, 0.0));
    float b = dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1.0, 0.0));
    float c = dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0.0, 1.0));
    float d = dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1.0, 1.0));

    float xMix = mix(a, b, blend.x);
    float yMix = mix(c, d, blend.x);
    return mix(xMix, yMix, blend.y) / 0.7; // Normalize
}
```

### 6. 3D → 1D Value Noise

Compact, high-frequency value noise using hash44.

- `p`: 3D position  
- Returns noise in `[0, 1]`  
- Uses Hermite interpolation and `hash44` for corner values  
- Useful for fast small-scale variation like rocks or textures
  
```glsl
float n31(vec3 p) {
    const vec3 S = vec3(7.0, 157.0, 113.0); // step vector: pairwise-prime
    vec3 ip = floor(p);
    p = fract(p);
    p = p * p * (3.0 - 2.0 * p); // Hermite smoother

    vec4 h = vec4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    h = mix(hash44(h), hash44(h + S.x), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}
```

### 7. Voronoi-style cell noise

Voronoi-style cell noise pattern with configurable randomness.

- `pos`: Position to sample  
- `distortion`: Range `[0, 1]`, higher values = more irregular cells  
- Returns `vec2(colorIndex, distanceToBorder)`  
- Good for cell outlines, stylized shading, organic textures
  
```glsl
vec2 voronoi(in vec2 pos, float distortion) {
    vec2 cell = floor(pos);
    vec2 cellOffset = fract(pos);
    float borderDist = 8.0;
    float color;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 samplePos = vec2(float(y), float(x));
            vec2 center = rand2(cell + samplePos) * distortion;
            vec2 r = samplePos - cellOffset + center;
            float d = dot(r, r);
            float col = rand(cell + samplePos);

            if (d < borderDist) {
                borderDist = d;
                color = col;
            }
        }
    }

    borderDist = 8.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 samplePos = vec2(float(i), float(j));
            vec2 center = rand2(cell + samplePos) * distortion;
            vec2 r = samplePos + center - cellOffset;

            if (dot(r, r) > 0.000001) {
                borderDist = min(borderDist, dot(0.5 * r, normalize(r)));
            }
        }
    }

    return vec2(color, borderDist);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/noise/noise.glsl)
