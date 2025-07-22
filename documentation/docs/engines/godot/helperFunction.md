<div class="container">
    <h1 class="main-heading">Helper Functions</h1>
    <blockquote class="author">by Jeewan</blockquote>
</div>
This document provides a detailed analysis of the helper functions defined in the `helper_function.gdshaderinc` 
file, which are crucial for supporting the IntegrationFlexible method in a Godot shader. These functions handle
 tasks such as camera setup, animation, lighting, UV coordinate transformation, and object color/effect modifications.

The helper functions are included from 
`addons/includes/helper_functions/helper_function.gdshaderinc` 
and rely on global variables defined in
 `addons/includes/global_variables/global_variables.gdshaderinc`.

Each function is explained with its purpose, inputs/outputs, process, and code implementation, covering the role of each function in the ray marching and scene rendering pipeline.

## **Lighting Functions**

### 1. lightingContext
**Purpose**: Computes standard lighting context for hit points in the scene, providing vectors and colors for Phong lighting calculations.

**Input/Output**:

- **Input**: `hitPos` (vec3), `cameraPos` (vec3)
- **Output**: `viewDir`, `lightDir`, `lightColor`, `ambientColor`

**Process**: Calculates view and light directions, sets white light color and dim ambient lighting (0.1).

```glsl
void lightingContext(vec3 hitPos, vec3 cameraPos, out vec3 viewDir, out vec3 lightDir, out vec3 lightColor, out vec3 ambientColor) {
    viewDir = normalize(cameraPos - hitPos); // Use the actual camera position
    lightDir = normalize(lightPosition - hitPos);
    lightColor = vec3(1.0, 1.0, 1.0);
    ambientColor = vec3(0.1, 0.1, 0.1);
}
```

### 2. desertLightingContext
**Purpose**: Specialized lighting context for desert surfaces with warm, natural appearance.

**Input/Output**:

- **Input**: `hitPos` (vec3), `cameraPos` (vec3)
- **Output**: `viewDir`, `lightDir`, `lightColor`, `ambientColor`

**Process**: Similar to lightingContext but with warm light tint and blue-sky ambient for desert environments.

```glsl
void desertLightingContext(vec3 hitPos, vec3 cameraPos, out vec3 viewDir, out vec3 lightDir, out vec3 lightColor, out vec3 ambientColor) {
    viewDir = normalize(cameraPos - hitPos);
    lightDir = normalize(lightPosition - hitPos);
    lightColor = vec3(1.1, 1.05, 0.95);
    ambientColor = vec3(0.6, 0.7, 0.8);
}
```

## **Camera and Coordinate Functions**

### 3. computeUV_float

**Purpose**: Converts Godot's normalized UV coordinates to screen-space coordinates for ray marching with aspect ratio correction and Y-axis flipping.

**Input/Output**:

- **Input**: `INuv` (vec2) - normalized UV coordinates
- **Output**: `uv` (vec2) - transformed NDC coordinates

**Process**: Converts to pixel coordinates, normalizes to [-1,1], flips Y-axis, applies aspect ratio correction.

```glsl
void computeUV_float(vec2 INuv, out vec2 uv) {
    vec2 fragCoord = INuv * screen_resolution;
    uv = fragCoord / screen_resolution.xy * 2. - 1.;
    uv.y = -uv.y; // Flip Y axis
    uv.x *= screen_resolution.x / screen_resolution.y;
}
```

### 4. compute_rotation_matrix
**Purpose**: Creates 3x3 rotation matrix using Rodrigues' rotation formula for object/camera rotation around specified axis.

**Input/Output**:

- **Input**: `axis` (vec3), `angle` (float)
- **Output**: Returns mat3 rotation matrix

**Process**: Uses trigonometric values and axis components to build column-major rotation matrix.

```glsl
mat3 compute_rotation_matrix(vec3 axis, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    float one_minus_c = 1.0 - c;

    vec3 col0 = vec3(
        c + axis.x * axis.x * one_minus_c,
        axis.y * axis.x * one_minus_c + axis.z * s,
        axis.z * axis.x * one_minus_c - axis.y * s
    );

    vec3 col1 = vec3(
        axis.x * axis.y * one_minus_c - axis.z * s,
        c + axis.y * axis.y * one_minus_c,
        axis.z * axis.y * one_minus_c + axis.x * s
    );

    vec3 col2 = vec3(
        axis.x * axis.z * one_minus_c + axis.y * s,
        axis.y * axis.z * one_minus_c - axis.x * s,
        c + axis.z * axis.z * one_minus_c
    );

    return mat3(col0, col1, col2); // Column-major
}
```

### 5. compute_camera_basis
**Purpose**: Computes camera orientation matrix (right, up, -forward) given camera position and target.

**Input/Output**:

- **Input**: `look_at_pos` (vec3), `eye` (vec3), `mat` (mat3)
- **Output**: Returns mat3 camera orientation matrix

**Process**: Calculates forward, right, and up vectors using cross products to create orthonormal basis.

```glsl
mat3 compute_camera_basis(vec3 look_at_pos, vec3 eye, mat3 mat) {
    vec3 f = normalize(look_at_pos - eye);            // Forward
    vec3 r = normalize(cross(f, vec3(0.0, 1.0, 0.0))); // Right
    vec3 u = cross(r, f);                              // Up
    return mat3(r, u, -f); // Column-major matrix for camera orientation
}
```
Note: It is being used inside get_camera_matrix() to update camera related transformations.

### 6. getCameraMatrix_float
**Purpose**: Combines animation matrices and computes final camera orientation and position for ray marching.

**Input/Output**:

- **Input**: `matrix1` (mat3), `matrix2` (mat3), `distance` (float), `lookAtPos` (vec3)
- **Output**: `camMatrix` (mat3), `rayOrigin` (vec3)

**Process**: Multiplies matrices, positions camera at distance, computes orientation using camera basis.

```glsl
void getCameraMatrix_float(mat3 matrix1, mat3 matrix2, float distance, vec3 lookAtPos, out mat3 camMatrix, out vec3 rayOrigin) {
    mat3 combinedMat = matrix1 * matrix2;
    rayOrigin = (vec3(0.0, 0.0, distance) * combinedMat);
    camMatrix = compute_camera_basis(lookAtPos, rayOrigin, combinedMat);
}
```
Note: This function need to be always called after each camera related animation.

## **Camera Animation Functions**

### 7. move_via_mouse_float
**Purpose**: Mouse-controlled camera rotation for interactive scene exploration.

**Input/Output**:

- **Input**: None (uses global mouse and screen parameters)
- **Output**: `mat` (mat3) - rotation matrix

**Process**: Maps mouse coordinates to yaw/pitch angles, combines Y and X rotations.

```glsl
void move_via_mouse_float(out mat3 mat) {
    vec2 mouse = _mousePoint.xy / _ScreenParams.xy;

    float angle_y = mix(-PI, PI, mouse.x);
    float angle_x = -PI * mouse.y;

    mat3 rot_y = compute_rotation_matrix(vec3(0.0, 1.0, 0.0), angle_y);
    mat3 rot_x = compute_rotation_matrix(vec3(1.0, 0.0, 0.0), angle_x);

    mat = rot_y * rot_x;
}
```

### 8. orbitY_float
**Purpose**: Automatic camera orbiting around specified axis at given speed.

**Input/Output**:

- **Input**: `axis` (vec3), `speed` (float)
- **Output**: `mat` (mat3) - rotation matrix

**Process**: Uses time and speed to create continuous rotation around normalized axis.

```glsl
void orbitY_float(vec3 axis, float speed, out mat3 mat) {
    float angle = Tme * speed;
    mat = compute_rotation_matrix(normalize(axis), angle);
}
```

### 9. backAndForth_scale_float
**Purpose**: Oscillating scale effect for zoom animation, creating back-and-forth zooming.

**Input/Output**:

- **Input**: `speed` (float)
- **Output**: `animationMatrix` (mat3) - scaling matrix

**Process**: Uses sine function to scale between 0.5 and 2.0, creating pulsing effect.

```glsl
void backAndForth_scale_float(float speed, out mat3 animationMatrix) {
    float t = Tme * speed;
    float scale = abs(sin(t)) * 1.5 + 0.5; // Scale between 0.5 and 2.0
    animationMatrix = mat3(
        vec3(scale, 0.0, 0.0),
        vec3(0.0, scale, 0.0),
        vec3(0.0, 0.0, scale)
    );
}
```

### 10. backAndForth_translate_float
**Purpose**: Oscillating translation along Z-axis for back-and-forth movement.

**Input/Output**:

- **Input**: `speed` (float)
- **Output**: `offset` (vec3) - translation vector

**Process**: Creates ±3 unit oscillation along Z-axis using sine function.

```glsl
void backAndForth_translate_float(float speed, out vec3 offset) {
    float t = Tme * speed;
    offset = vec3(0.0, 0.0, sin(t) * 3.0); // Move ±3 units along Z
}
```

### 11. shake_matrix_float
**Purpose**: Camera shake effect with random position offsets, simulating jittery motion.

**Input/Output**:

- **Input**: `intensity` (float), `speed` (float)
- **Output**: `shakeMatrix` (mat3), `positionOffset` (vec3)

**Process**: Uses hash function to generate random XYZ offsets, identity matrix for no rotation.

```glsl
void shake_matrix_float(float intensity, float speed, out mat3 shakeMatrix, out vec3 positionOffset) {
    float t = Tme * speed;
    float px = hash11(t + 1.1) - 0.5;
    float py = hash11(t + 2.3) - 0.5;
    float pz = hash11(t + 3.7) - 0.5;
    shakeMatrix = mat3(1.0); // Identity matrix
    positionOffset = vec3(px, py, pz) * intensity;
}
```

### 12. hash11
**Purpose**: Pseudo-random float generator for noise effects like camera shake.

**Input/Output**:

- **Input**: `p` (float) - seed value
- **Output**: Returns float in [0,1] range

**Process**: Uses sine-based hash with large multiplier and fractional part.

```glsl
float hash11(float p) {
    return fract(sin(p * 17.23) * 43758.5453);
}
```

## **Color and Animation Effects**

### 13. cycleColor_float
**Purpose**: Hue-shifting color animation, creating cycling color effects over time.

**Input/Output**:

- **Input**: `speed` (float), `color` (vec3) - inout parameter
- **Output**: Modified color with cycling hue

**Process**: Converts time to hue, applies HSV-to-RGB conversion, multiplies with base color.

```glsl
void cycleColor_float(float speed, inout vec3 color) {
    float t = Tme * speed;
    float hue = fract(t);
    vec3 hsv = vec3(hue, 1.0, 1.0);
    vec3 rgb = clamp(abs(fract(hsv.x + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
    vec3 cycleRGB = hsv.z * mix(vec3(1.0), rgb, hsv.y);
    color = color * cycleRGB;
}
```

### 14. changingColorSin_float
**Purpose**: Sinusoidal color modulation, creating wave-like color change effects.

**Input/Output**:

- **Input**: `speed` (float), `color` (vec3) - inout parameter
- **Output**: Modified color with wave effect

**Process**: Transforms color using asin, applies time-dependent sine oscillation.

```glsl
void changingColorSin_float(float speed, inout vec3 color) {
    vec3 rootColor = asin(2.0 * color - 1.0);
    color = 0.5 + 0.5 * sin(Tme * speed * rootColor);
}
```

### 15. pulseObject_float
**Purpose**: Pulsing scale animation for objects, simulating breathing or throbbing effects.

**Input/Output**:

- **Input**: `seedSize` (vec3), `seedRadius` (float), `freq` (float), `amp` (float), `mode` (int)
- **Output**: `size` (vec3), `radius` (float)

**Process**: Applies time mode modification, uses sine function for scaling with frequency and amplitude.

```glsl
void pulseObject_float(vec3 seedSize, float seedRadius, float freq, float amp, int mode, out vec3 size, out float radius) {
    float t = applyTimeMode(Tme, mode);
    float scale = 1.0 + sin(t * freq) * amp;
    size = seedSize * scale;
    radius = seedRadius * scale;
}
```

### 16. applyTimeMode
**Purpose**: Modifies time values for different animation modes (linear, sine, absolute sine).

**Input/Output**:

- **Input**: `t` (float), `mode` (int)
- **Output**: Returns modified time value

**Process**: Mode 0: linear, Mode 1: sine oscillation, Mode 2: absolute sine (pulsing).

```glsl
float applyTimeMode(float t, int mode) {
    if (mode == 1)
        return sin(t);
    else if (mode == 2)
        return abs(sin(t));
    return t; // mode 0 or default - linear time
}
```

## **Summary**

These helper functions provide comprehensive support for ray marching pipelines, enabling flexible camera animations, lighting calculations, UV transformations, and dynamic object effects. Each function is designed to be modular and reusable, contributing to the shader's ability to render complex, animated scenes with ray marching. From computing camera matrices to animating colors and objects, these functions form the backbone of the rendering pipeline, ensuring robust and visually appealing output.