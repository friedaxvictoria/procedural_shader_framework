<div class="container">
    <h1 class="main-heading">SDF Shader Include File Documentation</h1>
    <blockquote class="author">by Jeewan</blockquote>
</div>
## Introduction

This documentation covers the comprehensive 3D rendering pipeline implemented in the sdf_updated.gdshaderinc file for Godot. The system integrates signed distance field (SDF) objects, water effects, and desert terrain using advanced ray marching techniques through a single, unified method.

## Include Files Overview

### What is an Include File?

An include file (`.gdshaderinc`) in Godot is a modular shader component that contains reusable shader code. It serves as a library of functions, constants, and utilities that can be included in multiple shader files using the `#include` directive.

### Purpose of Include Files

- **Code Reusability**: Write once, use in multiple shaders
- **Modularity**: Organize complex shader logic into manageable components  
- **Maintainability**: Update shared functionality in one place
- **Performance**: Compiled once and shared across shaders
- **Organization**: Keep main shader files clean and focused

### File Structure

The `sdf_updated.gdshaderinc` file includes:

#### Core Dependencies
```glsl
#include "res://addons/includes/helper_functions/helper_func.gdshaderinc"
#include "res://addons/includes/global_variables/global_variables.gdshaderinc"
```

- Imports essential helper functions and global variables
- Provides access to camera controls, animation systems, and uniform parameters

#### IntegrationFlexible Method - Main Entry Point

The `sdf_updated.gdshaderinc` file is designed around one primary method: `IntegrationFlexible`. This method serves as the complete 3D rendering system and contains the implementation of all other functionality within itself, including:

- Ray marching algorithms for SDF objects
- Water surface generation and rendering
- Desert terrain creation and lighting
- Camera animation systems with multiple modes
- Scene composition and surface selection
- Lighting calculations for all surface types

#### Key Design Principle: 
All rendering functionality is self-contained within the `IntegrationFlexible` method. We don't need to call separate methods for ray marching, water effects, or desert rendering, everything is integrated into this single, comprehensive function.

---

## IntegrationFlexible Method

### Overview

The `IntegrationFlexible` method is the central integration point for rendering a 3D scene in a fragment shader. It combines procedural terrain systems (water and desert) with SDF-based objects using ray marching.

### Method Signature

```glsl
void IntegrationFlexible(vec2 INuv, out vec4 frgColor3)
```

**Parameters:**

- `INuv`: Normalized UV coordinates (0 to 1) from the fragment shader
- `frgColor3`: Final RGBA color output for the fragment

### Core Functionality

The method handles:

1. **Camera Setup**: Various animation modes (mouse control, orbiting, static)
2. **Ray Marching**: Find closest surface (SDF object, water, or desert)
3. **Terrain Rendering**: Specialized ray marching for water and desert
4. **Lighting**: Phong lighting for SDF objects and desert, custom water effects
5. **Scene Composition**: Select and render closest surface with fallbacks

---

## Camera Control Architecture
### Camera Setup and Ray Generation

The method begins by configuring the camera system with support for multiple animation modes:

```glsl
vec4 frgColor = vec4(0.0);
vec2 uv;
computeUV_float(INuv, uv);

// Animation system with dual camera matrices
mat3 animationMatrix1;
mat3 animationMatrix2;
mat3 baseMatrix = mat3(1.0); // Identity matrix
float distance;
vec3 rayOrigin;
```

**Initialization:**

- `frgColor`: Initialized to transparent black, updated with final pixel color
- `uv`: Computed from `INuv` using `computeUV_float` (internal method)
- Camera matrices: Two 3x3 matrices for complex camera transformations
- `distance`: Distance from camera to look-at position
- `rayOrigin`: Camera's position in world space

### Camera Animation Modes

The method supports multiple camera modes for dynamic scene exploration:

```glsl
if (camera_mode1 == MOUSE_CONTROL) {
    move_via_mouse_float(animationMatrix1);
    distance = length(camera_position - look_at_position);
} else if (camera_mode1 == AUTO_ORBIT) {
    orbitY_float(orbit_axis, orbit_speed, animationMatrix1);
    distance = length(camera_position - look_at_position);
} else if (camera_mode1 == STATIC_CAMERA) {
    animationMatrix1 = mat3(1.0);
    distance = length(camera_position - look_at_position);
}
// ... additional modes
```

**Available Camera Modes:**

- **MOUSE_CONTROL**: User-controlled rotation via `move_via_mouse_float()`
- **AUTO_ORBIT**: Automatic rotation around Y-axis via `orbitY_float()`
- **STATIC_CAMERA**: Fixed camera position
- **BACKANDFORTH**: Oscillating movement via `backAndForth_scale_float()`
- **SHAKE**: Camera shake effect via `shake_matrix_float()`

### Ray Direction Calculation

```glsl
mat3 finalCameraMatrix;
vec3 target = look_at_position;
getCameraMatrix_float(animationMatrix1, animationMatrix2, distance, target, finalCameraMatrix, rayOrigin);

vec3 rd = normalize(finalCameraMatrix * vec3(uv, -1.5));
vec3 ro = rayOrigin;
```

The `getCameraMatrix_float()` method combines both animation matrices to produce the final camera transformation and ray origin.

---

## Ray Marching Implementation

### Core Ray Marching Function

The `raymarch()` method traces rays to find the closest SDF object:

```glsl
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos, out int gHitID) {
    gHitID = -1;
    hitPos = vec3(0.0);
    float t = 0.0;

    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float d = evaluateScene(p, gHitID);
        
        // Apply noise based on object type
        if (gHitID >= 0) {
            int noise_type = obj_noise[gHitID];
            // ... noise application logic
        }
        
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        
        if (t > 50.0) break;
        t += d;
    }
    
    return -1.0;
}
```

### Scene Evaluation

The `evaluateScene()` method finds the closest object:

```glsl
float evaluateScene(vec3 p, out int gHitID) {
    float d = 100000.0;
    int bestID = -1;

    for (int i = 0; i < inputCount; ++i) {
        float di = evalSDF(obj_type[i], obj_position[i], obj_size[i], obj_radius[i], p, i);
        if (di < d) {
            d = di;
            bestID = i;
        }
    }

    gHitID = bestID;
    return d;
}
```

The `evalSDF()` method handles different object types (spheres, boxes, dolphins, etc.) with animation support.

---
## Lighting System

### Phong Lighting
The `applyPhongLighting_float()` method is used to compute lighting on standard SDF objects using the Phong reflection model. It simulates diffuse, ambient, and specular light components to create realistic lighting for smooth and hard-surface materials.

```glsl
void applyPhongLighting_float(vec3 hitPos, int hitID, vec3 cameraPosition, vec3 normal, vec3 baseColor, vec3 specularColor, float specularStrength, float shininess, out vec3 lightingColor)
{
    vec3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, cameraPosition, viewDir, lightDir, lightColor, ambientColor);

    normal = normalize(normal);
    float diff = max(dot(normal, lightDir), 0.15);

    vec3 R = reflect(-lightDir, normal);
    float spec = pow(max(dot(R, viewDir), 0.0), shininess);

    vec3 colour = baseColor;
    vec3 diffuse = diff * colour * lightColor;
    vec3 specular = spec * specularColor * specularStrength;

    vec3 enhancedAmbient = ambientColor * baseColor * 0.4;
    lightingColor = enhancedAmbient + diffuse + specular;
}
```

Lighting Breakdown:

- Ambient: Multiplies the base color by ambient light
- Diffuse: Based on dot product between light direction and surface normal
- Specular: Computed using the reflection vector and view direction
- Final Color: Sum of ambient, diffuse, and specular components

### Desert Phong Lighting
The `applyDesertPhongLighting_float()` function is a specialized lighting method for rendering desert terrain with more organic and natural characteristics.

```glsl
void applyDesertPhongLighting_float(vec3 hitPos, int hitID, vec3 cameraPosition, vec3 normal, vec3 baseColor, vec3 specularColor, float specularStrength, float shininess, out vec3 lightingColor){
    vec3 viewDir, lightDir, lightColor, ambientColor;
    desertLightingContext(hitPos, cameraPosition, viewDir, lightDir, lightColor, ambientColor);
    normal = normalize(normal);
    float diff = max(dot(normal, lightDir), 0.3);
    float subsurface = pow(max(0.0, dot(-lightDir, viewDir)), 2.0) * 0.1;
    vec3 R = reflect(-lightDir, normal);
    float spec = pow(max(dot(R, viewDir), 0.0), shininess);
    vec3 colour = baseColor;
    vec3 diffuse = diff * colour * lightColor;
    vec3 specular = spec * specularColor * specularStrength;
    vec3 enhancedAmbient = ambientColor * baseColor * 0.4;
    vec3 subsurfaceContrib = subsurface * colour * lightColor * 0.5;
    lightingColor = enhancedAmbient + diffuse + specular + subsurfaceContrib;
}
```

Differences from Standard Phong Lighting:

- **Subsurface Scattering:** Adds a soft backlighting effect simulating light passing through sand grains
- **Adjusted Diffuse Strength:** Slightly higher base diffuse contribution (0.3 instead of 0.15)
- **Softer Specular Highlights:** Uses lower specularStrength and shininess to simulate rough, matte surfaces
- **Enhanced Ambient Contribution:** Maintains richer base color in shaded areas
- **Lighting Context:** Uses a separate desertLightingContext() to better simulate outdoor sunlight

---

## Terrain Integration

### Water Effect System

#### Water Ray Marching

The `traceWater()` method performs ray marching for water surfaces:

```glsl
vec2 traceWater(vec3 rayOrigin, vec3 rayDir, float globalTimeWrapped,
                inout vec3 controlPoint, inout float waveStrength) {
    vec2 hit = vec2(0.1);
    
    for (int i = 0; i < 128; i++) {
        vec2 d = evaluateDistanceField(rayOrigin + rayDir * hit.x, 1.0, 
                                      globalTimeWrapped, controlPoint, waveStrength);
        if (d.x < 0.0001 || hit.x > 43.0) break;
        hit.x += d.x;
        hit.y = d.y;
    }
    
    return hit;
}
```

#### Wave Generation

The `computeWave()` method creates dynamic water surfaces:

```glsl
float computeWave(vec3 pos, int iterationCount, float writeOut, float globalTimeWrapped,
                  inout vec3 controlPoint, inout float waveStrength) {
    vec3 warped = pos - vec3(0.0, 0.0, globalTimeWrapped * 3.0);
    float accum = 0.0;
    float amplitude = 3.0;

    for (int i = 0; i < iterationCount; i++) {
        accum += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * amplitude;
        amplitude *= 0.51;
        warped.xy = rotation * warped.xy;
        warped *= 1.75;
    }
    
    return height_calculation;
}
```

#### Water Rendering

The `ApplyWaterEffectIntegrated()` method renders water with:

- Surface normal calculation using finite differences
- Fresnel reflection effects
- Specular highlights
- Color blending between deep/shallow water
- Foam effects based on wave strength

### Desert Effect System

#### Desert Ray Marching

The `traceDesert()` method handles desert terrain:

```glsl
vec2 traceDesert(vec3 rayOrigin, vec3 rayDir) {
    vec2 hit = vec2(0.1);
    
    for (int i = 0; i < 128; i++) {
        vec2 d = getDesert(rayOrigin + rayDir * hit.x);
        if (d.x < 0.0001 || hit.x > 43.0) break;
        hit.x += d.x;
        hit.y = d.y;
    }
    
    return hit;
}
```

#### Desert Height Calculation

The `surfFunc()` method creates layered desert terrain:

```glsl
float surfFunc(in vec3 p) {
    p /= 2.5;
    float layer1 = n2D(p.xz * layer1Freq) * layer1Amp - 0.5;
    float layer2 = n2D(p.xz * later2Freq) * later2Amp;
    float layer3 = n2D(p.xz * layer3Freq) * layer3Amp;
    
    return layer1 * 0.7 + layer2 * 0.25 + layer3 * 0.05;
}
```

#### Desert Rendering

Desert surfaces are rendered using:

- `getDesertNormal()`: Normal calculation with bump mapping
- `getDesertColor()`: Color mixing based on ripple patterns
- `applyDesertPhongLighting_float()`: Phong lighting with subsurface scattering

---

## Rendering Output

### Scene Composition

The method determines the closest surface by comparing distances:

```glsl
float closestT = 1000.0;
int closestSurface = 0; // 0 = background, 1 = sdf, 2 = water, 3 = desert

if (sdfHitSuccess && t < closestT) {
    closestT = t;
    closestSurface = 1;
}

if (waterHitSuccess && waterT < closestT) {
    closestT = waterT;
    closestSurface = 2;
}

if (desertHitSuccess && desertT < closestT) {
    closestT = desertT;
    closestSurface = 3;
}
```

### Final Rendering

Based on the closest surface:

- **SDF Objects**: Rendered using `applyPhongLighting_float()` with material properties
- **Water**: Rendered with `ApplyWaterEffectIntegrated()` for realistic water effects
- **Desert**: Rendered with desert-specific lighting and texturing
- **Background**: Fallback to background color or secondary terrain

---

## Usage Examples

### Basic Integration

```glsl
// In your fragment shader
void fragment() {
    vec4 finalColor;
    IntegrationFlexible(UV, finalColor);  // Complete 3D scene rendering in one method call
    ALBEDO = finalColor.rgb;
}
```
The `IntegrationFlexible` method computes the final color value for each screen-space fragment by performing ray marching calculations. The resulting RGBA color data is then assigned to the fragment's albedo channel, effectively rendering the 3D scene onto the 2D surface.

---

## Technical Notes

- All methods called within `IntegrationFlexible` are self-contained within the same `.gdshaderinc` file
- User can add multiple shaders, like PhongLighting,  inside this `.gdshaderinc` file and integrate that shader functionality  inside the `IntegrationFlexible` method. 

This comprehensive system provides a flexible, high-performance solution for rendering complex 3D scenes with mixed geometry types in Godot shaders.