<div class="container">
    <h1 class="main-heading">Global Variables in Godot Shaders</h1>
    <blockquote class="author">by Jeewan</blockquote>
</div>

## Overview
In Godot, global variables in shader files (`global_variables.gdshaderinc`) are used to define constants and uniforms that are shared across multiple shader functions or files. These variables provide a centralized way to manage configuration data, such as object properties, camera settings, and rendering parameters, ensuring consistency and modularity in shader code.

### **Constants**
Defined with `const`, these are immutable values (e.g., `MAX_OBJECTS`, `TYPE_SPHERE`) used to set limits or define fixed settings like object types or camera modes. They are compiled into the shader and cannot be changed at runtime.

### **Uniforms**
Defined with `uniform`, these are variables set externally by the Godot engine or scripts (e.g., `lightPosition`, `obj_position`). They allow dynamic configuration of the shader, such as updating object positions or camera parameters per frame.

### **Usage in Godot**
The `global_variables.gdshaderinc` file is included in other shader files (e.g., `helper_function.gdshaderinc`) using `#include`, making its variables accessible throughout the shader pipeline. Uniforms are typically set via a ShaderMaterial in Godot's scene tree, while constants are fixed at compile time. This setup supports flexible rendering, such as ray marching, by providing data for objects, lighting, and camera control.

These variables are critical for the IntegrationFlexible method, enabling it to render SDF objects, water, and desert terrains with dynamic camera animations and lighting effects.


```glsl
const int MAX_OBJECTS = 25;

uniform vec3 lightPosition;

uniform vec3 specularColorFloat[MAX_OBJECTS];
uniform float specularStrengthFloat[MAX_OBJECTS];
uniform float shininessFloat[MAX_OBJECTS];

uniform vec2 screen_resolution;
uniform int inputCount;
uniform int obj_noise[MAX_OBJECTS];
uniform int is_animated[MAX_OBJECTS];

uniform int camera_mode1;
uniform int camera_mode2;
uniform int terrain_mode;
uniform int color_mode;
uniform int animation_mode;

const float F_NO_OF_SEGMENTS=11.0;
const int NO_OF_SEGMENTS=11;

const int TYPE_SPHERE = 0;
const int TYPE_ROUNDED_BOX = 1;
const int TYPE_TORUS = 2;
const int TYPE_DOLPHIN = 3;
const int TYPE_HEX_PRISM=4;
const int TYPE_OCTAHEDRON=5;
const int TYPE_ELLIPSOID=6;

uniform int obj_type[MAX_OBJECTS];
uniform vec3 obj_position[MAX_OBJECTS];
uniform vec3 obj_size[MAX_OBJECTS];
uniform float obj_radius[MAX_OBJECTS];
uniform vec3 obj_color[MAX_OBJECTS];

uniform float obj_speed[MAX_OBJECTS];
uniform vec3 obj_direction[MAX_OBJECTS];
uniform float obj_time_offset[MAX_OBJECTS];
uniform float Tme;

uniform vec3 camera_position;
uniform vec3 look_at_position;
uniform vec4 _mousePoint;
uniform vec4 _ScreenParams;

uniform sampler2D MainTex;
uniform vec2 _Resolution;
uniform vec2 iResolution;
uniform vec2 _Mouse;

const int MOUSE_CONTROL = 0;
const int AUTO_ORBIT = 1;
const int STATIC_CAMERA = 2;
const int BACKANDFORTH=3;
const int SHAKE=4;

uniform float movement_speed;
uniform float shake_intensity;
uniform float shake_speed;
uniform vec3 orbit_axis;
uniform float orbit_speed;
uniform float cycle_speed;
uniform float wave_speed;

const int NONE = 0;
const int WATER = 1;
const int DESERT = 2;

const int STATIC=0;
const int CYCLE_COLOR=1;
const int WAVE_COLOR=2;

const int NO_ANIMATION=0;
const int PULSE_ANIMATION=1;
```

---
## Explanation of Usage

### **Object Management**
- `MAX_OBJECTS`, `obj_type`, `obj_position`, `obj_size`, `obj_radius`, `obj_color`, `obj_speed`, `obj_direction`, `obj_time_offset`, and `is_animated` define properties for up to 25 SDF objects (e.g., spheres, dolphins)
- These are used in `evaluateScene` and `evalSDF` to compute distances and render objects

### **Lighting**
- `lightPosition`, `specularColorFloat`, `specularStrengthFloat`, and `shininessFloat` provide parameters for Phong lighting
- Used in `lightingContext` and `applyPhongLighting_float`

### **Camera Control**
- `camera_position`, `look_at_position`, `_mousePoint`, `_ScreenParams`, `camera_mode1`, `camera_mode2`, `movement_speed`, `shake_intensity`, `shake_speed`, `orbit_axis`, and `orbit_speed` configure camera behavior
- Used in `getCameraMatrix_float` and animation functions like `move_via_mouse_float`

### **Terrain and Effects**
- `terrain_mode`, `color_mode`, `cycle_speed`, `wave_speed`, and terrain constants (`WATER`, `DESERT`) control water and desert rendering
- Used in `traceWater` and `traceDesert`

### **General Rendering**
- `screen_resolution`, `_Resolution`, `iResolution`, and `MainTex` support UV transformations and texture sampling
- `Tme` drives time-based animations

### **Constants**
- `TYPE_*`, `MOUSE_CONTROL`, `STATIC`, etc., define enumerated values for object types, camera modes, and animation modes
- Ensure consistent logic across functions

## Integration

These variables are set via Godot's ShaderMaterial properties or scripts, enabling dynamic updates (e.g., object positions, time) while constants ensure fixed configurations (e.g., maximum object count). They integrate seamlessly with the IntegrationFlexible method to render a complex, animated 3D scene using ray marching.