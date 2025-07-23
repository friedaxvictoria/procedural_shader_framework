Code snippets
Scene 1:

<div align="center">
<img src="../../../static/images/images4Godot/Desert.png
" alt="Camera Controls" width="640" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>

```glsl
    shader_objects = [
    #Cart_1
    #Back-left wheel
    ShaderObject.new().set_values(2, Vector3(-7.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2), # Rock pillar
    ShaderObject.new().set_values(1, Vector3(-5.0, 2.0, -4.0), Vector3(3.0, 1.0, 1.0), 0.1, Vector3(0.5, 0.3, 0.2), 1),
    #Back-right wheel
    ShaderObject.new().set_values(2, Vector3(-7.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    #Front-Left wheel
    ShaderObject.new().set_values(2, Vector3(-2.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    #Front-right wheel
    ShaderObject.new().set_values(2, Vector3(-2.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),

    #Left Cart Diamonds(#1)

    # Option 1: Classic White Diamond

    ShaderObject.new().set_values(5, Vector3(-6.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(-4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),

    ShaderObject.new().set_values(5, Vector3(-4.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(-6.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),

    # Option 2: Blue Diamond (more colorful)

    ShaderObject.new().set_values(5, Vector3(-8.0, 3.5, -4.0), Vector3(1, 1, 1), 1.0, Vector3(0.85, 0.9, 1.0), 0, Vector3(0.7, 0.75, 1.0), 0.98, 150.0),
    #Cart_2
    #Back-left wheel
    ShaderObject.new().set_values(2, Vector3(3.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),

    # Rock pillar

    ShaderObject.new().set_values(1, Vector3(6.0, 2.0, -4.0), Vector3(3.0, 1.0, 1.0), 0.1, Vector3(0.5, 0.3, 0.2), 1),
    #Back-right wheel
    ShaderObject.new().set_values(2, Vector3(3.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),

    #Front-Left wheel
    ShaderObject.new().set_values(2, Vector3(8.5, 0.2, -5.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),
    #Front-right wheel
    ShaderObject.new().set_values(2, Vector3(8.5, 0.2, -3.0), Vector3(0.3, 1.5, 0.3), 0.1, Vector3(0.5, 0.3, 0.2), 2),

    #Right Cart Diamonds(#2)

    # Option 1: Classic White Diamond

    ShaderObject.new().set_values(5, Vector3(6.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(4.0, 3.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),

    ShaderObject.new().set_values(5, Vector3(4.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),
    ShaderObject.new().set_values(5, Vector3(6.7, 4.5, -4.0), Vector3(0.5, 0.5, 0.5), 1.0, Vector3(0.9, 0.95, 1.0), 0, Vector3(1.0, 1.0, 1.0), 0.95, 128.0),

    # Option 2: Blue Diamond (more colorful)

    ShaderObject.new().set_values(5, Vector3(8.0, 3.5, -4.0), Vector3(1, 1, 1), 1.0, Vector3(0.85, 0.9, 1.0), 0, Vector3(0.7, 0.75, 1.0), 0.98, 150.0),

    ]

```

<!-- this is for locally stored videos -->
<div align="center">
<video controls width="640" height="360" >
  <source src="../../../static/videos/Scene_2.mov" type="video/mp4">
  Your browser does not support the video tag.
</video>
</div>

```glsl
    shader_objects = [

    # 🐬 Dolphins (Type 3) - jumping in circle

    #ShaderObject.new().set_values(3, Vector3(0, 3.5, -3.5), Vector3(4.5, 4.5, 4.5), 2.8, Vector3(0.05, 0.2, 0.45), 0, Vector3(0.8, 0.9, 1.0), 1.0, 32.0, 1.2, Vector3(1, 0, 0), 0.0), # Navy Blue
    #ShaderObject.new().set_values(3, Vector3(6.5, 2.8, -1.2), Vector3(4.5, 4.5, 4.5), 2.8, Vector3(0.1, 0.3, 0.6), 0, Vector3(0.9, 0.9, 1.0), 1.0, 32.0, 1.4, Vector3(0.5, 0, 0.87), 1.0), # Steel Blue
    #ShaderObject.new().set_values(3, Vector3(7.5, 4.5, 4.2), Vector3(4.5, 4.5, 4.5), 2.8, Vector3(0.2, 0.4, 0.7), 0, Vector3(0.8, 0.85, 1.0), 1.0, 32.0, 1.6, Vector3(-0.5, 0, 0.87), 2.0), # Royal Blue
    #ShaderObject.new().set_values(3, Vector3(0, 3.2, 9.5), Vector3(4.5, 4.5, 4.5), 2.8, Vector3(0.25, 0.5, 0.75), 0, Vector3(0.9, 0.9, 1.0), 1.0, 32.0, 1.3, Vector3(-1, 0, 0), 3.0), # Deep Sky Blue
    #ShaderObject.new().set_values(3, Vector3(-7.5, 4.0, 4.5), Vector3(4.5, 4.5, 4.5), 2.8, Vector3(0.0, 0.6, 0.8), 0, Vector3(0.85, 0.85, 0.95), 1.0, 32.0, 1.5, Vector3(-0.7, 0, -0.6), 4.0), # Cyan Blue
    ShaderObject.new().set_values(3, Vector3(-10.4, 2.0, -5.0), Vector3(4.5, 4.5, 4.5), 2.8, Vector3(0.1, 0.45, 0.65), 0, Vector3(0.8, 0.9, 1.0), 1.0, 32.0, 1.1, Vector3(0.7, 0, -0.6), 5.0), # Teal Blue
    ShaderObject.new().set_values(3, Vector3(-2.5, 2.0, -5.0), Vector3(5.0, 5.0, 5.0), 3.0, Vector3(0.2, 0.6, 1.0), 0, Vector3(1.0, 1.0, 1.0), 1.0, 40.0, 2.0, Vector3(0, 1, 0), 6.0), # Bright Blue
    ShaderObject.new().set_values(3, Vector3(5.3, 1.3, -5.0), Vector3(5.0, 5.0, 5.0), 3.0, Vector3(0.2, 0.6, 1.0), 0, Vector3(1.0, 1.0, 1.0), 1.0, 40.0, 2.0, Vector3(0, 1, 0), 6.0), # Bright Blue

    # 🧡 Center Floating Pearl (Type 0 - Sphere)

    # 🌈 Decorative Spheres – Water Edge Jewels

    ShaderObject.new().set_values(0, Vector3(2.0, -1.5, -2.0), Vector3.ZERO, 0.4, Vector3(1.0, 0.4, 0.7), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Pink
    ShaderObject.new().set_values(0, Vector3(-3.5, -1.5, -1.5), Vector3.ZERO, 0.4, Vector3(0.9, 0.2, 0.2), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Red
    #ShaderObject.new().set_values(0, Vector3(5.0, -1.5, -0.5), Vector3.ZERO, 0.4, Vector3(0.5, 0.3, 1.0), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Purple
    #ShaderObject.new().set_values(0, Vector3(-6.0, -1.5, 2.0), Vector3.ZERO, 0.4, Vector3(0.3, 0.9, 0.5), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Mint Green
    ShaderObject.new().set_values(0, Vector3(3.0, -1.5, 4.0), Vector3.ZERO, 0.4, Vector3(1.0, 0.6, 0.2), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Orange
    ShaderObject.new().set_values(0, Vector3(-1.5, -1.5, 5.0), Vector3.ZERO, 0.4, Vector3(0.6, 1.0, 1.0), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Cyan Pearl
    #ShaderObject.new().set_values(0, Vector3(-6.0, -1.5, 2.0), Vector3.ZERO, 0.4, Vector3(0.3, 0.9, 0.5), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Mint Green
    ShaderObject.new().set_values(0, Vector3(-8.0, -1.5, 1.0), Vector3.ZERO, 0.4, Vector3(0.9, 0.2, 0.2), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Mint Green
    ShaderObject.new().set_values(0, Vector3(-4.0, -1.5, 6.0), Vector3.ZERO, 0.4, Vector3(1.0, 0.4, 0.7), 0, Vector3(1.0, 1.0, 1.0), 1.0, 48.0), # Mint Green

    # 🌀🐬 Thinner + Closer Torus Hoops (for Dolphin Jump Show)

    ShaderObject.new().set_values(2, Vector3(-10.4, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(1.0, 0.4, 0.7), 0), # Pink Torus - Left
    ShaderObject.new().set_values(2, Vector3(-2.5, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(0.3, 0.6, 1.0), 0), # Blue Torus - Center
    ShaderObject.new().set_values(2, Vector3(5.3, 2.0, -5.0), Vector3(1.5, 3.0, 1.5), 0.5, Vector3(0.5, 1.0, 0.6), 0), # Green Torus - Right

    # 🪸 Coral Arc (Type 1 - RoundBox)

    # Left Coral Pillar

    ShaderObject.new().set_values(1, Vector3(-9.0, 1.0, 5.0), Vector3(0.6, 4.0, 0.6), 0.15, Vector3(1.0, 0.5, 0.7), 1),

    ShaderObject.new().set_values(1, Vector3(7.0, 1.0, 3.0), Vector3(0.6, 4.0, 0.6), 0.15, Vector3(1.0, 0.5, 0.7), 1),

    # 💨 Bubbles (Type 0 - Sphere, animated floaters)

    #ShaderObject.new().set_values(0, Vector3(1.5, 1.5, -1.5), Vector3.ZERO, 0.4, Vector3(0.6, 0.8, 1.0), 0, Vector3(1,1,1), 0.3, 12.0, 0.3, Vector3(0,1,0), 0.5),
    #ShaderObject.new().set_values(0, Vector3(-2.0, 2.0, 1.0), Vector3.ZERO, 0.35, Vector3(0.6, 0.8, 1.0), 0, Vector3(1,1,1), 0.3, 12.0, 0.4, Vector3(0,1,0), 1.2),
    #ShaderObject.new().set_values(0, Vector3(0.5, 1.0, 2.0), Vector3.ZERO, 0.3, Vector3(0.6, 0.8, 1.0), 0, Vector3(1,1,1), 0.3, 12.0, 0.35, Vector3(0,1,0), 2.1),
    ]

```

<!-- this is for locally stored videos -->
<div align="center">
<video controls width="640" height="360" >
  <source src="../../../static/videos/Scene_1.mov" type="video/mp4">
  Your browser does not support the video tag.
</video>
</div>

```glsl
    shader_objects = [
    # Large central crystal cluster - Main focal point
    ShaderObject.new().set_values(5, Vector3(0, 2.0, 0), Vector3(2.0, 3.0, 2.0), 1.5, Vector3(0.8, 0.3, 1.0), 0),

    # Surrounding crystal formations - Left side
    ShaderObject.new().set_values(5, Vector3(-4.0, 0.5, -2.0), Vector3(1.5, 2.0, 1.5), 1.0, Vector3(0.3, 0.8, 1.0), 0),
    ShaderObject.new().set_values(6, Vector3(-3.0, -1.0, 1.0), Vector3(1.0, 1.5, 1.0), 0.8, Vector3(0.9, 0.4, 0.7), 0),
    ShaderObject.new().set_values(5, Vector3(-2.5, 1.5, -1.5), Vector3(1.0, 1.8, 1.0), 0.9, Vector3(0.6, 0.9, 0.3), 0),

    # Right side crystal formations
    ShaderObject.new().set_values(5, Vector3(4.0, 0.8, -1.0), Vector3(1.8, 2.5, 1.8), 1.2, Vector3(1.0, 0.6, 0.8), 0),
    ShaderObject.new().set_values(6, Vector3(3.5, -0.5, 2.0), Vector3(1.2, 1.8, 1.2), 0.7, Vector3(0.4, 1.0, 0.6), 0),
    ShaderObject.new().set_values(5, Vector3(2.0, 2.5, 1.5), Vector3(1.0, 2.0, 1.0), 1.0, Vector3(0.8, 0.8, 0.3), 0),

    # Background crystals for depth
    ShaderObject.new().set_values(5, Vector3(0, -2.0, -4.0), Vector3(2.5, 4.0, 2.5), 1.8, Vector3(0.7, 0.5, 1.0), 0),
    ShaderObject.new().set_values(6, Vector3(-1.5, 0, -3.0), Vector3(1.0, 2.0, 1.0), 0.9, Vector3(1.0, 0.7, 0.4), 0),

    # Small scattered crystals for detail
    ShaderObject.new().set_values(5, Vector3(1.5, -1.5, 0.5), Vector3(0.8, 1.2, 0.8), 0.6, Vector3(0.9, 0.9, 0.9), 0),
    ShaderObject.new().set_values(6, Vector3(-1.0, -0.8, 2.5), Vector3(0.6, 1.0, 0.6), 0.5, Vector3(0.5, 0.8, 1.0), 0),
    ]

```

```

```
