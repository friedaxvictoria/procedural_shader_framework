# 🏔️ Pure Snowy Mountain Shader

<img src="https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/screenshots/Snowy_Mountain.png?raw=true" alt="Snowy Mountain Output" width="400" height="225">

- **Category:** Scene  
- **Author:** Wanzhang He  
- **Shader Type:** Procedural terrain via raymarching and multifractal FBM  
- **Input Requirements:** `fragCoord`, `iResolution`  
- **Output:** Highly detailed snowy mountain scene with choppy ridges and dynamic shading

---

## 📌 Notes

- This shader renders **a procedural snowy mountain** using **multifractal FBM noise** and **warp-based displacement**.
- Terrain is raymarched by solving a custom `terrainHeight()` SDF-like function with choppy, sharp ridges.
- Slope-based blending generates a natural transition between **rock and snow**.
- Includes **soft ambient occlusion**, **diffuse lighting**, **specular highlights**, and **fog** for enhanced realism.
- Uses a **fixed camera** with optional support for mouse-controlled navigation.

---

## 🧠 Algorithm

### 🔷 Core Concept

The mountain scene is built through:

- **Procedural Terrain:** Evaluated with `terrainHeight()` and enhanced using `detailedTerrainHeight()` for normals and AO.
- **Fractal Brownian Motion:** Multi-octave noise with warping, amplitude decay, and frequency increase.
- **Slope-Based Shading:** Rock and snow colors are blended based on the terrain’s slope and elevation.
- **Lighting Model:** Combines diffuse and specular terms using a single directional light.
- **Ambient Occlusion:** Approximate AO based on noise layers and slope contribution.
- **Fog:** Distance and depth-based fog fades terrain into background.
  
---

## 🎛️ Parameters

| Name            | Description                              | Type     | Example            |
|-----------------|------------------------------------------|----------|---------------------|
| `fragCoord`     | Fragment/pixel coordinate                | `vec2`   | Built-in            |
| `iResolution`   | Viewport resolution                      | `vec2`   | uniform             |
| `NUM_STEPS`     | Max number of raymarching steps          | `int`    | `64`                |
| `TERR_HEIGHT`   | Maximum terrain height                   | `float`  | `12.0`              |
| `TERR_FREQ`     | Base terrain frequency                   | `float`  | `0.24`              |
| `TERR_OCTAVE_AMP`| Amplitude decay per octave              | `float`  | `0.58`              |
| `TERR_OCTAVE_FREQ`| Frequency multiplier per octave        | `float`  | `2.5`               |
| `TERR_CHOPPY`   | Controls sharpness of terrain ridges     | `float`  | `1.9`               |

---

## 📦 Function Reference

| Name                    | Description                                                             | Return Type | Example Usage              |
|-------------------------|-------------------------------------------------------------------------|-------------|----------------------------|
| `terrainOctave(uv)`     | Returns FBM octave: height + warp derivatives                           | `vec3`      | `vec3 n = terrainOctave(uv);` |
| `terrainHeight(p)`      | Computes terrain height using multifractal FBM (used in raymarch loop)  | `float`     | `float d = terrainHeight(p);` |
| `detailedTerrainHeight(p)` | High-res terrain for normals and AO                                   | `float`     | `float h = detailedTerrainHeight(p);` |
| `traceTerrain(ori, dir, p, t)` | Raymarches terrain surface; returns hit position and distance     | `bool`      | `if (traceTerrain(...)) {}` |
| `calcNormal(p, eps)`    | Approximates terrain normal from height field sampling                  | `vec3`      | `vec3 n = calcNormal(p, eps);` |
| `calculateTerrainColor(p, n)` | Blends snow and rock colors based on slope and elevation         | `vec3`      | `vec3 col = calculateTerrainColor(p, n);` |
| `calculateAO(p)`        | Approximates ambient occlusion using layered FBM shadowing              | `float`     | `float ao = calculateAO(p);` |
| `calculateDiffuse(n, l, p)` | Computes diffuse lighting term                                    | `float`     | `float d = calculateDiffuse(n, l, 2.0);` |
| `calculateSpecular(n, l, e, s)` | Computes Phong specular term                                 | `float`     | `float s = calculateSpecular(n, l, e, 20.0);` |
| `renderMountain(fragCoord, iResolution)` | Main rendering function for the mountain scene     | `vec3`      | `vec3 col = renderMountain(fragCoord, iResolution);` |

---
## 💻 Shader Code

```glsl
// Rotation matrix
mat3 rotationMatrix(vec3 ang) {
    vec2 a1 = vec2(sin(ang.x), cos(ang.x));
    vec2 a2 = vec2(sin(ang.y), cos(ang.y));
    vec2 a3 = vec2(sin(ang.z), cos(ang.z));
    return mat3(
        a1.y*a3.y+a1.x*a2.x*a3.x, a1.y*a2.x*a3.x+a3.y*a1.x, -a2.y*a3.x,
        -a2.y*a1.x, a1.y*a2.y, a2.x,
        a3.y*a1.x*a2.x+a1.y*a3.x, a1.x*a3.x-a1.y*a3.y*a2.x, a2.y*a3.y
    );
}

// Hash & noise
float hash(vec2 p) {
    uint n = floatBitsToUint(p.x * 122.0 + p.y);
    n = (n << 13U) ^ n;
    n = n * (n * n * 15731U + 789221U) + 1376312589U;
    return uintBitsToFloat((n>>9U) | 0x3f800000U) - 1.0;
}

vec3 noiseDerivatives(in vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);	
    vec2 u = f*f*(3.0-2.0*f);
    
    float a = hash(i + vec2(0.0,0.0));
    float b = hash(i + vec2(1.0,0.0));    
    float c = hash(i + vec2(0.0,1.0));
    float d = hash(i + vec2(1.0,1.0));    
    float h1 = mix(a,b,u.x);
    float h2 = mix(c,d,u.x);
                              
    return vec3(
        abs(mix(h1,h2,u.y)),
        6.0*f*(1.0-f)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx)
    );
}

vec3 terrainOctave(vec2 uv) {
    vec3 n = noiseDerivatives(uv);
    return vec3(pow(n.x, TERR_CHOPPY), n.y, n.z);
}

float terrainHeight(vec3 p) {
    float frq = TERR_FREQ;
    float amp = 1.0;
    vec2 uv = p.xz * frq + TERR_OFFSET;
    vec2 dsum = vec2(0.0);
    
    float h = 0.0;    
    for(int i = 0; i < ITER_GEOMETRY; i++) {          
        vec3 n = terrainOctave((uv - dsum * TERR_WARP) * frq);
        h += n.x * amp;       
        dsum += n.yz * (n.x*2.0-1.0) * amp;
        frq *= TERR_OCTAVE_FREQ;
        amp *= TERR_OCTAVE_AMP;        
        amp *= pow(n.x, TERR_MULTIFRACT);
    }
    h *= TERR_HEIGHT / (1.0 + dot(p.xz,p.xz) * 1e-3);
    return p.y - h;
}

float detailedTerrainHeight(vec3 p) {
    float frq = TERR_FREQ;
    float amp = 1.0;
    vec2 uv = p.xz * frq + TERR_OFFSET;
    vec2 dsum = vec2(0.0);
    
    float h = 0.0;    
    for(int i = 0; i < ITER_FRAGMENT; i++) {        
        vec3 n = terrainOctave((uv - dsum * TERR_WARP) * frq);
        h += n.x * amp;
        dsum += n.yz * (n.x*2.0-1.0) * amp;
        frq *= TERR_OCTAVE_FREQ;
        amp *= TERR_OCTAVE_AMP;
        amp *= pow(n.x, TERR_MULTIFRACT);
    }
    h *= TERR_HEIGHT / (1.0 + dot(p.xz,p.xz) * 1e-3);
    return p.y - h;
}

// Lighting
float calculateDiffuse(vec3 n, vec3 l, float p) { 
    return pow(max(dot(n,l), 0.0), p); 
}

float calculateSpecular(vec3 n, vec3 l, vec3 e, float s) {    
    float nrm = (s + 8.0) / (3.1415 * 8.0);
    return pow(max(dot(reflect(e,n), l), 0.0), s) * nrm;
}

vec3 calculateTerrainColor(in vec3 p, in vec3 n) {
    float slope = 1.0 - dot(n, vec3(0.,1.,0.));     
    vec3 ret = mix(COLOR_SNOW, COLOR_ROCK, smoothstep(0.0, 0.2, slope*slope));
    ret = mix(ret, COLOR_SNOW, clamp(smoothstep(0.6, 0.8, slope+(p.y-TERR_HEIGHT*0.5)*0.05), 0.0, 1.0));
    return ret;
}

float calculateAO(vec3 p) {
    float frq = TERR_FREQ;
    float amp = 1.0;
    vec2 uv = p.xz * frq + TERR_OFFSET;
    vec2 dsum = vec2(0.0);
    
    float h = 1.0;    
    for(int i = 0; i < ITER_FRAGMENT; i++) {        
        vec3 n = terrainOctave((uv - dsum * TERR_WARP) * frq);
        float it = float(i)/float(ITER_FRAGMENT-1);
        float iao = mix(sqrt(n.x), 1.0, it*0.9);
        iao = mix(iao, 1.0, 1.0 - it);
        h *= iao;
        dsum += n.yz * (n.x*2.0-1.0) * amp;
        frq *= TERR_OCTAVE_FREQ;
        amp *= TERR_OCTAVE_AMP;
        amp *= pow(n.x, TERR_MULTIFRACT);
    }
    return sqrt(h*2.0);
}

// Ray tracing
vec3 calcNormal(vec3 p, float eps) {
    vec3 n;
    n.y = detailedTerrainHeight(p);    
    n.x = detailedTerrainHeight(p + vec3(eps, 0, 0)) - n.y;
    n.z = detailedTerrainHeight(p + vec3(0, 0, eps)) - n.y;
    n.y = eps;
    return normalize(n);
}

bool traceTerrain(vec3 ori, vec3 dir, out vec3 p, out float t) {
    t = 0.0;
    for(int i = 0; i < NUM_STEPS; i++) {
        p = ori + dir * t;
        float d = terrainHeight(p);
        if(d < 0.0) return true;
        t += d * 0.6;
    }
    return false;
}

// mountain
vec3 renderMountain(vec2 fragCoord, vec2 iResolution) {
    vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    // fixed camera
    float yaw = -0.15;
    float pitch = 0.1;
    vec3 ang = vec3(pitch, yaw, 0.0);
    mat3 rot = rotationMatrix(ang);

    vec3 ori = vec3(0.0, 5.0, 40.0) * rot;
    vec3 dir = normalize(vec3(uv.xy, -2.0)) * rot;
    dir.z += length(uv) * 0.12;
    dir = normalize(dir);

    ori.y -= terrainHeight(ori) * 0.75 - 3.0;

    vec3 p;
    float t;
    if (!traceTerrain(ori, dir, p, t)) return vec3(0.0);

    vec3 dist = p - ori;
    vec3 n = calcNormal(p, dot(dist, dist) * (1e-1 / iResolution.x));
    float ao = calculateAO(p);
    vec3 col = calculateTerrainColor(p, n);

    col += calculateDiffuse(n, LIGHT_DIR, 2.0) * LIGHT_COLOR;
    col += calculateSpecular(n, LIGHT_DIR, dir, 20.0) * LIGHT_COLOR * 0.4;
    col *= ao;

    float fog = clamp(min(length(dist)*0.018, dot(p.xz, p.xz)*0.001), 0.0, 1.0);
    col = mix(col, vec3(0.0), fog);

    col = (col - 1.0) * 1.2 + 1.0;
    col = pow(col * 0.8, vec3(1.0 / 2.2));

    return col;
}
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 color = renderMountain(fragCoord, iResolution.xy);
    fragColor = vec4(color, 1.0);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/scenes/Snowy_Mountain.glsl)
