/*
This shader module creates volumetric fog (mist) using ray-marched noise layers.
It works by tracing from the camera position (ro) towards the scene hit point (t), sampling multiple layers of 3D procedural noise, and combining them with simple distance-based attenuation
*/
#define FAR 80.

/*
    input:  
        vec3 p: The 3D point to evaluate noise at.
    output:
        float: A scalar noise value in the range [0.0, 1.0].

*/
// Generates a smooth 3D scalar noise value at a given position p.
float noise3D(in vec3 p){
    
    // Just some random figures, analogous to stride. You can change this, if you want.
	const vec3 s = vec3(113, 157, 1);
	
	vec3 ip = floor(p); // Unique unit cell ID.
    
    // Setting up the stride vector for randomization and interpolation, kind of. 
    // All kinds of shortcuts are taken here. Refer to IQ's original formula.
    vec4 h = vec4(0., s.yz, s.y + s.z) + dot(ip, s);
    
	p -= ip; // Cell's fractional component.
	
    // A bit of cubic smoothing, to give the noise that rounded look.
    p = p*p*(3. - 2.*p);
    
    // Standard 3D noise stuff. Retrieving 8 random scalar values for each cube corner,
    // then interpolating along X. There are countless ways to randomize, but this is
    // the way most are familar with: fract(sin(x)*largeNumber).
    h = mix(fract(sin(h)*43758.5453), fract(sin(h + s.x)*43758.5453), p.x);
	
    // Interpolating along Y.
    h.xy = mix(h.xz, h.yw, p.y);
    
    // Interpolating along Z, and returning the 3D noise value.
    return mix(h.x, h.y, p.z); // Range: [0, 1].
	
}
/*
    input:
        vec3 ro: Ray origin (camera position)
        vec3 rd: Ray direction (normalized)
        vec3 lp: Light position (used for fog illumination attenuation)
        float t: Distance to the hit surface (used to limit fog sampling range)
    output:
        float: Final mist value along the ray (range: approx 0.0 – 0.3 or more depending on density)
Traces along the ray direction from the camera (ro) to the surface hit point (t), sampling fog/mist density based on multiple octaves of 3D noise, and accumulating the result with simple light attenuation.
*/
float getMist(in vec3 ro, in vec3 rd, in vec3 lp, in float t){

    float mist = 0.;
    
    //ro -= vec3(0, 0, iTime*3.);
    
    float t0 = 0.;
    
    for (int i = 0; i<24; i++){
        
        // If we reach the surface, don't accumulate any more values.
        if (t0>t) break; 
        
        // Lighting. Technically, a lot of these points would be
        // shadowed, but we're ignoring that.
        float sDi = length(lp-ro)/FAR; 
	    float sAtt = 1./(1. + sDi*.25);
	    
        // Noise layer.
        vec3 ro2 = (ro + rd*t0)*2.5;
        float c = noise3D(ro2)*.65 + noise3D(ro2*3.)*.25 + noise3D(ro2*9.)*.1;
        //float c = noise3D(ro2)*.65 + noise3D(ro2*4.)*.35; 

        float n = c;//max(.65-abs(c - .5)*2., 0.);//smoothstep(0., 1., abs(c - .5)*2.);
        mist += n*sAtt;
        
        // Advance the starting point towards the hit point. You can 
        // do this with constant jumps (FAR/8., etc), but I'm using
        // a variable jump here, because it gave me the aesthetic 
        // results I was after.
        t0 += clamp(c*.25, .1, 1.);
        
    }
    
    // Add a little noise, then clamp, and we're done.
    return max(mist/48., 0.);
    
    // A different variation (float n = (c. + 0.);)
    //return smoothstep(.05, 1., mist/32.);

}