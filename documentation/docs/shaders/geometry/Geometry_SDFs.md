<div class="container">
    <h1 class="main-heading">Geometry SDF Shader</h1>
    <blockquote class="author">by Saeed Shamseldin</blockquote>
</div>

This document describes the SDF (Signed Distance Field) geometry functions used in the GLSL shader file, focusing on three primitive shapes: sphere, rounded box, and torus.

---

## Overview

SDF functions calculate the shortest distance from any point in space to the surface of a shape. The distance is:

- Positive when the point is outside the shape

- Negative when the point is inside the shape

- Zero when the point is exactly on the surface

## Implemented SDF Functions

### 1. Sphere SDF (sdSphere)
#### Function Signature:

```glsl
float sdSphere(vec3 position, float radius)
```
#### Parameters:

- **`position`**: The point in 3D space to evaluate (relative to sphere center)

- **`radius`**: The radius of the sphere

#### Implementation:

```glsl
return length(position) - radius;
```
#### Usage:

The sphere SDF is the simplest SDF function. It calculates the Euclidean distance from the point to the sphere's center and subtracts the radius. This gives:

- Positive values outside the sphere

- Negative values inside

- Zero on the surface

#### Engine Integrations

<div class="button-row">
  <a class="custom-button md-button" href="../../../../engines/unity/sdfs/sphere">Unity</a>
</div>
<div class="button-row">
  <a class="custom-button md-button" href="../../engines/unreal/sdfs/sphere.md">Unreal</a>
</div>

### 2. Rounded Box SDF (sdRoundBox)
#### Function Signature:

```glsl
float sdRoundBox(vec3 p, vec3 b, float r)
```
#### Parameters:

- **`p`**: The point in 3D space to evaluate (relative to box center)

- **`b`**: The half-extents of the box (size/2 in each dimension)

- **`r`**: The corner rounding radius

#### Implementation:

```glsl
vec3 q = abs(p) - b + r;
return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
```
#### Behavior:

1. First calculates the distance from the point to the box faces

2. Then applies rounding to the corners

3. The function handles both inside and outside cases correctly

#### Engine Integrations

<div class="button-row">
  <a class="custom-button md-button" href="../../../../engines/unity/sdfs/cube">Unity</a>
</div>


### 3. Torus SDF (sdTorus)

#### Function Signature:
```glsl
float sdTorus(vec3 p, vec2 radius)
```
#### Parameters:

- **`p`**: The point in 3D space to evaluate (relative to torus center)

- **`radius`**: A vec2 where:

    - **`radius.x`** is the major radius (distance from center to tube center)

    - **`radius.y`** is the minor radius (tube thickness)

#### Implementation:

```glsl
vec2 q = vec2(length(p.xy)-radius.x,p.z);
return length(q)-radius.y;
```
#### Behavior:

1. First calculates distance in the XY plane to the torus ring

2. Then combines with Z coordinate to form a new 2D distance

3. Finally subtracts the minor radius to get the tube thickness

#### Engine Integrations

<div class="button-row">
  <a class="custom-button md-button" href="../../../../engines/unity/sdfs/torus">Unity</a>
</div>
<div class="button-row">
  <a class="custom-button md-button" href="../../engines/unity/sdfs/torus.md">Unreal</a>
</div>

## Scene Integration

The SDF shapes are integrated into the scene through:

### 1. SDF Structure:
```glsl
struct SDF {
    int   type;       // 0=sphere, 1=round box, 2=torus
    vec3  position;   // World position
    vec3  size;       // Dimensions (interpretation varies by type)
    float radius;     // Primary radius parameter
    vec3 color;       // Base color
};
```

### 2. Scene Evaluation:
The **`evalSDF`** function dispatches to the appropriate SDF based on type:

```glsl
float evalSDF(SDF s, vec3 p) {
    if (s.type == 0) return sdSphere((p - s.position), s.radius);
    else if (s.type == 1) return sdRoundBox(p - s.position, s.size, s.radius);
    else if(s.type == 2) return sdTorus(p - s.position, s.size.yz);
    // ... other types
}
```

### 3. Scene Composition:
Multiple SDFs are combined by taking the minimum distance in [evaluateScene()](./SDF_Shader.md#scene-evaluation) to create a union of shapes.