/*
Given the camera position (ro), view ray (rd) and a sun-direction (ld) this file returns a
physically–plausible sky colour with horizon gradient, sun disk, flare and soft cloud layer.
*/

#define RIGID // Set to rigid==true (static hash) – delete for animated clouds

// Standard 2x2 hash algorithm.
vec2 hash22(vec2 p) {
    
    // Faster, but probaly doesn't disperse things as nicely as other methods.
    float n = sin(dot(p, vec2(113, 1)));
    p = fract(vec2(2097152, 262144)*n)*2. - 1.;
    #ifdef RIGID
    return p;
    #else
    return cos(p*6.283 + iGlobalTime);
    //return abs(fract(p+ iGlobalTime*.25)-.5)*2. - .5; // Snooker.
    //return abs(cos(p*6.283 + iGlobalTime))*.5; // Bounce.
    #endif

}

/*
Classic 2-D gradient noise (one octave of Perlin noise)
    input:
        f – point to sample (continuous coordinates) 
    output:
        scalar noise value in [0, 1]
*/
float gradN2D(in vec2 f){
    
    // Used as shorthand to write things like vec3(1, 0, 1) in the short form, e.yxy. 
   const vec2 e = vec2(0, 1);
   
    // Set up the cubic grid.
    // Integer value - unique to each cube, and used as an ID to generate random vectors for the
    // cube vertiies. Note that vertices shared among the cubes have the save random vectors attributed
    // to them.
    vec2 p = floor(f);
    f -= p; // Fractional position within the cube.
    

    // Smoothing - for smooth interpolation. Use the last line see the difference.
    //vec2 w = f*f*f*(f*(f*6.-15.)+10.); // Quintic smoothing. Squarish, but derivatives are smooth too.
    vec2 w = f*f*(3. - 2.*f); // Cubic smoothing. 
    //vec2 w = f*f*f; w = ( 7. + (w - 7. ) * f ) * w; // Super smooth, but less practical.
    //vec2 w = .5 - .5*cos(f*3.14159); // Cosinusoidal smoothing.
    //vec2 w = f; // No smoothing. Gives a blocky appearance.
    
    // Smoothly interpolating between the four verticies of the square. Due to the shared vertices between
    // grid squares, the result is blending of random values throughout the 2D space. By the way, the "dot" 
    // operation makes most sense visually, but isn't the only metric possible.
    float c = mix(mix(dot(hash22(p + e.xx), f - e.xx), dot(hash22(p + e.yx), f - e.yx), w.x),
                  mix(dot(hash22(p + e.xy), f - e.xy), dot(hash22(p + e.yy), f - e.yy), w.x), w.y);
    
    // Taking the final result, and converting it to the zero to one range.
    return c*.5 + .5; // Range: [0, 1].
}

/*
2-D fractal Brownian motion – three octaves, fixed weights
    input: 
        p – point to sample
    output:
        scalar noise value approx. in [0,1]
*/
float fBm(in vec2 p){
    
    return gradN2D(p)*.57 + gradN2D(p*2.)*.28 + gradN2D(p*4.)*.15;
    
}

/*
Evaluate procedural sky colour with sun and distant cloud band
    input:
        ro : camera/world position                                         
        rd : unit view direction for the current pixel                     
        ld : unit vector pointing *towards* the sun (main light direction) 
    output:
        RGB sky colour in linear space    
*/
vec3 getSky(vec3 ro, vec3 rd, vec3 ld){ 
    
    // Sky color gradients.
    vec3 col = vec3(.8, .7, .5), col2 = vec3(.4, .6, .9);
    
    //return mix(col, col2, pow(max(rd.y*.5 + .9, 0.), 5.));  // Probably a little too simplistic. :)
     
    // Mix the gradients using the Y value of the unit direction ray. 
    vec3 sky = mix(col, col2, pow(max(rd.y + .15, 0.), .5));
    sky *= vec3(.84, 1, 1.17); // Adding some extra vibrancy.
     
    float sun = clamp(dot(ld, rd), 0., 1.);
    sky += vec3(1, .7, .4)*vec3(pow(sun, 16.))*.2; // Sun flare, of sorts.
    sun = pow(sun, 32.); // Not sure how well GPUs handle really high powers, so I'm doing it in two steps.
    sky += vec3(1, .9, .6)*vec3(pow(sun, 32.))*.35; // Sun.
    
     // Subtle, fake sky curvature.
    rd.z *= 1. + length(rd.xy)*.15;
    rd = normalize(rd);
   
    // A simple way to place some clouds on a distant plane above the terrain -- Based on something IQ uses.
    const float SC = 1e5;
    float t = (SC - ro.y - .15)/(rd.y + .15); // Trace out to a distant XZ plane.
    vec2 uv = (ro + t*rd).xz; // UV coordinates.
    
    // Mix the sky with the clouds, whilst fading out a little toward the horizon (The rd.y bit).
	if(t>0.) sky =  mix(sky, vec3(2), smoothstep(.45, 1., fBm(1.5*uv/SC))*
                        smoothstep(.45, .55, rd.y*.5 + .5)*.4);
    
    // Return the sky color.
    return sky;
}