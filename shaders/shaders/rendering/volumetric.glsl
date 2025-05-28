#define CLOUD_BASE -3.0
#define CLOUD_TOP  0.6
uniform sampler2D iChannel1;  /* !!!1024 × 1024 single-channel (R) blue-noise or white-noise texture provided by the engine.!!! */

/*
Input:
        ro(ray origin): world-space camera position
        rd(ray direction): normalised, from camera to object
        px(pixel coord): integer pixel coordinates (used for blue-noise dithering)
Output:
        vec4  – premultiplied colour (rgb) and accumulated opacity (a)
External dependencies:
        uniform sampler2D iChannel1  – 1024×1024 *single-channel* blue-noise
        float map(vec3 p, int oct)   – user-supplied density function
            map() must return  > 0.0  inside the cloud,
                                ≤ 0.0 outside (air)
*/
vec4 VolumeticRayMarch(vec3 ro, vec3 rd, ivec2 px) {
    float tb = (CLOUD_BASE - ro.y) / rd.y; 
    float tt = (CLOUD_TOP  - ro.y) / rd.y;

    float tmin, tmax; // integration segment
    if (ro.y > CLOUD_TOP)                   // camera above cloud
    {                                   
        if (tt < 0.0) return vec4(0.0);
        tmin = tt; tmax = tb;
    } 
    else if (ro.y < CLOUD_BASE)             // camera below cloud
    {
        if (tb < 0.0) return vec4(0.0);
        tmin = tb; tmax = tt;
    } 
    else                                    // camera inside cloud slab
    {
        tmin = 0.0;
        tmax = 60.0;
        if (tt > 0.0) tmax = min(tmax, tt);
        if (tb > 0.0) tmax = min(tmax, tb);
    }
    // Add blue-noise dither to the first sample position, helps break up banding artifacts
    float t = tmin + 0.1 * texelFetch(iChannel1, px & 1023, 0).x;
    vec4 sum = vec4(0.0);  // accumulated RGBA (premultiplied)
    const int oct = 5;       // FBM octave count (passed to map)

    for (int i = 0; i < 190; i++) {
        // adaptive step size: finer when close, coarser when fa
        float dt = max(0.05, 0.02 * t);
        vec3 pos = ro + t * rd;
        float den = map(pos, oct); /*!!! Density Function needed, Positive den → cloud/medium density  Negative or zero → empty air!!!*/

        if (den > 0.01) {
            float alpha = clamp(den, 0.0, 1.0);
            vec4 col = vec4(vec3(alpha), alpha);
            col.a = min(col.a * 8.0 * dt, 1.0);
            col.rgb *= col.a;
            sum += col * (1.0 - sum.a);
        }

        t += dt;
        // exit when outside the cloud or nearly opaque
        if (t > tmax || sum.a > 0.99) break;
    }
    // Clamp numeric drift and return premultiplied colour + alpha
    return clamp(sum, 0.0, 1.0);
}

/*
usage example:
    float map(vec3 p, int oct)
    ...
    void mainImage(out vec4 fragColor, in vec2 fragCoord)
    {
        ...
        // volume pass
        vec4 vol = VolumetricRayMarch(ro, rd, ivec2(fragCoord));

        // sky background
        vec3 sky = skyColour(rd);

        // compositing (premultiplied)
        vec3 col = mix(sky, vol.rgb, vol.a);

        fragColor = vec4(col, 1.0);
    } 
*/