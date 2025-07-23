/*
 Finds the first intersection between a camera ray and a single-valued height field.

  Inputs:
    ro    – ray origin in world space (e.g., camera position)
    rd    – normalized ray direction (from camera into scene)
    tmin  – starting distance along ray (e.g., near‐plane or entry point)
    tmax  – maximum distance along ray (e.g., far‐plane or bounding height intersection)
 
  Output:
    float – distance t along the ray where it first crosses the terrain surface;
            if no intersection within [tmin, tmax], returns a value ≥ tmax.
  External dependencies:
   float terrainM(vec2 xz);
      // user-defined height function: given world‐space (x,z), returns terrain height y.
 */
float heightfield_raycast(in vec3 ro, in vec3 rd, in float tmin, in float tmax)
{
    float t = tmin;                       // start from tmin

    for (int i = 0; i < 300; i++)
    {
        vec3 pos = ro + t * rd;           // current position along the ray
        float h   = pos.y - terrainM(pos.xz);
                                           // h = current point altitude − terrain height at (x, z)
        // if |h| < 0.0015 * t or t > tmax, stop
        if (abs(h) < (0.0015 * t) || t > tmax)
            break;

        // otherwise advance by 0.4 * h
        t += 0.4 * h;
    }

    return t;
}
/*
Usage example (inside a render function):

float terrainM(vec2 xz) {
    // ... user-defined height field ...
}

vec4 render(in vec3 ro, in vec3 rd)
{
    // 1. Determine ray–terrain bounding distance
    float tmin = 1.0;
    float tmax = FAR_DISTANCE; // some large value or computed from sky plane intersection

    // 2. Call heightfield_raycast to get hit distance
    float t = heightfield_raycast(ro, rd, tmin, tmax);

    vec3 color;
    if (t >= tmax) {
        // no hit → render sky
        color = skyColour(rd);
    } else {
        // hit at t < tmax → render terrain surface
        vec3 pos = ro + rd * t;             // intersection point
        vec3 nor = calcNormalHF(pos);       // compute normal from height field
        color = shadeTerrain(pos, nor, rd); // lighting/material for terrain
    }

    return vec4(color, 1.0);
}
*/