<div class="container">
    <h1 class="main-heading">TIE Fighter Animation Shader</h1>
    <blockquote class="author">by Wanzhang He</blockquote>
</div>

<img src="../../../static/images/images4Shaders/tie_fighter.gif" alt="TIE Fighter Animation" width="400" height="225">

- **Category:** Animation 
- **Shader Type:** utility (time-based motion helper)  
- **Input Requirements:** `T` (float, time in 0–40 range)  
- **Output:**  
  - `vec3` from `tiePos(vec3 p, float t)` — fighter position  
  - `ro`, `lookAt` from `getCamera(float T, out vec3 ro, out vec3 lookAt)` — camera path  

---

## 📥 Input Requirements

This shader relies on a **looped time input** `T` ranging approximately from `0` to `40`, which drives both the object and camera animation.

### ⏱ Time Input
- `T` (`float`) – scene time in seconds, typically looped over `[0‥40]`

---

## ✈️ Fighter Animation: `tiePos(vec3 p, float t)`

This function applies stylized, non-linear movement to the TIE Fighter body:

- **Lateral sway**: `cos(t * 0.7)` affects X position  
- **Vertical bob**: `cos(t)` affects Y position  
- **Depth sway**: `sin(t * 1.1)` affects Z position  
- **Roll**: `mat2` rotation applied in the X–Y plane, scaled by `-x * 0.1`

These effects combine into a figure-8–like flight pattern with gentle roll, creating a more cinematic, natural feel.

---

## 🎥 Camera Animation: `getCamera(float T, out vec3 ro, out vec3 lookAt)`

The camera follows the fighter dynamically, with two phases:

1. **Close follow** (0–5s):  
   - `lookAt` targets the animated fighter's position  
   - `ro` (camera origin) is just behind the target

2. **Pull-back transition** (after 5s):  
   - `lookAt` transitions to a fixed point  
   - `ro` moves into an orbiting camera path

This is achieved using `smoothstep(0.0, 5.0, T)` to blend between the two states.

---

## 🧠 Algorithm Summary

| Function       | Purpose                    |
|----------------|----------------------------|
| `tiePos(...)`  | Animate fighter motion     |
| `getCamera(...)` | Animate cinematic camera  |

These are **not part of the general animation system**, but instead define a **scene-specific animation pipeline** for demonstration or cinematic shots.

---

## 💻 Shader Code

```glsl
/** Fighter body motion */
vec3 tiePos(vec3 p, float t)
{
    float x = cos(t * 0.7);
    p += vec3(x, cos(t), sin(t * 1.1));
    p.xy *= mat2(cos(-x*0.1), sin(-x*0.1),
                -sin(-x*0.1), cos(-x*0.1));
    return p;
}

/** Camera path: follow then pull out */
void getCamera(float T, out vec3 ro, out vec3 lookAt)
{
    float t = smoothstep(0.0, 5.0, T);

    lookAt = mix(vec3(0,0,6) - tiePos(vec3(0), T-0.2),
                 vec3(2.5,0,0), t);

    ro = mix(lookAt - vec3(0,0,1),
             vec3(4.0 + cos(T),
                  0.2 * sin(T),
                 -8.0 + 6.0 * cos(T * 0.2)),
             t);
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/animation/TIE%20Fighter_animation.glsl)
