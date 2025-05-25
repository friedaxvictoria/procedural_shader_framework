// ==========================================
// Shader: gray Scale noise Shader
// Category: noise
// Description: generate random gray scale noise
// Screenshot: screenshots/noise/grayScale_noise.png
// ==========================================

/*
to use this component in Godot, replace the following variables:

iResolution -> resolution
fragCoord -> UV
iTime -> Time
fragColor -> COLOR
*/

float noise2d(vec2 co){
  return fract(sin(dot(co.xy ,vec2(1.0,73))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv = uv*sin(iTime);

    vec3 col = vec3(noise2d(uv));
    fragColor = vec4(col,1.0);
}