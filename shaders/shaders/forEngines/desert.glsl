float layer1Amp = 2.0;
float later2Amp = 1.0;
float layer3Amp = 1.0;

float layer1Freq = 0.2;
float later2Freq = 0.275;
float layer3Freq = 0.5*3.0;

vec3 desertColor1 = vec3(1.0,.95,.7);
vec3 desertColor2 = vec3(.9,.6,.4);


// Desert noise functions
float n2D(vec2 p) {
    vec2 i = floor(p); p -= i; 
    p *= p*(3. - p*2.);   
    return dot(mat2(fract(sin(mod(vec4(0, 1, 113, 114) + dot(i, vec2(1, 113)), 6.2831853))*
               43758.5453))*vec2(1. - p.y, p.y), vec2(1. - p.x, p.x) );
}

float surfFunc( in vec3 p){
    p /= 2.5;
    float layer1 = n2D(p.xz*.2)*2. - .5;
    layer1 = smoothstep(0., 1.05, layer1);
    float layer2 = n2D(p.xz*.275);
    layer2 = 1. - abs(layer2 - .5)*2.;
    layer2 = smoothstep(.2, 1., layer2*layer2);
    float layer3 = n2D(p.xz*.5*3.);
    float res = layer1*.7 + layer2*.25 + layer3*.05;
    return res;
}

float mapDesert(vec3 p){
    float sf = surfFunc(p);
    return p.y + (.5-sf)*2.; 
}

// Desert ripple functions
mat2 rot2(in float a){ float c = cos(a), s = sin(a); return mat2(c, s, -s, c); }

vec2 hash22(vec2 p) {
    float n = sin(dot(p, vec2(113, 1)));
    p = fract(vec2(2097152, 262144)*n)*2. - 1.;
    return p;
}

float gradN2D(in vec2 f){
    const vec2 e = vec2(0, 1);
    vec2 p = floor(f);
    f -= p;
    vec2 w = f*f*(3. - 2.*f);
    float c = mix(mix(dot(hash22(p + e.xx), f - e.xx), dot(hash22(p + e.yx), f - e.yx), w.x),
                  mix(dot(hash22(p + e.xy), f - e.xy), dot(hash22(p + e.yy), f - e.yy), w.x), w.y);
    return c*.5 + .5;
}

float grad(float x, float offs){
    x = abs(fract(x/6.283 + offs - .25) - .5)*2.;
    float x2 = clamp(x*x*(-1. + 2.*x), 0., 1.);
    x = smoothstep(0., 1., x);
    return mix(x, x2, .15);
}

float sandL(vec2 p){
    vec2 q = rot2(3.14159/18.)*p;
    q.y += (gradN2D(q*18.) - .5)*.05;
    float grad1 = grad(q.y*80., 0.);
   
    q = rot2(-3.14159/20.)*p;
    q.y += (gradN2D(q*12.) - .5)*.05;
    float grad2 = grad(q.y*80., .5);
      
    q = rot2(3.14159/4.)*p;
    float a2 = dot(sin(q*12. - cos(q.yx*12.)), vec2(.25)) + .5;
    float a1 = 1. - a2;
    float c = 1. - (1. - grad1*a1)*(1. - grad2*a2);
    return c;
}

float sand(vec2 p){
    p = vec2(p.y - p.x, p.x + p.y)*.7071/4.;
    float c1 = sandL(p);
    vec2 q = rot2(3.14159/12.)*p;
    float c2 = sandL(q*1.25);
    return mix(c1, c2, smoothstep(.1, .9, gradN2D(p*vec2(4))));
}

float bumpSurf3D( in vec3 p){
    float n = surfFunc(p);
    vec3 px = p + vec3(.001, 0, 0);
    float nx = surfFunc(px);
    vec3 pz = p + vec3(0, 0, .001);
    float nz = surfFunc(pz);
    return sand(p.xz + vec2(n - nx, n - nz)/.001*1.);
}

vec3 doBumpMap(in vec3 p, in vec3 nor, float bumpfactor){
    const vec2 e = vec2(0.001, 0); 
    float ref = bumpSurf3D(p);
    vec3 grad = (vec3(bumpSurf3D(p - e.xyy),
                      bumpSurf3D(p - e.yxy),
                      bumpSurf3D(p - e.yyx)) - ref)/e.x; 
    grad -= nor*dot(nor, grad);          
    return normalize(nor + grad*bumpfactor);
}

void getDesertColor(vec3 p, out vec3 color) {
    float ripple = sand(p.xz);
    color = mix(vec3(1.0,.95,.7),  // light sand
                vec3(.9,.6,.4),    // darker trough
                ripple);
}
