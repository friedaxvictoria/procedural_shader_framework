<div class="container">
    <h1 class="main-heading">SDF Animation v2 Example Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/sdf_animation_v2_example.gif" alt="SDF animation v2 example" width="400" height="225">

- **Category:** Animation
- **Inputs:** `fragCoord`, `iTime`, `iResolution`
- **Output:** `fragColor`

---

## 🧠 Algorithm

### 🔷 Core Concept
This shader demonstrates a modular SDF animation system built using `sdf_animation_v2.glsl`.  
It shows how multiple animated objects can be composed using reusable functions like `animateTranslate`, `animateOrbit`, `animatePulseScale`, and `tiePos`.

| Stage              | Function / Code           | Purpose                                          |
|--------------------|---------------------------|--------------------------------------------------|
| **SDF Evaluation** | `evaluateSDF()`           | Calculates signed distance for primitive shapes |
| **Scene Compose**  | `sceneSDF()`              | Animates and colors each object individually     |
| **Raymarching**    | `raymarch()`              | Detects intersections via sphere tracing         |
| **Main Shader**    | `mainImage()`             | Renders result based on ray hit and base color   |

---

## 🎛️ Parameters

| Name         | Description                 | Range / Unit     | Default  |
|--------------|-----------------------------|------------------|----------|
| `iTime`      | Global time                 | seconds          | —        |
| `iResolution`| Viewport resolution         | pixels           | —        |
| `fragCoord`  | Fragment coordinates        | pixels           | —        |

This shader uses flat colors per object (no lighting) and applies sinusoidal, orbital, and pulsing scale animation.

---

## 💻 Shader Code

### 1. SDF Evaluation
Defines signed distance fields for sphere, round box, and torus types.

```glsl
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdRoundBox(vec3 p, vec3 b, float r) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

float evaluateSDF(SDF sdf, vec3 p) {
    if (sdf.type == 0) return sdSphere(p - sdf.position, sdf.radius);
    if (sdf.type == 1) return sdRoundBox(p - sdf.position, sdf.size, sdf.radius);
    if (sdf.type == 2) return sdTorus(p - sdf.position, sdf.size.xy);
    return 1e5;
}
```

### 2. Animation Examples

#### 🔴 Sphere – Sinusoidal Translation

```glsl
SDF sdf1;
sdf1.type = 0;
sdf1.position = vec3(-1.5, 0.0, 0.0);
sdf1.radius = 0.4;
sdf1 = animateTranslate(sdf1, t, vec4(1.0, 0.0, 0.0, 1.5), 1);
```

Moves left/right using `sin(t)` modulation along X axis.  
Color: Red

#### 🟢 Box – Orbiting Around Origin

```glsl
SDF sdf2;
sdf2.type = 1;
sdf2.position = vec3(2.0, 0.0, 0.0);
sdf2.size = vec3(0.3);
sdf2.radius = 0.1;
sdf2 = animateOrbit(sdf2, t, vec4(0.0, 0.0, 0.0, 1.0), vec4(0), 0);
```

Performs orbit around the origin at unit speed.  
Color: Green


#### 🔵 Torus – TIE Path + Pulse Scale

```glsl
SDF sdf3;
sdf3.type = 2;
sdf3.position = tiePos(vec3(1.0), t);
sdf3.size = vec3(0.5, 0.15, 0.0);
sdf3 = animatePulseScale(sdf3, t, vec4(3.0, 0.2, 0.0, 0.0), 2);
```

Moves in a figure-8 path and pulses its size.  
Color: Blue


### 3. Scene Composition

```glsl
SDFResult sceneSDF(vec3 p) {
    float t = iTime;

    // Sphere
    SDF sdf1;
    sdf1.type = 0;
    sdf1.position = vec3(-1.5, 0.0, 0.0);
    sdf1.radius = 0.4;
    sdf1 = animateTranslate(sdf1, t, vec4(1.0, 0.0, 0.0, 1.5), 1);
    float d1 = evaluateSDF(sdf1, p);
    vec3 c1 = vec3(1.0, 0.2, 0.2);

    // Green Round Box – orbits around the origin with radius 2.0
    SDF sdf2;
    sdf2.type = 1;
    sdf2.position = vec3(2.0, 0.0, 0.0);            // initial position on the orbit path
    sdf2.size = vec3(0.3);                          // half-size of the box
    sdf2.radius = 0.1;                              // corner roundness
    sdf2 = animateOrbit(
        sdf2,
        t,
        vec4(0.0, 0.0, 0.0, 1.0),                   // orbit around origin with speed 1.0
        vec4(0),                                    // unused rotation param
        0                                           // linear time mode
    );
    float d2 = evaluateSDF(sdf2, p);
    vec3 c2 = vec3(0.2, 1.0, 0.3);                  // green color


    // Torus
    SDF sdf3;
    sdf3.type = 2;
    sdf3.position = tiePos(vec3(1.0), t);
    sdf3.size = vec3(0.5, 0.15, 0.0);
    sdf3 = animatePulseScale(sdf3, t, vec4(3.0, 0.2, 0.0, 0.0), 2);
    float d3 = evaluateSDF(sdf3, p);
    vec3 c3 = vec3(0.3, 0.5, 1.0);

    // Select closest
    float d = d1;
    vec3 color = c1;
    if (d2 < d) { d = d2; color = c2; }
    if (d3 < d) { d = d3; color = c3; }

    return SDFResult(d, color);
}
```

Selects the closest object and returns its color.  
Used by raymarcher for hit testing and visual result.


### 4. Raymarching

```glsl
float raymarch(vec3 ro, vec3 rd, out vec3 hit, out vec3 color) {
    float d = 0.0;
    for (int i = 0; i < 128; i++) {
        vec3 p = ro + rd * d;
        SDFResult res = sceneSDF(p);
        if (res.dist < 0.001) {
            hit = p;
            color = res.color;
            return d;
        }
        d += res.dist;
        if (d > 100.0) break;
    }
    return -1.0;
}

```

### 5. Final Rendering

```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0.0, 0.0, 10.0);
    vec3 rd = normalize(vec3(uv, -1.5));

    vec3 hit, color;
    float dist = raymarch(ro, rd, hit, color);

    if (dist > 0.0) {
        fragColor = vec4(color, 1.0);  // No shading, pure color
    } else {
        fragColor = vec4(0.0);
    }
}
```

Renders the scene with no lighting, using pure base color from each object.  
Color is determined by the closest hit result.

---

## Note

This shader is a working example of how to animate multiple SDF primitives independently using modular animation functions.  
It demonstrates clean struct-based design, separation of animation logic, and functional composition.

