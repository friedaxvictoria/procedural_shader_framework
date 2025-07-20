# 🎥 Modular Camera Animation Shader

- **Category:** Animation
- **Author:** Wanzhang He  
- **Input Requirements:** `time`, `CameraAnimParams`  
- **Output:** `CameraState` (eye, target, up) used for view matrix setup  

---

## 📌 Notes

- This module provides a **modular and reusable camera animation system** for raymarching / SDF-based scenes.  
- It supports multiple camera animation modes:  
  - `0`: Static  
  - `1`: Orbit  
  - `2`: Ping-pong  
  - `3`: First-person  
- Designed for **plug-and-play integration** into main SDF rendering pipeline.

---

## 🧠 Algorithm
### 🔄 Core Concept

- The main function `animate_camera()` computes a time-varying camera state based on:  
  - Current time  
  - Speed and offset  
  - Chosen animation mode  
- The helper `get_camera_matrix()` constructs a **view-space matrix** from the camera state:
  - Forward vector is `target - eye`
  - Right vector is orthogonal to forward & up
  - Matrix is returned in **column-major** `[right, up, -forward]` order

---

## 🎛️ Parameters

| Name       | Description                         | Type     | Example            |
|------------|-------------------------------------|----------|---------------------|
| `mode`     | Animation mode (0–3)                | `int`    | `1` (orbit)         |
| `speed`    | Playback speed multiplier           | `float`  | `1.0`               |
| `offset`   | Time offset                         | `float`  | `0.0`               |
| `center`   | Point to look at                    | `vec3`   | `vec3(0)`           |
| `radius`   | Orbit or movement radius            | `float`  | `5.0`               |

### 🧭 Camera Modes

| Mode | Behavior                       | Motion Axis    |
|------|--------------------------------|----------------|
| 0    | Static                         | -              |
| 1    | Orbit around center            | Y-axis         |
| 2    | Ping-pong back and forth       | Z-axis         |
| 3    | First-person forward movement  | X-axis         |

### 🧱 Data Structures

#### `struct CameraState`

| Field     | Type   | Description               |
|-----------|--------|---------------------------|
| `eye`     | `vec3` | Camera position (origin)  |
| `target`  | `vec3` | Look-at target position   |
| `up`      | `vec3` | Upward vector direction   |

#### `struct CameraAnimParams`

| Field     | Type    | Description                         |
|-----------|---------|-------------------------------------|
| `mode`    | `int`   | Animation mode (0–3)                |
| `speed`   | `float` | Playback speed                      |
| `offset`  | `float` | Time offset                         |
| `center`  | `vec3`  | Target center for orbit/ping-pong   |
| `radius`  | `float` | Orbit radius / movement amplitude   |

### 📐 Functions

#### `mat3 get_camera_matrix(CameraState cam)`

Builds a **view direction matrix** based on camera state:  
- `right`, `up`, `-forward` are returned in **column-major** order.  
- Can be used to transform rays to camera space.

#### `CameraState animate_camera(float time, CameraAnimParams param)`

Returns an animated `CameraState` based on time and selected mode.

---
## 💻 Shader Code
```glsl
struct CameraState {
    vec3 eye;
    vec3 target;
    vec3 up;
};

struct CameraAnimParams {
    int mode;
    float speed;
    float offset;
    vec3 center;
    float radius;
};

mat3 get_camera_matrix(CameraState cam) {
    vec3 f = normalize(cam.target - cam.eye);
    vec3 r = normalize(cross(f, cam.up));
    vec3 u = cross(r, f);
    return mat3(r, u, -f);
}

CameraState animate_camera(float time, CameraAnimParams param) {
    CameraState cam;
    float t = time * param.speed + param.offset;

    if (param.mode == 0) {
        cam.eye = vec3(0.0, 2.0, 5.0);
        cam.target = param.center;
    } else if (param.mode == 1) {
        cam.eye = vec3(sin(t), 1.5, cos(t)) * param.radius;
        cam.target = param.center;
    } else if (param.mode == 2) {
        cam.eye = vec3(0.0, 1.5, sin(t) * param.radius + 5.0);
        cam.target = param.center;
    } else if (param.mode == 3) {
        cam.eye = vec3(t * param.radius, 1.0, 0.0);
        cam.target = cam.eye + vec3(0.0, 0.0, -1.0);
    } else {
        cam.eye = vec3(0.0, 1.5, 5.0);
        cam.target = param.center;
    }

    cam.up = vec3(0.0, 1.0, 0.0);
    return cam;
}
```
🔗 [View Full Shader Code on GitHub](https://github.com/friedaxvictoria/procedural_shader_framework/blob/main/shaders/shaders/animation/camera_anim.glsl)
