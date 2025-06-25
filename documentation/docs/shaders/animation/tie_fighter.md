# ✈️ TIE Fighter Animation Shader

<img src="../../../static/images/demo_tf.gif" alt="TIE Fighter" width="400" height="225">

- **Category:** Animation
- **Author:** Ruimin Ma
- **Shader Type:** Time-driven animation
- **Input:** `T` — looped time from 0 to 40

---

## 🧠 Algorithm

### 1. `tiePos(vec3 p, float t)`
- Simulates fighter movement:
- Lateral sway (`cos(t * 0.7)`)
- Up/down bobbing (`cos(t)`)
- Depth wobble (`sin(t * 1.1)`)
- Adds slight roll via 2D rotation.

### 2. `getCamera(float T, out vec3 ro, out vec3 lookAt)`
- Smooth camera transition using `smoothstep()`.
- Starts as a follow cam, ends as an orbit cam.

---

 ## 🎛️ Parameters

| Name | Description          | Range | Notes |
|------|-------------------|-------|-------|
| `T` | Looped time input | `0.0 – 40.0` | Required to drive the animation |
| `p` | Fighter body position | — | Used as input to `tiePos` |





## 💻 Code
shader code description here....

```glsl

#ifndef TF_ANIMATION_GLSL
#define TF_ANIMATION_GLSL

/** Fighter body motion */
vec3 tiePos(vec3 p, float t)
{
    float x = cos(t * 0.7);
    p += vec3(x,                  // lateral sway
              cos(t),             // bob up/down
              sin(t * 1.1));      // depth sway
    p.xy *= mat2(cos(-x*0.1), sin(-x*0.1),
                -sin(-x*0.1), cos(-x*0.1)); // slight roll
    return p;
}

/** Camera path: follow lead for 5 s, then pull out. */
void getCamera(float T, out vec3 ro, out vec3 lookAt)
{
    float t = smoothstep(0.0, 5.0, T);          // 0→1 over first 5 seconds

    lookAt = mix(vec3(0,0,6) - tiePos(vec3(0), T-0.2),
                 vec3(2.5,0,0), t);

    ro = mix( lookAt - vec3(0,0,1),             // close follow
              vec3(4.0 + cos(T),
                   0.2 * sin(T),
                  -8.0 + 6.0 * cos(T * 0.2)),   // pulled-out orbit
              t);
}
#endif

```