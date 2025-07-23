<div class="container">
    <h1 class="main-heading">Main Fragment Shader Analysis</h1>
    <blockquote class="author">by Jeewan</blockquote>
</div>
This document provides an analysis of the main fragment shader, which serves as the entry point for rendering a 3D scene using ray marching in Godot. The shader integrates the IntegrationFlexible method from `sdf_updated.gdshaderinc` to compute the final color for each pixel. Below, we describe the shader's purpose, structure, and usage of global variables, focusing on its role in the rendering pipeline.

## Overview of the Fragment Shader

In Godot, a fragment shader (defined with `shader_type canvas_item` for 2D rendering) processes each pixel of a 2D canvas item (`shader_type spatial` for 3D rendering of 3D canvas) to determine its final color. This shader is responsible for calling the IntegrationFlexible method, which performs ray marching to render a 3D scene with signed distance field (SDF) objects, water, and desert terrains. The shader leverages global variables and helper functions from included files to manage scene data and rendering parameters.

- **Purpose**: To render a 3D scene by computing the color of each pixel based on UV coordinates, using ray marching and terrain integration.
- **Usage in Godot**: Applied via a ShaderMaterial to a canvas item (e.g., a ColorRect or Sprite2D) in the Godot scene tree. The shader receives UV coordinates (UV) and uses global variables (e.g., `lightPosition`, `camera_position`) to configure the scene.
- **Dependencies**: Includes `sdf_updated.gdshaderinc`, which contains the `IntegrationFlexible` method, and indirectly relies on `global_variables.gdshaderinc` and `helper_function.gdshaderinc` for shared variables and functions.

## Shader Code

```glsl
shader_type canvas_item;

#include "res://addons/includes/sdf_updated.gdshaderinc"

void fragment() {
    vec4 color;
    IntegrationFlexible(UV, color);
    COLOR = color;
}
```

## Detailed Analysis

### Shader Type

**Canvas Item**: The `shader_type canvas_item` directive indicates this is a 2D shader in Godot, operating on a canvas item's texture coordinates. It processes each pixel in screen space, receiving UV coordinates (0.0 to 1.0) from the engine.

### Fragment Function

The `fragment()` function is the main entry point, executed for each pixel of the canvas item.

#### Purpose
Computes the final color (`COLOR`) for each pixel by calling `IntegrationFlexible`, which handles ray marching, terrain rendering, and lighting.

#### **Input:**
- `UV` (vec2): Built-in Godot variable providing normalized texture coordinates (0.0 to 1.0) for the current pixel.

#### **Output:**
- `COLOR` (vec4): Built-in Godot variable set to the final RGBA color of the pixel.
- `color` (vec4): Local variable to store the output of IntegrationFlexible.

#### Process

1. Declares a `vec4 color` variable to hold the computed color.
2. Calls `IntegrationFlexible(UV, color)` to perform ray marching and scene rendering:
   - `IntegrationFlexible` transforms UV into a ray direction, marches through the scene to detect hits with SDF objects, water, or desert terrains, and applies lighting (e.g., Phong for objects, custom effects for water).
   - It uses global variables (e.g., `camera_position`, `lightPosition`, `obj_type`) from `global_variables.gdshaderinc` to configure the scene.
3. Assigns the resulting color to `COLOR`, which Godot uses to render the pixel.

