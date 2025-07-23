/*
 * Example Shader: Terrain and Castle Integration
 *
 * Author: Xuetong Fu
 *
 * Description:
 *   This example combines procedurally generated heightmap terrain with
 *   modular SDF-based structures (houses and towers) to form a stylized castle scene.
 *   It includes:
 *     - Terrain height computation using blurred texture and FBM
 *     - Parametric SDF modeling for houses and towers with rotation & placement
 *     - Material assignment and lighting using Blinn-Phong, AO, and soft shadows
 */

#define FARCLIP    100.0         // Maximum raymarch distance (scene render depth limit)

#define MARCHSTEPS 1000           // Maximum number of raymarching steps
#define AOSTEPS    20            // Steps for ambient occlusion calculation
#define SHSTEPS    20            // Steps for soft shadow calculation
#define SHPOWER    2.0           // Shadow softness exponent

#define MAT_TERRAIN    0         // Material ID for terrain
#define MAT_BODY       1         // Material ID for building walls
#define MAT_ROOF       2         // Material ID for roofs

int gHitID = -1;                 // ID of the closest hit shape
int gTempHitID = -1;             // Temporary hit ID used during distance checks

struct SDF {
    int   type;
    vec3  position;  
    vec3  size;  
    float radius;
};

SDF sdfArray[3]; // Array to hold SDF shapes

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           SDF module                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Signed distance to a rounded box centered at origin
// p: point position, b: box half-size, r: corner radius
float sdRoundBox(vec3 p, vec3 b, float r) {
    vec3 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

// Signed distance to a triangular prism
// p: point position, b: vec3(baseHalfWidth, height, depth)
float sdTriPrism(vec3 p, vec3 b) {
    vec3 q = vec3(abs(p.x), p.y, abs(p.z));
    float slope = b.y / b.x; // height / half base * 2 → slope = 2h / base
    float tri = max(q.y - b.y + slope * q.x, -q.y);
    float slab = q.z - 0.5 * b.z;

    vec2 d = vec2(tri, slab);
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Signed distance to a pyramid with square base
// p: point position, height: pyramid height
float sdPyramid(vec3 p, float height) {
    vec3 q = abs(p);
    float d = (q.x + q.y + q.z - height) / 3.0;
    return max(-p.y, d);
}

// 2D rotation matrix (counter-clockwise)
// angle: rotation angle in radians
mat2 rot2(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, -s, s,  c);
}

// 3D rotation matrix around arbitrary axis
// axis: rotation axis (normalized), angle: rotation angle in radians
mat3 rot3(vec3 axis, float angle) {
    axis = normalize(axis);
    float c = cos(angle);
    float s = sin(angle);
    float t = 1.0 - c;

    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return mat3(t * x * x + c, t * x * y - s * z, t * x * z + s * y, t * x * y + s * z, t * y * y + c, t * y * z - s * x, t * x * z - s * y, t * y * z + s * x, t * z * z + c);
}

// Computes the distance to a house SDF with body, roof, and window cutouts
vec2 houseDistance(vec3 p) {
    // Main body of the house: rounded box centered at origin
    float bodyDist = sdRoundBox(p, vec3(0.6, 0.4, 0.3), 0.01);
    // Foundation below the house
    float foundationDist = sdRoundBox(
        p + vec3(0.0, 0.1 + 0.4, 0.0),
        vec3(0.6, 0.1, 0.3),
        0.01
    );
    // Front windows (mirrored vertically and tiled)
    vec3 localP = -abs(p);
    localP += vec3(0.09, 0.28, 0.3);
    localP.x = clamp(localP.x, -0.4, 0.55);
    localP.y = clamp(localP.y, 0.0, 0.6);
    localP.x = mod(localP.x, 0.18) - 0.5 * 0.18;
    localP.y = mod(localP.y, 0.3) - 0.5 * 0.3;
    float windowDist = sdRoundBox(localP, vec3(0.035, 0.06, 0.1), 0.01);
    bodyDist = max(bodyDist, -windowDist);

    // Side detail
    localP.x = -abs(p.x);
    localP.xz += vec2(0.6, -0.2);
    windowDist = sdRoundBox(localP, vec3(0.1, 0.06, 0.035), 0.01);
    bodyDist = max(bodyDist, -windowDist);

    // Roof as a triangular prism rotated to align
    localP = rot3(vec3(0.0, 1.0, 0.0), -1.5708) * p;
    localP.y -= 0.43;
    float roofDist = sdTriPrism(localP, vec3(0.4, 0.07, 1.22));
    
    // Blend roof and body
    vec2 house = mix(vec2(bodyDist, MAT_BODY), vec2(roofDist, MAT_ROOF), step(roofDist, bodyDist));

    // Blend with foundation
    house = mix(vec2(foundationDist, MAT_BODY), house, step(house.x, foundationDist));

    // Blend roof and body by nearest surface
    return house;
}

// Computes the distance to a tower with windows and pyramid roof
vec2 towerDistance(vec3 p, float h) {
    // Tower body as a vertical rounded box
    float bodyDist = sdRoundBox(p, vec3(0.25, h, 0.25), 0.02);
    // Foundation below the house
    float foundationDist = sdRoundBox(
        p + vec3(0.0, 0.1 + h, 0.0),
        vec3(0.25, 0.1, 0.25),
        0.02
    );
    // Single window on front face
    vec3 localP = p;
    localP.y -= h * 0.45;
    localP.xy = -abs(localP.xy) + vec2(0.3, 0.17);
    float windowDist = sdRoundBox(localP, vec3(0.1, 0.06, 0.035), 0.01);
    bodyDist = max(bodyDist, -windowDist);

    // Pyramid roof on top of tower
    localP = rot3(vec3(0.0, 1.0, 0.0), 0.785398163) * p;
    localP.y -= h;
    float roofDist = sdPyramid(localP, 0.4);
    
    // Blend roof and body
    vec2 tower = mix(vec2(bodyDist, MAT_BODY), vec2(roofDist, MAT_ROOF), step(roofDist, bodyDist));

    // Blend with foundation
    tower = mix(vec2(foundationDist, MAT_BODY), tower, step(tower.x, foundationDist));

    // Blend roof and body by nearest surface
    return tower;
}

vec2 castleDistance(vec3 p) {
    vec2 castle = vec2(FARCLIP, -1.0);
    vec3 LocalP = p;
    vec2 newDist;

    // House Row 1
    LocalP.z -= 0.8;
    if(LocalP.z > -2.0 && LocalP.z < 2.0) {
        LocalP.xy += vec2(0.7, -0.5);
        LocalP.z = mod(LocalP.z, 2.0) - 1.0;
        castle = houseDistance(LocalP);
    }

    // House Row 2
    LocalP = p;
    LocalP.xz *= rot2(1.8);
    LocalP -= vec3(1.35, 0.5, -0.5);
    newDist = houseDistance(LocalP);
    castle = mix(castle, newDist, step(newDist.x, castle.x));

    // House Row 3
    LocalP = p;
    LocalP.xz *= rot2(1.5);
    LocalP -= vec3(-0.90, 0.5, -0.9);
    newDist = houseDistance(LocalP);
    castle = mix(castle, newDist, step(newDist.x, castle.x));

    // Tower 1
    LocalP = p;
    LocalP.xy -= vec2(0.4, 0.7);
    newDist = towerDistance(LocalP, 0.6);
    castle = mix(castle, newDist, step(newDist.x, castle.x));

    // Tower 2
    LocalP -= vec3(-0.7, 0.6, 0.4);
    newDist = towerDistance(LocalP, 1.2);
    castle = mix(castle, newDist, step(newDist.x, castle.x));

    // Tower 3
    LocalP -= vec3(0.2, -0.4, 0.8);
    newDist = towerDistance(LocalP, 0.8);
    castle = mix(castle, newDist, step(newDist.x, castle.x));

    return castle;
}
// Gaussian-blurred heightmap sample (3x3 kernel)
float getSmoothedHeightMain(vec2 uv, float texelSize) {
    float kernel[3] = float[](0.25, 0.5, 0.25);
    float h = 0.0;

    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            vec2 offset = vec2(float(i), float(j)) * texelSize;
            float texVal = textureLod(iChannel0, uv + offset, 0.0).r;
            h += kernel[i + 1] * kernel[j + 1] * texVal;
        }
    }

    return h;
}

float fbm(vec2 uv) {
      float sum = 0.0, amp = 1.0, freq = 1.0;
      for(int i=0; i<3; ++i) {
          sum += amp * texture(iChannel0, uv * freq).r;
          amp *= 0.5;
          freq *= 2.0;
      }
      return sum;
}

// Full terrain construction
float terrainConstruct(vec3 p) {
    // === Base parameters ===
    float baseHeight      = -4.0;
    float heightScale     = 5.0;
    float texScaleMain    = 0.002;
    float texScaleDetail  = 0.04;
    float texelSize       = 0.002;
    
    // === Primary elevation map (blurred + smoothed heightmap) ===
    vec2 uvMain = p.xz * texScaleMain;
    float heightMain = getSmoothedHeightMain(uvMain, texelSize);
    heightMain = smoothstep(0.1, 0.9, heightMain);
    heightMain *= heightScale;
    
    // === Mid-frequency detail layer (adds localized bumpiness) ===
    vec2 uvDetail = p.xz * texScaleDetail;
    float detailTex = texture(iChannel0, uvDetail).r;
    detailTex = smoothstep(0.3, 0.7, detailTex);
    detailTex *= detailTex;
    
    // === Low-frequency FBM noise (breaks uniform patterns) ===
    float fbmDetail = 0.2 * fbm(p.xz * 0.02);
    
    // === Anti-banding pattern (directional sine bias) ===
    float patternBias = 0.15 * sin(dot(p.xz, vec2(0.08, 0.07)));
    
    // === Combine detail layers ===
    float detailHeight = 0.12 * detailTex + patternBias + fbmDetail;

    // === Optional: Reduce detail in high elevation (currently disabled) ===
    //float fade = 1.0 - smoothstep(0.0, heightScale * 0.6, heightMain);

    // === Final terrain elevation output ===
    float terrainHeight = baseHeight + heightMain + detailHeight;
    return terrainHeight;
}

vec2 terrainDistance(vec3 p) {
    // === Construct terrain ===
    float terrainHeight = terrainConstruct(p); 

    // === Compute vertical distance from terrain surface ===
    float terrainDist = p.y - terrainHeight;

    // Return distance and material ID
    return vec2(terrainDist, MAT_TERRAIN);
}


vec2 castleInstance(vec3 p, vec3 offset, float radius) {
    vec3 offsetP = vec3(offset.x, terrainConstruct(offset), offset.z);
    vec3 localP = p - offsetP;
    localP.xz = rot2(radius) * localP.xz;
    vec2 result = castleDistance(localP);
    return result;
}

// Evaluate the signed distance function for a given SDF shape
float evalSDF(SDF s, vec3 p) {
    vec2 result = vec2(FARCLIP, -1.0);
    if(s.type == 0) {
        result = terrainDistance(p);
        gTempHitID = int(result.y);
        return result.x;
    } else if(s.type == 1) {
        //result = castleDistance(p);
        result = castleInstance(p, s.position, s.radius);
        gTempHitID = int(result.y);
        return result.x;
    }
    return 1e5;
}

// Evaluate the scene by checking all SDF shapes
float evaluateScene(vec3 p) {
    float d = 1e5;
    int bestID = -1;
    for(int i = 0; i < 3; ++i) {
        float di = evalSDF(sdfArray[i], p);
        if(di < d) {
            d = di; // Update the closest distance
            bestID = gTempHitID; // Update the closest hit ID
        }
    }
    gHitID = bestID;  // Store the ID of the closest hit shape
    return d;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

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

MaterialParams getMaterialByID(int id, vec2 uv) {
    MaterialParams mat = createDefaultMaterialParams();

    if(id == int(MAT_TERRAIN)) {
        // === Terrain: blended grass/dirt with warm-to-cool color variation ===
        vec3 warmBase = vec3(1.0, 0.76, 0.55);
        vec3 coolBlend = vec3(0.1, 0.66, 0.25);

        vec3 tex1 = texture(iChannel1, uv * 0.05).rgb;
        tex1 = smoothstep(0.1, 0.9, tex1);
        vec3 col = warmBase * tex1 * 2.0;

        float blend = texture(iChannel0, uv * 0.0125).r * 0.5;
        blend = smoothstep(0.1, 0.9, blend);
        mat.baseColor = mix(col, coolBlend, blend);

        mat.roughness = 0.95;
        mat.specularStrength = 0.0;
        mat.shininess = 0.0;
    } else if(id == int(MAT_BODY)) {
        // === Wall body: pale brick wall with light/dark modulation ===
        vec3 tex1 = texture(iChannel2, uv * 3.0).rgb;
        vec3 tex2 = texture(iChannel2, uv.yx * 3.0).rgb;
        mat.baseColor = 3.75 * tex1 * tex2;

        mat.roughness = 0.3;
        mat.specularStrength = 0.0;
        mat.shininess = 3.0;
        mat.rimPower = 7.5;
    } else if(id == int(MAT_ROOF)) {
        // === Roof: dark clay tile color with strong rim light ===
        mat.baseColor = vec3(0.76, 0.46, 0.35);

        mat.roughness = 0.4;
        mat.specularStrength = 0.0;
        mat.shininess = 1.0;
        mat.rimPower = 10.0;
    } else {
        // === Fallback: debug color for unknown ID ===
        mat.baseColor = vec3(0.15);
        mat.roughness = 1.0;
        mat.specularStrength = 0.0;
    }

    return mat;
}

struct LightingContext {
    vec3 position;    
    vec3 normal; 
    vec3 viewDir;
    vec3 lightDir;
    vec3 lightColor;
    vec3 ambient;
};

LightingContext createLightingContext(
    vec3 position,
    vec3 normal,
    vec3 viewDir,
    vec3 lightDir,
    vec3 lightColor,
    vec3 ambient
) {
    LightingContext ctx;
    ctx.position = position;
    ctx.normal = normal;
    ctx.viewDir = viewDir;
    ctx.lightDir = lightDir;
    ctx.lightColor = lightColor;
    ctx.ambient = ambient;
    return ctx;
}

vec3 applyBlinnPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); // Lambertian diffuse

    vec3 H = normalize(ctx.lightDir + ctx.viewDir);       // Halfway vector
    float spec = pow(max(dot(ctx.normal, H), 0.0), mat.shininess); // Specular term

    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
}

// Computes ambient occlusion by sampling along the normal
// point: surface point, normal: surface normal
float computeAmbientOcclusion(vec3 point, vec3 normal) {
    float occlusion = 0.0;
    float scale = 1.0;
    for (int i = 0; i < AOSTEPS; i++) {
        float offset = 0.01 + 1.2 * pow(float(i) / float(AOSTEPS), 1.5);
        float dist = evaluateScene(point + normal * offset);
        occlusion += -(dist - offset) * scale;
        scale *= 0.65;
        if (occlusion > 1.0) break;
    }
    return clamp(1.0 - occlusion, 0.0, 1.0);
}

// Computes soft shadow factor by raymarching toward light
// rayOrigin: start point, rayDir: light direction
float computeSoftShadow(vec3 rayOrigin, vec3 rayDir, float tStart, float tEnd, float softnessFactor) {
    float shadow = 1.0;
    float t = tStart;
    for (int i = 0; i < SHSTEPS; i++) {
        if (t > tEnd) break;
        float dist = evaluateScene(rayOrigin + rayDir * t);
        shadow = min(shadow, softnessFactor * dist / t);
        t += 0.02 * SHPOWER;
        if (shadow < 0.001) break;
    }
    return clamp(shadow, 0.0, 1.0);
}

// Main lighting function: combines diffuse/specular, AO, shadow, and rim lighting
vec3 applyLighting(LightingContext ctx, MaterialParams mat, bool useAO, bool useShadow) {
    float ao = useAO ? computeAmbientOcclusion(ctx.position, ctx.normal) : 1.0;
    float shadow = useShadow ? computeSoftShadow(ctx.position + ctx.normal * 0.01, ctx.lightDir, 0.01, 2.0, 4.0) : 1.0;

    vec3 result = applyBlinnPhongLighting(ctx, mat);
    result = mix(result, result * ao, 0.5);
    result = mix(result, result * shadow, 0.5);
    return result;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////

// Estimate normal by central differences
vec3 getNormal(vec3 p) {
    float eps = 0.01;
    vec2 e = vec2(1, -1) * 0.5773;
    return normalize(e.xyy * evaluateScene(p + e.xyy * eps) +
        e.yyx * evaluateScene(p + e.yyx * eps) +
        e.yxy * evaluateScene(p + e.yxy * eps) +
        e.xxx * evaluateScene(p + e.xxx * eps));
}
// Raymarching function
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < MARCHSTEPS; i++) {
        vec3 p = ro + rd * t;     
        float noise = 0.0; 
        float d = evaluateScene(p) + noise * 0.3 * 0.0; 
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }
    return -1.0; // No hit
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // === Camera Position ===
    vec3 camPos = vec3(0.0, 2.0, -5.0);

    // === Camera Orientation from Mouse ===
    vec2 m = (iMouse.xy == vec2(0.0)) ? vec2(0.35, 0.45) : iMouse.xy / iResolution.xy;
    float yaw = 6.2831 * (m.x - 0.5);
    float pitch = 1.5 * 3.1416 * (m.y - 0.5);

    // === Construct camera matrix ===
    float cosPitch = cos(pitch);
    vec3 forward = vec3(cosPitch * sin(yaw), sin(pitch), cosPitch * cos(yaw));
    vec3 right = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
    vec3 up = normalize(cross(right, forward));
    mat3 camMat = mat3(right, up, forward);

    // === Compute ray direction for current pixel ===
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec3 rayDir = normalize(camMat * vec3(uv, 1.5));
    // === Light direction setup ===
    vec3 lightDir=normalize(vec3(2.0, 4.0, -15.0));

    // === Scene SDF objects ===
    SDF terrain = SDF(0, vec3(0.0), vec3(0.0), 0.0);
    SDF castle1 = SDF(1, vec3(0.0), vec3(0.0), 0.0);
    SDF castle2 = SDF(1, vec3(3.0, 0.0, 5.0), vec3(0.0), radians(15.0));
    sdfArray[0] = terrain;
    sdfArray[1] = castle1;
    sdfArray[2] = castle2;
    

    // === Raymarch ===
    vec3 hitPos;
    float t = raymarch(camPos, rayDir, hitPos); 

	// === Sky background color (gradient from bottom to top) ===
    vec3 skyBottom = vec3(0.8, 0.9, 1.0);
    vec3 skyTop    = vec3(0.2, 0.5, 0.9);
    vec3 color = mix(skyBottom, skyTop, uv.y); 
    // === Lighting ===
	if( t > 0.0 && gHitID >= 0) {
		vec3 normal=getNormal(hitPos);
        LightingContext ctx = createLightingContext(hitPos, normal, -rayDir, lightDir, vec3(1.0), vec3(0.1));
        MaterialParams mat;
        if (gHitID==MAT_TERRAIN) 
            mat = getMaterialByID(gHitID, hitPos.xz); 
        else if(gHitID==MAT_BODY || gHitID==MAT_ROOF)
            mat = getMaterialByID(gHitID, hitPos.xy);
        color = applyLighting(ctx, mat, true, true);
	}

	fragColor = vec4(color, 1.0 );
}
