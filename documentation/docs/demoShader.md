# Demo Shader: Procedural

## GLSL (Shadertoy)

## GLSL Code  // with title
Some `glsl` code goes here
```glsl title="pixelShader.glsl"
shader_type canvas_item;

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    // Called for every pixel the material is visible on.
    // Create a wavy pattern based on UV coordinates and time
    float value = sin(UV.x * 50.0 + TIME) * cos(UV.y * 50.0 + TIME);
    // Normalize the value to 0.0–1.0 for grayscale
    value = (value + 1.0) * 0.6;
    // Output as grayscale with full opacity
    COLOR = vec4(value, value, value, 1.0);
} 
```

## GODOT icon shader
```glsl title='icon.gdshader'
shader_type canvas_item;
void fragment() {
	// Called for every pixel the material is visible on.
	//COLOR = vec4(1,1,1,1);;
	vec4 input_color = texture(TEXTURE, UV);

	if (UV.x > 0.5) {
		COLOR = vec4(0,0, 0, input_color.r);
	}
	else {
		COLOR = vec4(1.0, 1.0, 1.0, input_color.g);
	}
}
```


## Pytorch  
Some `python` code goes here  // highlighting according to  specific language
``` py
import numpy as np
def sum():
    print('shader development doc')

```

## JSON Code   // with line number and higlighting specific line number code
Some `json` code entitled here...
```json linenums='1' hl_lines='2 3'
{
"name":"John",
"age":30,
"cars":["Ford", "BMW", "Fiat"]
}
myObj.cars[0];
```

## Shader Video Demo
Shader in action, made by `Utku` 
<video controls width="400">
    <source src="../static/videos/shaderexamplevideo.mp4" type="video/mp4">
    Your browser does not support the video tag.
</video>
*Shows different shaders running in Unreal Engine.*

## Video Demo ... Embedding external video link like from youtube
<iframe width="560" height="315" src="https://www.youtube.com/embed/BrZ4pWwkpto?si=hCWamP_iBE9a_Amq" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
*Getting Started with Compute Shaders in Unity.*