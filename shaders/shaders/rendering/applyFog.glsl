/*
applyFog — fixed-parameter exponential-squared fog
-----------------------------------------------------------------------------------------
This helper wraps the classic “distance fog” formula into a single call.  
Both the fog’s intrinsic colour and density are hard-coded as constants so the function
can be dropped into any shader without additional uniforms.

CONSTANTS (edit to taste)
    FOG_COLOR   – what the mist looks like where it is fully opaque
    FOG_DENSITY – how quickly it thickens; larger = denser / nearer

INPUT
    sceneColor  – linear-space RGB that you have just finished shading
    depth       – view-space distance from camera to the pixel (same units as your scene)

OUTPUT
    The colour after atmospheric blending.

ALGORITHM
    1.  Compute an attenuation factor  
            f = exp(-(depth · FOG_DENSITY)²)          // “exp²” fall-off
    2.  Linearly interpolate between the fog colour and the scene colour  
            result = mix(FOG_COLOR, sceneColor, f)

USAGE EXAMPLE
-----------------------------------------------------------------------------------------
    // 1. Ray-march or rasterise your scene as usual
    vec3  shaded   = shadePixel(...);   // your lighting routine
    float distance = hitDist;           // e.g. total march distance

    // 2. Apply fixed fog in a single line
    vec3 finalColor = applyFog(shaded, distance);
*/
vec3 applyFog(vec3 sceneColor, float depth)
{
    // Fixed parameters
    const vec3  FOG_COLOR   = vec3(0.82, 0.85, 0.92);   // pale overcast-sky tint
    const float FOG_DENSITY = 0.04;                     // scene-wide density knob

    // Exponential-squared attenuation
    float f = exp(-pow(depth * FOG_DENSITY, 2.0));

    // Blend towards fog as the ray gets longer
    return mix(FOG_COLOR, sceneColor, f);
}
