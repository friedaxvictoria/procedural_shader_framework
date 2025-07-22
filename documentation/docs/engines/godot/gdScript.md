<div class="container">
    <h1 class="main-heading">SDF Script Guide: Adding and Removing Objects</h1>
    <blockquote class="author">by Jeewan</blockquote>
</div>

## Overview

This script (`addons/scripts/sdf_updated.gd`) is a Godot 4 script that manages Signed Distance Field (SDF) objects for real-time 3D rendering using shaders. It extends `Node2D` and provides a system for creating, configuring, and animating various 3D shapes in a shader-based rendering pipeline.

## Script Structure Breakdown

### 1. Export Variables (Inspector Configuration)
```gdscript
@export var shader_material_target: CanvasItem
@export var MAX_OBJECTS: int = 15
@export var lightPosition: Vector3 = Vector3(0.0, 4.0, 7.0)
@export var cameraPosition: Vector3 = Vector3(0.0, 13.0 , 13.0)
# ... and many more camera/rendering settings
```

**Purpose**: These variables appear in the Godot Inspector and allow artists/designers to configure the rendering without touching code.

### 2. Enums (Configuration Options)
```gdscript
enum CameraMode1 { MOUSE_CONTROL, AUTO_ORBIT, STATIC_CAMERA, BACKANDFORTH, SHAKE }
enum TerrainMode { NONE, WATER, DESERT }
enum ColorMode { STATIC, CYCLE_COLOR, WAVE_COLOR }
enum AnimationMode { NO_ANIMATION, PULSE_ANIMATION }
```

**Purpose**: Define different modes for camera control, terrain rendering, coloring, and animation.

### 3. ShaderObject Class
```gdscript
class ShaderObject:
    var type: int           # Shape type (0=sphere, 1=cube, 2=torus, etc.)
    var position: Vector3   # 3D position
    var size: Vector3       # Dimensions
    var radius: float       # Radius for rounded shapes
    var color: Vector3      # RGB color
    var noise_type: int     # Type of noise effect
    # ... additional properties for lighting and animation
```

**Purpose**: Represents a single 3D object with all its properties that will be rendered by the shader.

## How to Add/Remove SDFs - Step by Step Guide

### Understanding SDF Types

The script supports these SDF types (identified by the `type` parameter):

| Type | Shape | Description |
|------|-------|-------------|
| 0 | Sphere | Basic sphere shape |
| 1 | Cube | Box/cube shape |
| 2 | Torus | Donut shape |
| 3 | Dolphin | Complex animated dolphin model |
| 4 | Hex Prism | Hexagonal prism |
| 5 | Octahedron | 8-sided polyhedron |
| 6 | Ellipsoid | Stretched sphere |

### Step 1: Locate the SDF Array

Find the `shader_objects` array in the `_ready()` function:

```gdscript
func _ready():
    shader_objects = [
        # This is where you add/remove objects
        ShaderObject.new().set_values(2, Vector3(0.0,0.0, 0.0), Vector3(1.0,5.0,1.5), 0.2, Vector3(1.0, 0.2, 0.2),2),
    ]
```

### Step 2: Adding New SDFs

To add a new SDF, create a new `ShaderObject` line using this format:

```gdscript
ShaderObject.new().set_values(type, position, size, radius, color, noise_type, specular_color, specular_strength, shininess, speed, direction, time_offset)
```

#### Parameters (Required):
- **type**: Shape type (0-6, see table above)
- **position**: Vector3(x, y, z) - 3D position
- **size**: Vector3(width, height, depth) - dimensions
- **radius**: float - radius/rounding amount
- **color**: Vector3(r, g, b) - RGB color (0.0-1.0 range)
- **noise_type**: int - noise effect type
- **specular_color**: Vector3 - specular highlight color (default: Vector3.ONE)
- **specular_strength**: float - specular intensity (default: 0.5)
- **shininess**: float - surface shininess (default: 32.0)
- **speed**: float - animation speed (default: 1.0)
- **direction**: Vector3 - movement direction (default: Vector3(1,0,0))
- **time_offset**: float - animation timing offset (default: 0.0)

### Step 3: Practical Examples

#### Example 1: Adding a Simple Sphere
```gdscript
shader_objects = [
    # Add a blue sphere at origin
    ShaderObject.new().set_values(0, Vector3(0, 3.0, 0), Vector3.ZERO, 1.0, Vector3(0.2, 0.2, 1.0), 0),
    # Existing objects...
]
```

#### Example 2: Adding Multiple Cubes
```gdscript
shader_objects = [
    # Green cubes on left and right
    ShaderObject.new().set_values(1, Vector3(1.9, 0, 0), Vector3(1, 1, 1), 0.2, Vector3(0.2, 1.0, 0.2), 0),
    ShaderObject.new().set_values(1, Vector3(-1.9, 0, 0), Vector3(1, 1, 1), 0.2, Vector3(0.2, 1.0, 0.2), 0),
    # Existing objects...
]
```

#### Example 3: Adding an Animated Dolphin
```gdscript
shader_objects = [
    # Animated dolphin with custom movement
    ShaderObject.new().set_values(3, Vector3(0, 2.5, 0), Vector3(8.0, 8.0, 8.0), 5.0, Vector3(0.5, 0.7, 1.0), 0, Vector3.ONE, 0.8, 16.0, 2.0, Vector3(1, 0, 0.2), 0.0),
    # Existing objects...
]
```

#### Example 4: Complete Scene Setup
```gdscript
shader_objects = [
    # Central torus (red)
    ShaderObject.new().set_values(2, Vector3(0.0, 0.0, 0.0), Vector3(1.0, 5.0, 1.5), 0.2, Vector3(1.0, 0.2, 0.2), 2),
    
    # Floating spheres (blue)
    ShaderObject.new().set_values(0, Vector3(3.0, 2.0, 0), Vector3.ZERO, 0.8, Vector3(0.2, 0.2, 1.0), 0),
    ShaderObject.new().set_values(0, Vector3(-3.0, 2.0, 0), Vector3.ZERO, 0.8, Vector3(0.2, 0.2, 1.0), 0),
    
    # Ground cubes (green)
    ShaderObject.new().set_values(1, Vector3(2.0, -1.0, 2.0), Vector3(0.5, 0.5, 0.5), 0.1, Vector3(0.2, 1.0, 0.2), 0),
    ShaderObject.new().set_values(1, Vector3(-2.0, -1.0, 2.0), Vector3(0.5, 0.5, 0.5), 0.1, Vector3(0.2, 1.0, 0.2), 0),
]
```

### Step 4: Removing SDFs

To remove an SDF, simply:
1. **Comment out the line** by adding `#` at the beginning:
```gdscript
# ShaderObject.new().set_values(0, Vector3(0, 3.0, 0), Vector3.ZERO, 1.0, Vector3(0.2, 0.2, 1.0), 0),
```

2. **Delete the entire line** completely

3. **Replace with a different object** by changing the parameters

### Step 5: Important Limitations

- **Maximum Objects**: Limited to 15 objects (defined by `MAX_OBJECTS`)
- **Performance**: More objects = lower performance
- **Shader Compatibility**: The shader must support the SDF types you're using

### Step 6: Testing Your Changes

1. Save the script
2. Run the scene
3. Check the console for debug output:
   ```
   Object count: 3
   Types: [2, 0, 1]
   Positions: [(0, 0, 0), (3, 2, 0), (-3, 2, 0)]
   ```

## Common Issues and Solutions

### Objects Not Appearing
1. **Check the type number** - ensure it matches a supported SDF type
2. **Verify position** - object might be outside the camera view
3. **Check MAX_OBJECTS limit** - you might have too many objects

### Color Issues
1. **RGB values** should be between 0.0 and 1.0
2. **Black objects** might have Vector3(0, 0, 0) color
3. **Check lighting** - adjust lightPosition if objects appear too dark

## Summary

This script provides a powerful system for creating 3D scenes using SDF rendering. The key to adding/removing objects is understanding the `ShaderObject.set_values()` function and modifying the `shader_objects` array in the `_ready()` function. Start with simple shapes and gradually add complexity as needed.
