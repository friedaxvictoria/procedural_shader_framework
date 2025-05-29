// structure for SDF functions
struct SDF {
    int   type;       // 0 for sphere, 1 for round box, 2 for torus
    vec3  position;  // position of the shape in world space
    vec3  size;      // for round box this is the size of the box, for torus this is the major radius and minor radius
    float radius;   // For sphere this is the radius, for round box, this is the corner radius
};

int gHitID;       // ID of the closest hit shape

SDF sdfArray[10]; // Array to hold SDF shapes
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           SDF module                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Signed distance functions for different shapes
float sdSphere( vec3 position, float radius )
{
  return length(position)-radius;
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

// radius.x is the major radius, radius.y is the minor radius
float sdTorus( vec3 p, vec2 radius )
{
    // length(p.xy) - radius.x measures how far this point is from the torus ring center in the XY-plane.
  vec2 q = vec2(length(p.xy)-radius.x,p.z);
  return length(q)-radius.y;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Evaluate the signed distance function for a given SDF shape
float evalSDF(SDF s, vec3 p) {
    if (s.type == 0) {
        return sdSphere((p - s.position), s.radius);
    } else if (s.type == 1) {
        return sdRoundBox(p - s.position, s.size, s.radius);
    }
    else if(s.type == 2)
        return sdTorus(p - s.position, s.size.yz);
    return 1e5;
}
// Evaluate the scene by checking all SDF shapes
float evaluateScene(vec3 p) {
    float d = 1e5;
    int bestID = -1;
    for (int i = 0; i < 10; ++i) {
        float di = evalSDF(sdfArray[i], p);
        if(di < d)
        {
            d = di; // Update the closest distance
            bestID = i; // Update the closest hit ID
        }
    }
    gHitID = bestID;  // Store the ID of the closest hit shape
    return d;
}
// Estimate normal by central differences
vec3 getNormal(vec3 p) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    return normalize(
        k.xyy * evaluateScene(p + k.xyy * h) +
        k.yyx * evaluateScene(p + k.yyx * h) +
        k.yxy * evaluateScene(p + k.yxy * h) +
        k.xxx * evaluateScene(p + k.xxx * h)
    );
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          noise module                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////
vec2 GetGradient(vec2 intPos, float t) {
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return vec2(cos(angle), sin(angle));
}

float Pseudo3dNoise(vec3 pos) {
    vec2 i = floor(pos.xy);
    vec2 f = fract(pos.xy);
    vec2 blend = f * f * (3.0 - 2.0 * f);

    float a = dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0.0, 0.0));
    float b = dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1.0, 0.0));
    float c = dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0.0, 1.0));
    float d = dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1.0, 1.0));

    float xMix = mix(a, b, blend.x);
    float yMix = mix(c, d, blend.x);
    return mix(xMix, yMix, blend.y) / 0.7; // Normalize
}

float fbmPseudo3D(vec3 p, int octaves) {
    float result = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; ++i) {
        result += amplitude * Pseudo3dNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return result;
}

// -----------------------------------------------------------------------------------
vec4 hash44(vec4 p) {
    p = fract(p * vec4(0.1031, 0.1030, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    return fract((p.xxyz + p.yzzw) * p.zywx);
}

float n31(vec3 p) {
    const vec3 S = vec3(7.0, 157.0, 113.0); // step vector: pairwise-prime
    vec3 ip = floor(p);
    p = fract(p);
    p = p * p * (3.0 - 2.0 * p); // Hermite smoother

    vec4 h = vec4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    h = mix(hash44(h), hash44(h + S.x), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

float fbm_n31(vec3 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < octaves; ++i) {
        value += amplitude * n31(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

/////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          material module                                          //
///////////////////////////////////////////////////////////////////////////////////////////////////////
struct MaterialParams {
    vec3 baseColor;          
    vec3 specularColor;       
    float specularStrength;   
    float shininess;          

    float roughness;          
    float metallic;          
    float rimPower;           
    float fakeSpecularPower;  
    vec3 fakeSpecularColor;   

    float ior;               
    float refractionStrength;
    vec3 refractionTint; 
};

MaterialParams createDefaultMaterialParams() {
    MaterialParams mat;
    mat.baseColor = vec3(1.0);
    mat.specularColor = vec3(1.0);
    mat.specularStrength = 1.0;
    mat.shininess = 32.0;

    mat.roughness = 0.5;
    mat.metallic = 0.0;
    mat.rimPower = 2.0;
    mat.fakeSpecularPower = 32.0;
    mat.fakeSpecularColor = vec3(1.0);

    mat.ior = 1.45;                    
    mat.refractionStrength = 0.0;     
    mat.refractionTint = vec3(1.0);
    return mat;
}

MaterialParams makePlastic(vec3 color) {
    MaterialParams mat = createDefaultMaterialParams();
    mat.baseColor = color;
    mat.metallic = 0.0;
    mat.roughness = 0.4;
    mat.specularStrength = 0.5;
    return mat;
}

struct LightingContext {
    vec3 position;    // World-space fragment position
    vec3 normal;      // Normal at the surface point (normalized)
    vec3 viewDir;     // Direction from surface to camera (normalized)
    vec3 lightDir;    // Direction from surface to light (normalized)
    vec3 lightColor;  // RGB intensity of the light source
    vec3 ambient;     // Ambient light contribution
};

vec3 applyPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); // Lambertian diffuse

    vec3 R = reflect(-ctx.lightDir, ctx.normal);          // Reflected light direction
    float spec = pow(max(dot(R, ctx.viewDir), 0.0), mat.shininess); // Phong specular

    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

// Raymarching function
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;     // Current point in the ray
        float noise = fbmPseudo3D(p, 1);    // here you can replace fbmPseudo3D with fbm_n31 for different noise
        float d = evaluateScene(p) + noise*0.3; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }
    return -1.0; // No hit
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
     // replcae fragCoord and iResolution with your engine variables
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;  
    uv.x *= iResolution.x / iResolution.y;
    // Initialize SDF shapes
    SDF circle = SDF(0, vec3(0.0), vec3(0.0), 1.0);
    SDF roundBox = SDF(1, vec3(1.9,0.0,0.0), vec3(1.0,1.0,1.0), 0.2);
    SDF roundBox2 = SDF(1, vec3(-1.9,0.0,0.0), vec3(1.0,1.0,1.0), 0.2);
    SDF torus = SDF(2, vec3(0.0), vec3(1.0,5.0,1.5), 0.2);
    // Add shapes to the array
    sdfArray[0] = circle;
    sdfArray[1] = roundBox;
    sdfArray[2] = roundBox2;
    sdfArray[3] = torus;

    vec3 ro = vec3(0, 0, 7);         // Ray origin
    vec3 rd = normalize(vec3(uv, -1)); // Ray direction

    vec3 hitPos;
    float t = raymarch(ro, rd, hitPos);  // Raymarching to find the closest hit point
    
    vec3 color;
    if (t > 0.0) {
    vec3 normal = getNormal(hitPos);  // Estimate normal at the hit point
    vec3 viewDir = normalize(ro-hitPos); // Direction from hit point to camera
    
    vec3 lightPos   = vec3(5.0, 5.0, 5.0);  // Light position in world space
    vec3 lightColor = vec3(1.0);            // Light color (white)
    vec3 L = normalize(lightPos - hitPos);  // Direction from hit point to light source
        
    vec3 ambientCol = vec3(0.1);     // Ambient light color
    
    // Prepare lighting context
    LightingContext ctx;
    ctx.position   = hitPos;
    ctx.normal     = normal;
    ctx.viewDir    = viewDir;
    ctx.lightDir   = L;
    ctx.lightColor = lightColor;
    ctx.ambient    = ambientCol;
    
    MaterialParams mat; // Material parameters for the hit object
    
    if (gHitID == 0) {  // Sphere
    mat = makePlastic(vec3(0.2,0.2,1.0));       // red sphere
    } else if (gHitID == 1 || gHitID == 2) {  // Round boxes
    mat = makePlastic(vec3(0.2,1.0,0.2));       // green boxes
    } else if (gHitID == 3) {    // Torus
    mat = createDefaultMaterialParams();
    mat.baseColor = vec3(1.0,0.2,0.2);          // blue torus
    mat.shininess = 64.0;
    } else {
    mat = createDefaultMaterialParams();     
    }

        color = applyPhongLighting(ctx, mat); // final color 
    } else {
        color = vec3(0.0); // Background
    }

    fragColor = vec4(color, 1.0);
}
