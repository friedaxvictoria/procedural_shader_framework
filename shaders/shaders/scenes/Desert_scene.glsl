/*
Building the desert scene needs three ingredients:
1. Height Field (Dunes)	
Lay a wavy elevation map on the flat y = 0 plane. This big-scale height map decides where the sand rises and dips, sculpting the large dunes.	
2. Ripples / Dune Ridges	
On top of every point of that terrain, stamp millimetre-to-centimetre repeating patterns. These small waves look like wind-carved ripple lines.	
3. Bump & Color Detail	
Push the ripple pattern into the surface normal with bump-mapping and tint the sand with a little extra noise. This finishes the fine “grains” and tiny self-shadowing that make the sand feel real.
*/



/**********************************************************  Height Field (Dunes)  *******************************************************************/
/*
What these four functions do together
They take flat 2-D noise and turn it into a 3-D signed-distance field (SDF) that a ray-marcher can walk on:

n2D – produces the base smooth 2-D noise signal.

surfFunc – blends three frequency bands of that noise into a 0-to-1 dune height-map.

camSurfFunc – cheaper two-band variant used only to lift/tilt the camera along the dunes.

map – displaces an X-Z plane by the height-map and returns the signed distance, giving a ray-march-ready desert SDF.
*/
// Cheap smooth 2-D noise: quick, inline Perlin-style noise in [0,1].
// input: p(vec2) – sample position in the X-Z plane
// output: float  – noise value in the range [0 ,1]
float n2D(vec2 p) {

	vec2 i = floor(p); p -= i; 
    
    p *= p*(3. - p*2.);   
    
    return dot(mat2(fract(sin(mod(vec4(0, 1, 113, 114) + dot(i, vec2(1, 113)), 6.2831853))*
               43758.5453))*vec2(1. - p.y, p.y), vec2(1. - p.x, p.x) );

}

//blend three noise layers (low/medium/high freq) to build dunes.
//input : p(vec3) – world position
//output : float   – dune height factor (0-1)
float surfFunc( in vec3 p){
    
    p /= 2.5;
    
    // Large base ampltude with lower frequency.
    float layer1 = n2D(p.xz*.2)*2. - .5; // Linear-like discontinuity - Gives an edge look.
    layer1 = smoothstep(0., 1.05, layer1); // Smoothing the sharp edge.

    // Medium amplitude with medium frequency. 
    float layer2 = n2D(p.xz*.275);
    layer2 = 1. - abs(layer2 - .5)*2.; // Triangle function, to give the dune edge look.
    layer2 = smoothstep(.2, 1., layer2*layer2); // Smoothing the sharp edge.
    
    // Smaller, higher frequency layer.
	float layer3 = n2D(p.xz*.5*3.);

     // Combining layers fBm style. Ie; Amplitudes inversely proportional to frequency.
    float res = layer1*.7 + layer2*.25 + layer3*.05;

    return res;
    
}

// cheaper variant of surfFunc (no high-freq layer); keeps camera motion stable while costing less.
// input: p(vec3) – world position
// output: float   – dune height factor (0-1)
float camSurfFunc( in vec3 p){
    
    p /= 2.5;
    
    // Large base ampltude with lower frequency.
    float layer1 = n2D(p.xz*.2)*2. - .5; // Linear-like discontinuity - Gives an edge look.
    layer1 = smoothstep(0., 1.05, layer1); // Smoothing the sharp edge.

    // Medium amplitude with medium frequency. 
    float layer2 = n2D(p.xz*.275);
    layer2 = 1. - abs(layer2 - .5)*2.; // Triangle function, to give the dune edge look.
    layer2 = smoothstep(.2, 1., layer2*layer2); // Smoothing the sharp edge.

     // Combining layers fBm style. Ie; Amplitudes inversely proportional to frequency.
    float res = (layer1*.7 + layer2*.25)/.95;

    return res;
    
}

// The desert scene. Adding a heightmap to an XZ plane. convert surfFunc height into an SDF: >0 air, <0 sand surface.
// input: p(vec3) – sample point in world space
// output: float   – signed distance (positive above ground)
float map(vec3 p){
    
    float sf = surfFunc(p);

    // Add the height map to the plane.
    return p.y + (.5-sf)*2.; 
 
}


/*********************************************************   Ripples / Dune Ridges   **************************************************************/
/*
rot2 → hash22 → gradN2D → grad → sandL → sand form a pipeline that synthesises the millimetre-to-centimetre ripples sitting on top of the large dunes.

1. hash22 + gradN2D generate a low-frequency noise mask that slightly warps the grid.

2. grad creates a tileable rounded-triangle waveform that acts as the basic ridge profile.

3. sandL takes two copies of that ridge field, rotates them, perturbs them with the noise, then screen-blends the pair to obtain Λ-shaped ripple lines.

4. sand stacks two sandL layers at different angles / scales and fades them with view-distance, outputting the final 0-to-1 ripple-height map.
*/
//2-D rotation matrix
//input: a  – rotation angle in radians
//output: mat2( … ) – column-major 2×2 matrix that rotates a 2-D vector by +a
mat2 rot2(in float a){ float c = cos(a), s = sin(a); return mat2(c, s, -s, c); }

#define RIGID
// small 2-D hash → pseudo-random gradient
//input: p  – cell coordinates
//output: vec2 in [-1, +1] – pseudo-random direction
vec2 hash22(vec2 p) {
    
    // Faster, but probaly doesn't disperse things as nicely as other methods.
    float n = sin(dot(p, vec2(113, 1)));
    p = fract(vec2(2097152, 262144)*n)*2. - 1.;
    #ifdef RIGID
    return p;
    #else
    return cos(p*6.283 + iGlobalTime);
    #endif

}

// classic Perlin-style 2-D gradient noise
//input: f  – position in continuous 2-D space
//output: scalar in [0,1]
float gradN2D(in vec2 f){
    
    // Used as shorthand to write things like vec3(1, 0, 1) in the short form, e.yxy. 
   const vec2 e = vec2(0, 1);
    vec2 p = floor(f);
    f -= p; // Fractional position within the cube.
    
    vec2 w = f*f*(3. - 2.*f); // Cubic smoothing. 
    float c = mix(mix(dot(hash22(p + e.xx), f - e.xx), dot(hash22(p + e.yx), f - e.yx), w.x),
                  mix(dot(hash22(p + e.xy), f - e.xy), dot(hash22(p + e.yy), f - e.yy), w.x), w.y);
    
    // Taking the final result, and converting it to the zero to one range.
    return c*.5 + .5; // Range: [0, 1].
}

// repeated rounded-triangle pulse, gives the longitudinal “ripple” ridges on dunes
// input: x     – 1-D coordinate (any scale) 
//        offs – phase offset (0-1)
//output: scalar [0,1] – soft ridge profile
float grad(float x, float offs){
    
    // Repeat triangle wave. The tau factor and ".25" factor aren't necessary, but I wanted its frequency
    // to overlap a sine function.
    x = abs(fract(x/6.283 + offs - .25) - .5)*2.;
    
    float x2 = clamp(x*x*(-1. + 2.*x), 0., 1.); // Customed smoothed, peaky triangle wave.
    //x *= x*x*(x*(x*6. - 15.) + 10.); // Extra smooth.
    x = smoothstep(0., 1., x); // Basic smoothing - Equivalent to: x*x*(3. - 2.*x).
    return mix(x, x2, .15);
}

// one procedural ripple layer
//input: p  – 2-D world / texture coords (meters) 
//output: scalar [0,1] – height contribution 
float sandL(vec2 p){
    
    // Layer one. 
    vec2 q = rot2(3.14159/18.)*p; // Rotate the layer, but not too much.
    q.y += (gradN2D(q*18.) - .5)*.05; // Perturb the lines to make them look wavy.
    float grad1 = grad(q.y*80., 0.); // Repeat gradient lines.
   
    q = rot2(-3.14159/20.)*p; // Rotate the layer back the other way, but not too much.
    q.y += (gradN2D(q*12.) - .5)*.05; // Perturb the lines to make them look wavy.
    float grad2 = grad(q.y*80., .5); // Repeat gradient lines.
      
    q = rot2(3.14159/4.)*p;
    
    // The mixes above will work, but I wanted to use a subtle screen blend of grad1 and grad2.
    float a2 = dot(sin(q*12. - cos(q.yx*12.)), vec2(.25)) + .5;
    float a1 = 1. - a2;
    
    // Screen blend.
    float c = 1. - (1. - grad1*a1)*(1. - grad2*a2);
    
    // Smooth max\min
    //float c = smax(grad1*a1, grad2*a2, .5);
   
    return c;
    
    
}

float gT;

//final two-layer dune-ripple map
//input: p  – 2-D coords (after 45° rot & zoom)
//output: scalar [0,1]  – ripple height
float sand(vec2 p){
    
    p = vec2(p.y - p.x, p.x + p.y)*.7071/4.;
    
    // Sand layer 1.
    float c1 = sandL(p);
    
    // Second layer.
    // Rotate, then increase the frequency -- The latter is optional.
    vec2 q = rot2(3.14159/12.)*p;
    float c2 = sandL(q*1.25);
    
    // Mix the two layers with some underlying gradient noise.
    c1 = mix(c1, c2, smoothstep(.1, .9, gradN2D(p*vec2(4))));
    return c1/(1. + gT*gT*.015);
}



/**********************************************************  Bump & Color Detail  *******************************************************************/
// compact 3-D value noise 
//input: vec3 p  - sample position
//output: float   - noise value [0,1]
float n3D(in vec3 p){
    
	const vec3 s = vec3(113, 157, 1);
	vec3 ip = floor(p); p -= ip; 
    vec4 h = vec4(0., s.yz, s.y + s.z) + dot(ip, s);
    p = p*p*(3. - 2.*p); //p *= p*p*(p*(p * 6. - 15.) + 10.);
    h = mix(fract(sin(h)*43758.5453), fract(sin(h + s.x)*43758.5453), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z); // Range: [0, 1].
}

// fractal Brownian motion noise 
//input: vec3 p  - sample position
//output: float   - fbm noise value [0,1]
float fBm(in vec3 p){
    
    return n3D(p)*.57 + n3D(p*2.)*.28 + n3D(p*4.)*.15;
    
}

// 3x1 hash function.
//input : vec3 p  - any vector key
//output: float   - pseudo-random [0,1]
float hash( vec3 p ){ return fract(sin(dot(p, vec3(21.71, 157.97, 113.43)))*45758.5453); }


// micro-height for bumps 
//input : vec3 p  - world position 
//output : float   - bump height 0-1
float bumpSurf3D( in vec3 p){

    float n = surfFunc(p);
    vec3 px = p + vec3(.001, 0, 0);
    float nx = surfFunc(px);
    vec3 pz = p + vec3(0, 0, .001);
    float nz = surfFunc(pz);
    
    // The wavy sand, that has been perturbed by the underlying terrain.
    return sand(p.xz + vec2(n - nx, n - nz)/.001*1.);

}

// turn scalar bumps into a perturbed normal 
//in : vec3 p        – position 
//     vec3 nor      – unperturbed normal 
//     float bumpfactor 
//output : vec3      – perturbed unit normal
vec3 doBumpMap(in vec3 p, in vec3 nor, float bumpfactor){
    const vec2 e = vec2(0.001, 0); 
    
    // Gradient vector: vec3(df/dx, df/dy, df/dz);
    float ref = bumpSurf3D(p);
    vec3 grad = (vec3(bumpSurf3D(p - e.xyy),
                      bumpSurf3D(p - e.yxy),
                      bumpSurf3D(p - e.yyx)) - ref)/e.x; 

    grad -= nor*dot(nor, grad);          
         
    // Applying the gradient vector to the normal. Larger bump factors make things more bumpy.
    return normalize(nor + grad*bumpfactor);
}










/*
usage example:
# include Desert_scene.glsl

#define FAR 80.0

//––– very light-weight ray marcher ––––––––––––––––
float trace(vec3 ro, vec3 rd)                 // returns hit-distance (or FAR)
{
    float t = 0.0;            // travelled distance
    for(int i = 0; i < 96; ++i)
    {
        float d = map(ro + rd*t);             // map() = dune SDF
        if(abs(d) < 0.001 || t > FAR) break;  // hit or too far
        t += d;
    }
    return min(t, FAR);
}

//––– six-tap central-diff normal (cheap version works too) ––
vec3 normal(vec3 p)
{
    const vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),           ///////////////////////////////// here use map(in Dunes) /////////////////////////////////
        map(p + e.yyx) - map(p - e.yyx)));
}

//––– simple lambert for the demo –––––––––––––––––––
vec3 shadeLambert(vec3 n, vec3 lDir, vec3 baseCol)
{
    float dif = max(dot(n, lDir), 0.0);
    return baseCol * dif;
}

//–––– entry point ––––––––––––––––––––––––––––––––––
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // camera
    vec2  uv = (fragCoord - 0.5*iResolution.xy)/iResolution.y;
    vec3  ro = vec3(0.0, 1.8, -4.0);          // eye
    vec3  rd = normalize(vec3(uv, 1.8));      // view dir
    
    // 1. ray–march against dune SDF
    float t  = trace(ro, rd);
    vec3  col = vec3(0.8, 0.9, 1.0);          // background sky
    
    if(t < FAR)                               // hit ground
    {
        // 2. position & base normal
        vec3 p  = ro + rd*t;
        vec3 n  = normal(p);
        
        // 3.inject ripple-&-grain normal detail
        n = doBumpMap(p, n, 0.07);            // bumpfactor ≈ 0.05–0.10   ///////////////////////////////// here use doBumpMap(in Details) /////////////////////////////////
        
        // 4.(optional) use sand() to tint colour
        float ripple = sand(p.xz);            // 0-1 ripple mask  ///////////////////////////////// here use sand(in Ripples) /////////////////////////////////
        vec3  base   = mix(vec3(1.0,.95,.7),  // light sand
                           vec3(.9,.6,.4),    // darker trough
                           ripple);
        
        // 5. shade
        vec3 lightDir = normalize(vec3(0.4, 0.6, 0.7));
        col = shadeLambert(n, lightDir, base);
    }
    
    fragColor = vec4(col, 1.0);
}

*/








