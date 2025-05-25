// ==========================================
// Raymarching
// Category: Geometry
// Description: Raymarching steps based on different objects.
// ==========================================

// ------------------------------------------
// Input: float fieldOfView: The vertical field of view in degrees
//        vec2 size: Output image resolution
//        vec2 fragCoord: The current pixel coordinate
// Output: Ray direction
// Description: Calculate the ray direction for each pixel, 
//              typically used as the starting step in ray tracing or raymarching.
// ------------------------------------------
vec3 rayDirection(float fieldOfView, vec2 size, vec2 fragCoord) {
    vec2 xy = fragCoord - size / 2.0;
    float z = size.y / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3(xy, -z));
}

// ------------------------------------------
// Input: vec3 eye: Ray origin
//        vec3 marchingDirection: Ray direction
//        float start: Start distance
//        float end: Maximum distance
// Output: The shortest distance between the ray and the scene surface
// Description: The sceneSDF function can be used to compute the SDF for any geometry, 
//              including those resulting from CSG (Constructive Solid Geometry) operations.
// ------------------------------------------
float shortestDistanceToSurface(vec3 eye, vec3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = sceneSDF(eye + depth * marchingDirection);
        if (dist < EPSILON) return depth;
        depth += dist;
        if (depth >= end) return end;
    }
    return end;
}

// ------------------------------------------
// Input: vec3 ro: Ray origin
//        vec3 rd: Ray direction
//        vec3 bgcol: Background color
//        ivec2 px: The current pixel coordinate
//        sampler2D texture2DInput
//        int kDiv: Raymarch sampling density
//        vec3 sundir: Sunlight dir
// Output: The color resulting from the interaction between the ray and the volume in the scene, 
//         including lighting and transparency
// Description: The function performs raymarching by calculating the interaction region between the ray and the volume.
//              The map function (often combined with FBM noise) is used to generate the detail noise value for each position.
//              At each sample, the lighting and color are computed, and the background color is blended based on the transparency.
//              The raymarching stops when the maximum step count is reached or when the total transparency exceeds the threshold.  
// ------------------------------------------
vec4 raymarchVolume(in vec3 ro, in vec3 rd, in vec3 bgcol, in ivec2 px, sampler2D texture2DInput,int kDiv, vec3 sundir)
{
    const float yb = -3.0;
    const float yt = 0.6;
    float tb = (yb - ro.y) / rd.y;
    float tt = (yt - ro.y) / rd.y;

    float tmin, tmax;
    if (ro.y > yt)
    {
      if (tt < 0.0) return vec4(0.0); 
        tmin = tt;
        tmax = tb;
    }
    else if (ro.y < yb)
    {
        if (tb < 0) return vec4(0.0);
        tmin = tb;
        tmax = tt;
    }
    else
    {
        tmin = 0.0;
        tmax = 60.0;
        if (tt > 0.0) tmax = min(tmax, tt);
        if (tb > 0.0) tmax = min(tmax, tb);
    }

    float t = tmin + 0.1 * texelFetch(texture2DInput, px & 1023, 0).x;

    // ----------------Raymarch Loop----------------
    vec4 sum = vec4(0.0);
    for (int i = 0; i < 190 * kDiv; i++)
    {
        float dt = max(0.05, 0.02 * t / float(kDiv));

        const int oct = 5;
        int oct = 5 - int(log2(1.0 + t * 0.5));

        vec3 pos = ro + t * rd;
        float den = map(pos, oct);
        if (den > 0.01) 
        {
            float dif = clamp((den - map(pos + 0.3 * sundir, oct)) / 0.25, 0.0, 1.0);
            vec3  lin = vec3(0.65, 0.65, 0.75) * 1.1 + 0.8 * vec3(1.0, 0.6, 0.3) * dif;
            vec4  col = vec4(mix(vec3(1.0, 0.93, 0.84), vec3(0.25, 0.3, 0.4), den), den);
            col.xyz *= lin;
            col.xyz = mix(col.xyz, bgcol, 1.0 - exp2(-0.1 * t));
            col.w = min(col.w * 8.0 * dt, 1.0);
            col.rgb *= col.a;
            sum += col * (1.0 - sum.a);
        }
        t += dt;
        if (t > tmax || sum.a > 0.99) break;
    }
    return clamp(sum, 0.0, 1.0);
}
