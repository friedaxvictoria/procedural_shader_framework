// ==========================================
// Shader: Circle Shader
// Category: Geometry
// Description: Draws a simple filled circle.
// Screenshot: screenshots/geometry/circle.png
// ==========================================

// Converts RGB values from 0–255 range to normalized 0–1 range (GLSL expects 0–1)
vec3 rgb(float r, float g, float b) {
    return vec3(r / 255.0, g / 255.0, b / 255.0);
}

/**
 * Draws a circle centered at `pos`, with radius `rad` and color `color`.
 * `uv` is the current pixel position. The function returns a vec4 color,
 * where alpha represents how close the pixel is to the circle edge (for blending).
 */
vec4 circle(vec2 uv, vec2 pos, float rad, vec3 color) {
    // Compute the distance from current pixel (uv) to the circle center (pos), minus radius
    float d = length(pos - uv) - rad;

    // Clamp the distance to the range [0,1] to use for alpha blending
    // Clamp function limits a value to stay within a certain range.
    float t = clamp(d, 0.0, 1.0);

    // Return the final color with alpha = 1.0 - t, making center fully opaque and edge transparent
    return vec4(color, 1.0 - t);
}


// The main shader function, executed per-pixel (fragment)
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Store pixel coordinates (uv) in screen space
    vec2 uv = fragCoord.xy;
    // Compute center of screen using iResolution (width, height of render target)
    vec2 center = iResolution.xy * 0.5;
    // Define circle radius as 25% of screen height
    float radius = 0.25 * iResolution.y;
    // Set background layer color using normalized RGB (light bluish-gray)
    vec4 layer1 = vec4(rgb(210.0, 222.0, 228.0), 1.0);
    // Define the color for the circle (reddish-orange)
    vec3 red = rgb(225.0, 95.0, 60.0);
    // Create a colored circle layer at the screen center
    vec4 layer2 = circle(uv, center, radius, red);
   // Blend circle layer over background using the circle's alpha (anti-aliased edge)
    fragColor = mix(layer1, layer2, layer2.a);
}