# SDF Scene Tutorial

This tutorial is designed to illustrate the workflow of Godot's integration of the SDF framework. It showcases how user can get different SDFs scene while changing only one script file i.e. `includes/sdg_updated.gd`. 

## Scene 1: Desert Mining Cart

This scene demonstrates creating a desert environment with **two mining carts equipped with wheels** and **precious gems** using basic SDF shapes.

<div align="center">
    <img src="../../../static/videos/desertCart.gif" width="640" height="360" alt="Scene 2 Demo">
</div>

### Step 1: Setting Up the Cart Wheels

First, we create the wheels for both carts using torus shapes (Type 2). Each cart has four wheels positioned at the corners:

```glsl
# Cart 1 - Left side
# Back-left wheel
ShaderObject.new().set_values(2, Vector3(-7.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
# Back-right wheel  
ShaderObject.new().set_values(2, Vector3(-7.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
# Front-left wheel
ShaderObject.new().set_values(2, Vector3(-2.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
# Front-right wheel
ShaderObject.new().set_values(2, Vector3(-2.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
```

### Step 2: Adding Cart Bodies

Add the main cart body using round box shapes (Type 1):

```glsl
# Cart body/platform
ShaderObject.new().set_values(1, Vector3(-5.0, 2.0, -4.0), Vector3(3.0, 1.0, 1.0), 0.1, Vector3(0.5, 0.3, 0.2), 1),
```

### Step 3: Creating Precious Gems

Add diamonds using crystal shapes (Type 5) with high reflectance values for a sparkling effect:

```glsl
# White diamonds with high reflectance
ShaderObject.new().set_values(5, Vector3(-6.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
ShaderObject.new().set_values(5, Vector3(-4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),

# Blue diamond for variety
ShaderObject.new().set_values(5, Vector3(-8.0, 3.5, -4.0), Vector3(1, 1, 1), 1.0, Vector3(0.85, 0.9, 1.0), 0, Vector3(0.7, 0.75, 1.0), 0.98, 150.0),
```

### Step 4: Duplicate for Second Cart

Repeating the same process for the second cart on the right side, adjusting X coordinates accordingly.

## Scene 2: Underwater Dolphin Show

This scene creates an **aquatic environment with animated dolphins** jumping through **colorful torus hoops**, decorated with **pearls and coral formations**.

<div align="center">
    <img src="../../../static/videos/Scene 2.gif" width="640" height="360" alt="Scene 2 Demo">
</div>

### Step 1: Creating Animated Dolphins

Use dolphin shapes (Type 3) with animation parameters for jumping motion:

```glsl
# Animated dolphins with jumping motion
ShaderObject.new().set_values(3, Vector3(-10.4, 2.0, -5.0), Vector3(4.5, 4.5, 4.5), 2.8, Vector3(0.1, 0.45, 0.65), 0, Vector3(0.8, 0.9, 1.0), 1.0, 32.0, 1.1, Vector3(0.7, 0, -0.6), 5.0),
ShaderObject.new().set_values(3, Vector3(-2.5, 2.0, -5.0), Vector3(5.0, 5.0, 5.0), 3.0, Vector3(0.2, 0.6, 1.0), 0, Vector3(1.0, 1.0, 1.0), 1.0, 40.0, 2.0, Vector3(0, 1, 0), 6.0),
```

### Step 2: Adding Jump Hoops

Create colorful torus shapes for dolphins to jump through:

```glsl
# Colorful torus hoops
ShaderObject.new().set_values(2, Vector3(-10.4, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(1.0, 0.4, 0.7), 0), # Pink
ShaderObject.new().set_values(2, Vector3(-2.5, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(0.3, 0.6, 1.0), 0), # Blue
ShaderObject.new().set_values(2, Vector3(5.3, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(0.5, 1.0, 0.6), 0), # Green
```

### Step 3: Decorative Elements

Add colorful pearl spheres and coral formations:

```glsl
# Decorative pearls at water edge
ShaderObject.new().set_values(0, Vector3(2.0, -1.5, -2.0), Vector3.ZERO, 0.4, Vector3(1.0, 0.4, 0.7), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Pink
ShaderObject.new().set_values(0, Vector3(-3.5, -1.5, -1.5), Vector3.ZERO, 0.4, Vector3(0.9, 0.2, 0.2), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Red

# Coral pillars
ShaderObject.new().set_values(1, Vector3(-9.0, 1.0, 5.0), Vector3(0.6, 4.0, 0.6), 0.15, Vector3(1.0, 0.5, 0.7), 1),
```

## Scene 3: Mystical Crystal Cave

This scene demonstrates creating a **crystal cave environment** with **various colored crystal formations** arranged naturally.

<div align="center">
    <img src="../../../static/videos/Scene 3.gif" width="640" height="360" alt="Scene 2 Demo">
</div>

### Step 1: Central Crystal Cluster

Create the main focal point with a large crystal:

```glsl
# Large central crystal - main focal point
ShaderObject.new().set_values(5, Vector3(0, 2.0, 0), Vector3(2.0, 3.0, 2.0), 1.5, Vector3(0.8, 0.3, 1.0), 0),
```

### Step 2: Surrounding Formations

Add supporting crystals around the central piece using different types and colors:

```glsl
# Left side crystals
ShaderObject.new().set_values(5, Vector3(-4.0, 0.5, -2.0), Vector3(1.5, 2.0, 1.5), 1.0, Vector3(0.3, 0.8, 1.0), 0), # Blue
ShaderObject.new().set_values(6, Vector3(-3.0, -1.0, 1.0), Vector3(1.0, 1.5, 1.0), 0.8, Vector3(0.9, 0.4, 0.7), 0), # Pink
ShaderObject.new().set_values(5, Vector3(-2.5, 1.5, -1.5), Vector3(1.0, 1.8, 1.0), 0.9, Vector3(0.6, 0.9, 0.3), 0), # Green
```

### Step 3: Adding Depth

Place background crystals for depth perception:

```glsl
# Background crystals for depth
ShaderObject.new().set_values(5, Vector3(0, -2.0, -4.0), Vector3(2.5, 4.0, 2.5), 1.8, Vector3(0.7, 0.5, 1.0), 0),
ShaderObject.new().set_values(6, Vector3(-1.5, 0, -3.0), Vector3(1.0, 2.0, 1.0), 0.9, Vector3(1.0, 0.7, 0.4), 0),
```

## Implementation Steps

>**Important:** We only need to modify the script file.

### Step 1: Open the Script File
Navigate to `scripts/sdf_updated.gd` in our project directory and open it in our code editor.

### Step 2: Locate the Shader Objects Array
Find the `shader_objects = [` declaration in the script. This array contains all the objects that will be rendered in your scene.

### Step 3: Replace with Your Chosen Scene

**For Scene 1 (Desert Mining Cart)**, replace the entire `shader_objects` array with:

```glsl
shader_objects = [
    #Cart_1
    #Back-left wheel
    ShaderObject.new().set_values(2, Vector3(-7.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    ShaderObject.new().set_values(1, Vector3(-5.0, 2.0, -4.0), Vector3(3.0, 1.0, 1.0), 0.1, Vector3(0.5, 0.3, 0.2), 1),
    #Back-right wheel
    ShaderObject.new().set_values(2, Vector3(-7.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    #Front-Left wheel
    ShaderObject.new().set_values(2, Vector3(-2.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    #Front-right wheel
    ShaderObject.new().set_values(2, Vector3(-2.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),

    #Left Cart Diamonds
    ShaderObject.new().set_values(5, Vector3(-6.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(-4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(-4.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(-6.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(-8.0, 3.5, -4.0), Vector3(1, 1, 1), 1.0, Vector3(0.85, 0.9, 1.0), 0, Vector3(0.7, 0.75, 1.0), 0.98, 150.0),
    
    #Cart_2
    #Back-left wheel
    ShaderObject.new().set_values(2, Vector3(3.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    ShaderObject.new().set_values(1, Vector3(6.0, 2.0, -4.0), Vector3(3.0, 1.0, 1.0), 0.1, Vector3(0.5, 0.3, 0.2), 1),
    #Back-right wheel
    ShaderObject.new().set_values(2, Vector3(3.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    #Front-Left wheel
    ShaderObject.new().set_values(2, Vector3(8.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    #Front-right wheel
    ShaderObject.new().set_values(2, Vector3(8.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),

    #Right Cart Diamonds
    ShaderObject.new().set_values(5, Vector3(6.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(4.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(6.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(8.0, 3.5, -4.0), Vector3(1, 1, 1), 1.0, Vector3(0.85, 0.9, 1.0), 0, Vector3(0.7, 0.75, 1.0), 0.98, 150.0),
]
```

**For Scene 2 (Underwater Dolphin Show)**, replace the entire `shader_objects` array with:

```glsl
shader_objects = [
    # Animated dolphins
    ShaderObject.new().set_values(3, Vector3(-10.4, 2.0, -5.0), Vector3(4.5, 4.5, 4.5), 2.8, Vector3(0.1, 0.45, 0.65), 0, Vector3(0.8, 0.9, 1.0), 1.0, 32.0, 1.1, Vector3(0.7, 0, -0.6), 5.0),
    ShaderObject.new().set_values(3, Vector3(-2.5, 2.0, -5.0), Vector3(5.0, 5.0, 5.0), 3.0, Vector3(0.2, 0.6, 1.0), 0, Vector3(1.0, 1.0, 1.0), 1.0, 40.0, 2.0, Vector3(0, 1, 0), 6.0),
    ShaderObject.new().set_values(3, Vector3(5.3, 1.3, -5.0), Vector3(5.0, 5.0, 5.0), 3.0, Vector3(0.2, 0.6, 1.0), 0, Vector3(1.0, 1.0, 1.0), 1.0, 40.0, 2.0, Vector3(0, 1, 0), 6.0),

    # Decorative pearls
    ShaderObject.new().set_values(0, Vector3(2.0, -1.5, -2.0), Vector3.ZERO, 0.4, Vector3(1.0, 0.4, 0.7), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0),
    ShaderObject.new().set_values(0, Vector3(-3.5, -1.5, -1.5), Vector3.ZERO, 0.4, Vector3(0.9, 0.2, 0.2), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0),
    ShaderObject.new().set_values(0, Vector3(3.0, -1.5, 4.0), Vector3.ZERO, 0.4, Vector3(1.0, 0.6, 0.2), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0),
    ShaderObject.new().set_values(0, Vector3(-1.5, -1.5, 5.0), Vector3.ZERO, 0.4, Vector3(0.6, 1.0, 1.0), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0),
    ShaderObject.new().set_values(0, Vector3(-8.0, -1.5, 1.0), Vector3.ZERO, 0.4, Vector3(0.9, 0.2, 0.2), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0),
    ShaderObject.new().set_values(0, Vector3(-4.0, -1.5, 6.0), Vector3.ZERO, 0.4, Vector3(1.0, 0.4, 0.7), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0),

    # Torus hoops for dolphin jumping
    ShaderObject.new().set_values(2, Vector3(-10.4, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(1.0, 0.4, 0.7), 0),
    ShaderObject.new().set_values(2, Vector3(-2.5, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(0.3, 0.6, 1.0), 0),
    ShaderObject.new().set_values(2, Vector3(5.3, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(0.5, 1.0, 0.6), 0),

    # Coral formations
    ShaderObject.new().set_values(1, Vector3(-9.0, 1.0, 5.0), Vector3(0.6, 4.0, 0.6), 0.15, Vector3(1.0, 0.5, 0.7), 1),
    ShaderObject.new().set_values(1, Vector3(7.0, 1.0, 3.0), Vector3(0.6, 4.0, 0.6), 0.15, Vector3(1.0, 0.5, 0.7), 1),
]
```

**For Scene 3 (Crystal Cave)**, replace the entire `shader_objects` array with:

```glsl
shader_objects = [
    # Large central crystal cluster
    ShaderObject.new().set_values(5, Vector3(0, 2.0, 0), Vector3(2.0, 3.0, 2.0), 1.5, Vector3(0.8, 0.3, 1.0), 0),

    # Left side crystals
    ShaderObject.new().set_values(5, Vector3(-4.0, 0.5, -2.0), Vector3(1.5, 2.0, 1.5), 1.0, Vector3(0.3, 0.8, 1.0), 0),
    ShaderObject.new().set_values(6, Vector3(-3.0, -1.0, 1.0), Vector3(1.0, 1.5, 1.0), 0.8, Vector3(0.9, 0.4, 0.7), 0),
    ShaderObject.new().set_values(5, Vector3(-2.5, 1.5, -1.5), Vector3(1.0, 1.8, 1.0), 0.9, Vector3(0.6, 0.9, 0.3), 0),

    # Right side crystals
    ShaderObject.new().set_values(5, Vector3(4.0, 0.8, -1.0), Vector3(1.8, 2.5, 1.8), 1.2, Vector3(1.0, 0.6, 0.8), 0),
    ShaderObject.new().set_values(6, Vector3(3.5, -0.5, 2.0), Vector3(1.2, 1.8, 1.2), 0.7, Vector3(0.4, 1.0, 0.6), 0),
    ShaderObject.new().set_values(5, Vector3(2.0, 2.5, 1.5), Vector3(1.0, 2.0, 1.0), 1.0, Vector3(0.8, 0.8, 0.3), 0),

    # Background crystals for depth
    ShaderObject.new().set_values(5, Vector3(0, -2.0, -4.0), Vector3(2.5, 4.0, 2.5), 1.8, Vector3(0.7, 0.5, 1.0), 0),
    ShaderObject.new().set_values(6, Vector3(-1.5, 0, -3.0), Vector3(1.0, 2.0, 1.0), 0.9, Vector3(1.0, 0.7, 0.4), 0),

    # Small detail crystals
    ShaderObject.new().set_values(5, Vector3(1.5, -1.5, 0.5), Vector3(0.8, 1.2, 0.8), 0.6, Vector3(0.9, 0.9, 0.9), 0),
    ShaderObject.new().set_values(6, Vector3(-1.0, -0.8, 2.5), Vector3(0.6, 1.0, 0.6), 0.5, Vector3(0.5, 0.8, 1.0), 0),
]
```

### Step 4: Save and Run
Save the `sdf_updated.gd` file and run the Godot project. The scene will automatically update to show your chosen configuration.