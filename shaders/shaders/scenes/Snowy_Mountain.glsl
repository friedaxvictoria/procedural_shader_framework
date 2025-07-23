// Pure Snowy Mountain Shader with Mouse-Controlled Camera
// Based on original by Alexander Alekseev aka TDM
// From Wanzhang He

const int NUM_STEPS = 64;
const float PI = 3.1415;
const float EPSILON = 1e-3;

// Terrain parameters
const int ITER_GEOMETRY = 7;
const int ITER_FRAGMENT = 10;
const float TERR_HEIGHT = 12.0;
const float TERR_WARP = 0.7;
const float TERR_OCTAVE_AMP = 0.58;
const float TERR_OCTAVE_FREQ = 2.5;
const float TERR_MULTIFRACT = 0.27;
const float TERR_CHOPPY = 1.9;
const float TERR_FREQ = 0.24;
const vec2 TERR_OFFSET = vec2(13.5,15.);

// Colors
const vec3 COLOR_SNOW = vec3(1.0,1.0,1.1) * 2.2;
const vec3 COLOR_ROCK = vec3(0.0,0.0,0.1);
const vec3 LIGHT_DIR = normalize(vec3(1.0,1.0,-0.3));
const vec3 LIGHT_COLOR = vec3(1.,1.,0.98) * 0.7;

// Rotation matrix
mat3 rotationMatrix(vec3 ang) {
    vec2 a1 = vec2(sin(ang.x), cos(ang.x));
    vec2 a2 = vec2(sin(ang.y), cos(ang.y));
    vec2 a3 = vec2(sin(ang.z), cos(ang.z));
    return mat3(
        a1.y*a3.y+a1.x*a2.x*a3.x, a1.y*a2.x*a3.x+a3.y*a1.x, -a2.y*a3.x,
        -a2.y*a1.x, a1.y*a2.y, a2.x,
        a3.y*a1.x*a2.x+a1.y*a3.x, a1.x*a3.x-a1.y*a3.y*a2.x, a2.y*a3.y
    );
}

// Hash & noise
float hash(vec2 p) {
    uint n = floatBitsToUint(p.x * 122.0 + p.y);
    n = (n << 13U) ^ n;
    n = n * (n * n * 15731U + 789221U) + 1376312589U;
    return uintBitsToFloat((n>>9U) | 0x3f800000U) - 1.0;
}

vec3 noiseDerivatives(in vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);	
    vec2 u = f*f*(3.0-2.0*f);
    
    float a = hash(i + vec2(0.0,0.0));
    float b = hash(i + vec2(1.0,0.0));    
    float c = hash(i + vec2(0.0,1.0));
    float d = hash(i + vec2(1.0,1.0));    
    float h1 = mix(a,b,u.x);
    float h2 = mix(c,d,u.x);
                              
    return vec3(
        abs(mix(h1,h2,u.y)),
        6.0*f*(1.0-f)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx)
    );
}

vec3 terrainOctave(vec2 uv) {
    vec3 n = noiseDerivatives(uv);
    return vec3(pow(n.x, TERR_CHOPPY), n.y, n.z);
}

float terrainHeight(vec3 p) {
    float frq = TERR_FREQ;
    float amp = 1.0;
    vec2 uv = p.xz * frq + TERR_OFFSET;
    vec2 dsum = vec2(0.0);
    
    float h = 0.0;    
    for(int i = 0; i < ITER_GEOMETRY; i++) {          
        vec3 n = terrainOctave((uv - dsum * TERR_WARP) * frq);
        h += n.x * amp;       
        dsum += n.yz * (n.x*2.0-1.0) * amp;
        frq *= TERR_OCTAVE_FREQ;
        amp *= TERR_OCTAVE_AMP;        
        amp *= pow(n.x, TERR_MULTIFRACT);
    }
    h *= TERR_HEIGHT / (1.0 + dot(p.xz,p.xz) * 1e-3);
    return p.y - h;
}

float detailedTerrainHeight(vec3 p) {
    float frq = TERR_FREQ;
    float amp = 1.0;
    vec2 uv = p.xz * frq + TERR_OFFSET;
    vec2 dsum = vec2(0.0);
    
    float h = 0.0;    
    for(int i = 0; i < ITER_FRAGMENT; i++) {        
        vec3 n = terrainOctave((uv - dsum * TERR_WARP) * frq);
        h += n.x * amp;
        dsum += n.yz * (n.x*2.0-1.0) * amp;
        frq *= TERR_OCTAVE_FREQ;
        amp *= TERR_OCTAVE_AMP;
        amp *= pow(n.x, TERR_MULTIFRACT);
    }
    h *= TERR_HEIGHT / (1.0 + dot(p.xz,p.xz) * 1e-3);
    return p.y - h;
}

// Lighting
float calculateDiffuse(vec3 n, vec3 l, float p) { 
    return pow(max(dot(n,l), 0.0), p); 
}

float calculateSpecular(vec3 n, vec3 l, vec3 e, float s) {    
    float nrm = (s + 8.0) / (3.1415 * 8.0);
    return pow(max(dot(reflect(e,n), l), 0.0), s) * nrm;
}

vec3 calculateTerrainColor(in vec3 p, in vec3 n) {
    float slope = 1.0 - dot(n, vec3(0.,1.,0.));     
    vec3 ret = mix(COLOR_SNOW, COLOR_ROCK, smoothstep(0.0, 0.2, slope*slope));
    ret = mix(ret, COLOR_SNOW, clamp(smoothstep(0.6, 0.8, slope+(p.y-TERR_HEIGHT*0.5)*0.05), 0.0, 1.0));
    return ret;
}

float calculateAO(vec3 p) {
    float frq = TERR_FREQ;
    float amp = 1.0;
    vec2 uv = p.xz * frq + TERR_OFFSET;
    vec2 dsum = vec2(0.0);
    
    float h = 1.0;    
    for(int i = 0; i < ITER_FRAGMENT; i++) {        
        vec3 n = terrainOctave((uv - dsum * TERR_WARP) * frq);
        float it = float(i)/float(ITER_FRAGMENT-1);
        float iao = mix(sqrt(n.x), 1.0, it*0.9);
        iao = mix(iao, 1.0, 1.0 - it);
        h *= iao;
        dsum += n.yz * (n.x*2.0-1.0) * amp;
        frq *= TERR_OCTAVE_FREQ;
        amp *= TERR_OCTAVE_AMP;
        amp *= pow(n.x, TERR_MULTIFRACT);
    }
    return sqrt(h*2.0);
}

// Ray tracing
vec3 calcNormal(vec3 p, float eps) {
    vec3 n;
    n.y = detailedTerrainHeight(p);    
    n.x = detailedTerrainHeight(p + vec3(eps, 0, 0)) - n.y;
    n.z = detailedTerrainHeight(p + vec3(0, 0, eps)) - n.y;
    n.y = eps;
    return normalize(n);
}

bool traceTerrain(vec3 ori, vec3 dir, out vec3 p, out float t) {
    t = 0.0;
    for(int i = 0; i < NUM_STEPS; i++) {
        p = ori + dir * t;
        float d = terrainHeight(p);
        if(d < 0.0) return true;
        t += d * 0.6;
    }
    return false;
}

// mountain
vec3 renderMountain(vec2 fragCoord, vec2 iResolution) {
    vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    // fixed camera
    float yaw = -0.15;
    float pitch = 0.1;
    vec3 ang = vec3(pitch, yaw, 0.0);
    mat3 rot = rotationMatrix(ang);

    vec3 ori = vec3(0.0, 5.0, 40.0) * rot;
    vec3 dir = normalize(vec3(uv.xy, -2.0)) * rot;
    dir.z += length(uv) * 0.12;
    dir = normalize(dir);

    ori.y -= terrainHeight(ori) * 0.75 - 3.0;

    vec3 p;
    float t;
    if (!traceTerrain(ori, dir, p, t)) return vec3(0.0);

    vec3 dist = p - ori;
    vec3 n = calcNormal(p, dot(dist, dist) * (1e-1 / iResolution.x));
    float ao = calculateAO(p);
    vec3 col = calculateTerrainColor(p, n);

    col += calculateDiffuse(n, LIGHT_DIR, 2.0) * LIGHT_COLOR;
    col += calculateSpecular(n, LIGHT_DIR, dir, 20.0) * LIGHT_COLOR * 0.4;
    col *= ao;

    float fog = clamp(min(length(dist)*0.018, dot(p.xz, p.xz)*0.001), 0.0, 1.0);
    col = mix(col, vec3(0.0), fog);

    col = (col - 1.0) * 1.2 + 1.0;
    col = pow(col * 0.8, vec3(1.0 / 2.2));

    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 color = renderMountain(fragCoord, iResolution.xy);
    fragColor = vec4(color, 1.0);
}