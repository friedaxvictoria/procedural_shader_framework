// ==========================================
// Shader: Square Shader
// Category: Geometry
// Description: Draws a centered red square using an SDF approach.
// Screenshot: screenshots/geometry/square.png
// ==========================================

/*
 * Signed Distance Function for a square.
 *
 * Inputs:
 *   uv     - vec2 : normalized and centered coordinates of the current fragment
 *   size   - float: half-length of the square's side
 *   offset - vec2 : position of the square's center in UV space
 *
 * Output:
 *   vec3   - RGB color:
 *              - red (1, 0, 0) if the fragment is inside or on the square
 *              - white (1, 1, 1) if the fragment is outside the square
 */
vec3 sdfSquare(vec2 uv, float size, vec2 offset) {
  // Shift the UV coordinates relative to the square's center (offset)
  float x = uv.x - offset.x;
  float y = uv.y - offset.y;

  // Compute the signed distance from the current point to the square's edge
  // Uses max(abs(x), abs(y)) for an axis-aligned square SDF
  float d = max(abs(x), abs(y)) - size;

  // If the point is outside the square (distance > 0), return white
  // If inside or on the edge (distance <= 0), return red
  return d > 0. ? vec3(1.) : vec3(1., 0., 0.);
}

// Main shader function
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  // Normalize pixel coordinates to range [0, 1]
  vec2 uv = fragCoord/iResolution.xy; 
  // Center the coordinates around (0, 0)  <-0.5,0.5>
  uv -= 0.5; 

  // Correct the aspect ratio so the square doesn't stretch
  uv.x *= iResolution.x/iResolution.y; 

  // Define the square's center offset (here, centered)
  vec2 offset = vec2(0.0, 0.0);

  // Get color based on whether the current UV is inside the square
  vec3 col = sdfSquare(uv, 0.2, offset);

  // Output to screen
  fragColor = vec4(col,1.0);
}
