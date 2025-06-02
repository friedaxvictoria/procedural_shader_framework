// structure for SDF functions
struct SDF
{
    int type; // 0 for sphere, 1 for round box, 2 for torus
    float3 position; // position of the shape in world space
    float3 size; // for round box this is the size of the box, for torus this is the major radius and minor radius
    float radius; // For sphere this is the radius, for round box, this is the corner radius
};

int gHitID; // ID of the closest hit shape

//SDF sdfArray[10]; // Array to hold SDF shapes
float _sdfType[10];
float4 _sdfPosition[10];
float4 _sdfSize[10];
float _sdfRadius[10];
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           SDF module                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Signed distance functions for different shapes
float sdSphere(float3 position, float radius)
{
    return length(position) - radius;
}

float sdRoundBox(float3 p, float3 b, float r)
{
    float3 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

// radius.x is the major radius, radius.y is the minor radius
float sdTorus(float3 p, float2 radius)
{
    // length(p.xy) - radius.x measures how far this point is from the torus ring center in the XY-plane.
    float2 q = float2(length(p.xy) - radius.x, p.z);
    return length(q) - radius.y;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Evaluate the signed distance function for a given SDF shape
float evalSDF(float3 sdfPosition, float sdfRadius, float3 sdfSize, int sdfType, float3 p)
{
    if (sdfType == 0)
    {
        return sdSphere((p - sdfPosition), sdfRadius);
    }
    else if (sdfType == 1)
    {
        return sdRoundBox(p - sdfPosition, sdfSize, sdfRadius);
    }
    else if (sdfType == 2)
        return sdTorus(p - sdfPosition, sdfSize.yz);
    return 1e5;
}
// Evaluate the scene by checking all SDF shapes
float evaluateScene(float3 p)
{
    float d = 1e5;
    int bestID = -1;
    for (int i = 0; i < 10; ++i)
    {
        float di = evalSDF(_sdfPosition[i].xyz, _sdfRadius[i], _sdfSize[i].xyz, _sdfType[i], p);
        if (di < d)
        {
            d = di; // Update the closest distance
            bestID = i; // Update the closest hit ID
        }
    }
    gHitID = bestID; // Store the ID of the closest hit shape
    return d;
}
// Estimate normal by central differences
float3 getNormal(float3 p)
{
    float h = 0.0001;
    float2 k = float2(1, -1);
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
float2 GetGradient(float2 intPos, float t)
{
    float rand = frac(sin(dot(intPos, float2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return float2(cos(angle), sin(angle));
}

float Pseudo3dNoise(float3 pos)
{
    float2 i = floor(pos.xy);
    float2 f = frac(pos.xy);
    float2 blend = f * f * (3.0 - 2.0 * f);

    float a = dot(GetGradient(i + float2(0, 0), pos.z), f - float2(0.0, 0.0));
    float b = dot(GetGradient(i + float2(1, 0), pos.z), f - float2(1.0, 0.0));
    float c = dot(GetGradient(i + float2(0, 1), pos.z), f - float2(0.0, 1.0));
    float d = dot(GetGradient(i + float2(1, 1), pos.z), f - float2(1.0, 1.0));

    float xMix = lerp(a, b, blend.x);
    float yMix = lerp(c, d, blend.x);
    return lerp(xMix, yMix, blend.y) / 0.7; // Normalize
}

float fbmPseudo3D(float3 p, int octaves)
{
    float result = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; ++i)
    {
        result += amplitude * Pseudo3dNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return result;
}

// -----------------------------------------------------------------------------------
float4 hash44(float4 p)
{
    p = frac(p * float4(0.1031, 0.1030, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    return frac((p.xxyz + p.yzzw) * p.zywx);
}

float n31(float3 p)
{
    const float3 S = float3(7.0, 157.0, 113.0); // step vector: pairwise-prime
    float3 ip = floor(p);
    p = frac(p);
    p = p * p * (3.0 - 2.0 * p); // Hermite smoother

    float4 h = float4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    h = lerp(hash44(h), hash44(h + S.x), p.x);
    h.xy = lerp(h.xz, h.yw, p.y);
    return lerp(h.x, h.y, p.z);
}

float fbm_n31(float3 p, int octaves)
{
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < octaves; ++i)
    {
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
struct MaterialParams
{
    float3 baseColor;
    float3 specularColor;
    float specularStrength;
    float shininess;

    float roughness;
    float metallic;
    float rimPower;
    float fakeSpecularPower;
    float3 fakeSpecularColor;

    float ior;
    float refractionStrength;
    float3 refractionTint;
};

MaterialParams createDefaultMaterialParams()
{
    MaterialParams mat;
    mat.baseColor = float3(1.0, 1.0, 1.0);
    mat.specularColor = float3(1.0, 1.0, 1.0);
    mat.specularStrength = 1.0;
    mat.shininess = 32.0;

    mat.roughness = 0.5;
    mat.metallic = 0.0;
    mat.rimPower = 2.0;
    mat.fakeSpecularPower = 32.0;
    mat.fakeSpecularColor = float3(1.0, 1.0, 1.0);

    mat.ior = 1.45;
    mat.refractionStrength = 0.0;
    mat.refractionTint = float3(1.0, 1.0, 1.0);
    return mat;
}

MaterialParams makePlastic(float3 color)
{
    MaterialParams mat = createDefaultMaterialParams();
    mat.baseColor = color;
    mat.metallic = 0.0;
    mat.roughness = 0.4;
    mat.specularStrength = 0.5;
    return mat;
}

struct LightingContext
{
    float3 position; // World-space fragment position
    float3 normal; // Normal at the surface point (normalized)
    float3 viewDir; // Direction from surface to camera (normalized)
    float3 lightDir; // Direction from surface to light (normalized)
    float3 lightColor; // RGB intensity of the light source
    float3 ambient; // Ambient light contribution
};

float3 applyPhongLighting(LightingContext ctx, MaterialParams mat)
{
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); // Lambertian diffuse

    float3 R = reflect(-ctx.lightDir, ctx.normal); // Reflected light direction
    float spec = pow(max(dot(R, ctx.viewDir), 0.0), mat.shininess); // Phong specular

    float3 diffuse = diff * mat.baseColor * ctx.lightColor;
    float3 specular = spec * mat.specularColor * mat.specularStrength;
    
    return ctx.ambient + diffuse + specular;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

// Raymarching function
float raymarch(float3 ro, float3 rd, out float3 hitPos)
{
    float t = 0.0;
    for (int i = 0; i < 100; i++)
    {
        float3 p = ro + rd * t; // Current point in the ray
        float noise = fbmPseudo3D(p, 1); // here you can replace fbmPseudo3D with fbm_n31 for different noise
        float d = evaluateScene(p) + noise * 0.3; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001)
        {
            hitPos = p;
            return t;
        }
        if (t > 50.0)
            break;
        t += d;
    }
    return -1.0; // No hit
}


void mainImage_float(float2 fragCoord, out float4 fragColor)
{

    
     // replcae fragCoord and iResolution with your engine variables
    float2 uv = (fragCoord.xy * 2.0 - 1.0) / float2(_ScreenParams.y / _ScreenParams.x, 1.);

        float3 ro = float3(0, 0, 7); // Ray origin
        float3 rd = normalize(float3(uv, -1)); // Ray direction

        float3 hitPos;
        float t = raymarch(ro, rd, hitPos); // Raymarching to find the closest hit point
        
        float3 color;
        if (t > 0.0)
        {
            float3 normal = getNormal(hitPos); // Estimate normal at the hit point
            float3 viewDir = normalize(ro - hitPos); // Direction from hit point to camera
    
            float3 lightPos = float3(5.0, 5.0, 5.0); // Light position in world space
        float3 lightColor = float3(1.0, 1.0, 1.0); // Light color (white)
            float3 L = normalize(lightPos - hitPos); // Direction from hit point to light source
        
        float3 ambientCol = float3(0.1, 0.1, 0.1); // Ambient light color
    
    // Prepare lighting context
            LightingContext ctx;
            ctx.position = hitPos;
            ctx.normal = normal;
            ctx.viewDir = viewDir;
            ctx.lightDir = L;
            ctx.lightColor = lightColor;
            ctx.ambient = ambientCol;
    
            MaterialParams mat; // Material parameters for the hit object
    
            if (gHitID == 0)
            { // Sphere
                mat = makePlastic(float3(0.2, 0.2, 1.0)); // red sphere
            }
            else if (gHitID == 1 || gHitID == 2)
            { // Round boxes
                mat = makePlastic(float3(0.2, 1.0, 0.2)); // green boxes
            }
            else if (gHitID == 3)
            { // Torus
                mat = createDefaultMaterialParams();
                mat.baseColor = float3(1.0, 0.2, 0.2); // blue torus
                mat.shininess = 64.0;
            }
            else
            {
                mat = createDefaultMaterialParams();
            }

            color = applyPhongLighting(ctx, mat); // final color 
        }
        else
        {
            color = float3(0.0, 0.0, 0.0); // Background
        }

        fragColor = float4(color, 1.0);
    }








static float3 ro = float3(0, 0, 7); // Ray origin

void computeUV_float(float2 fragCoord, out float2 uv)
{
    uv = (fragCoord.xy * 2.0 - 1.0) / float2(_ScreenParams.y / _ScreenParams.x, 1.);
}

void fbmPseudo3D_float(float3 p, int octaves, out float noiseValue)
{
    noiseValue = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; ++i)
    {
        noiseValue += amplitude * Pseudo3dNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
}

void evalSDF_float(float3 sdfPosition, float sdfRadius, float3 sdfSize, int sdfType, float3 p, out float sdfValue)
{
    if (sdfType == 0)
    {
        sdfValue = sdSphere((p - sdfPosition), sdfRadius);
    }
    else if (sdfType == 1)
    {
        sdfValue = sdRoundBox(p - sdfPosition, sdfSize, sdfRadius);
    }
    else if (sdfType == 2)
        sdfValue = sdTorus(p - sdfPosition, sdfSize.yz);
    sdfValue = 1e5;
}

void raymarch_float(float2 uv, float noiseType, out float t, out float3 hitPos)
{

    
    float3 rd = normalize(float3(uv, -1)); // Ray direction

    t = 0.0;
    bool hit = false;
    for (int i = 0; i < 100; i++)
    {
        float3 p = ro + rd * t; // Current point in the ray
        float noise = fbmPseudo3D(p, 1); // here you can replace fbmPseudo3D with fbm_n31 for different noise
        float d = 1e5;
        int bestID = -1;
        for (int i = 0; i < 10; ++i)
        {
            float di = evalSDF(_sdfPosition[i].xyz, _sdfRadius[i], _sdfSize[i].xyz, _sdfType[i], p);
            if (di < d)
            {
                d = di; // Update the closest distance
                bestID = i; // Update the closest hit ID
            }
        }
        gHitID = bestID; // Store the ID of the closest hit shape
        d = d + noise * 0.3; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001)
        {
            hitPos = p;
            hit = true;
            break;
        }
        if (t > 50.0)
            break;
        t += d;
    }
    if (!hit)
    {
        t = -1;
    }
}

void applyPhongLighting_float(float3 normal, float3 lightDir, float3 viewDir, float shininess, float3 baseColor, float3 lightColor, float3 specularColor, 
float specularStrength, float3 ambientColor, out float3 lightingColor)
{
    float diff = max(dot(normal, lightDir), 0.0); // Lambertian diffuse

    float3 R = reflect(-lightDir, normal); // Reflected light direction
    float spec = pow(max(dot(R, viewDir), 0.0), shininess); // Phong specular

    float3 diffuse = diff * baseColor * lightColor;
    float3 specular = spec * specularColor * specularStrength;

    lightingColor = ambientColor + diffuse + specular;
}

void lightingContext_float(float3 hitPos, out float3 position, out float3 normal, out float3 viewDir, out float3 lightDir, out float3 lightColor,
out float3 ambientColor)
{
    position = hitPos;
    normal = getNormal(hitPos); // Estimate normal at the hit point
    viewDir = normalize(ro - hitPos); // Direction from hit point to camera
    float3 baseLightDir = float3(5.0, 5.0, 5.0); // Light position in world space
    lightDir = normalize(baseLightDir - hitPos);
    lightColor = float3(1.0, 1.0, 1.0); // Light color (white)
    ambientColor = float3(0.1, 0.1, 0.1); // Ambient light color<
}

void createDefaultMaterialParams_float(out float3 baseColor, out float3 specularColor, out float specularStrength, 
out float shininess, out float roughness, out float metallic, out float rimPower, out float fakeSpecularPower, out float3 fakeSpecularColor,
out float ior, out float refractionStrength, out float3 refractionTint)
{
    baseColor = float3(1.0, 1.0, 1.0);
    specularColor = float3(1.0, 1.0, 1.0);
    specularStrength = 1.0;
    shininess = 32.0;

    roughness = 0.5;
    metallic = 0.0;
    rimPower = 2.0;
    fakeSpecularPower = 32.0;
    fakeSpecularColor = float3(1.0, 1.0, 1.0);

    ior = 1.45;
    refractionStrength = 0.0;
    refractionTint = float3(1.0, 1.0, 1.0);
}

void makePlastic_float(float3 color, out float3 baseColor, out float3 specularColor, out float specularStrength,
out float shininess, out float roughness, out float metallic, out float rimPower, out float fakeSpecularPower, out float3 fakeSpecularColor,
out float ior, out float refractionStrength, out float3 refractionTint)
{
    baseColor = color;
    specularColor = float3(1.0, 1.0, 1.0);
    specularStrength = 1.0;
    shininess = 32.0;

    roughness = 0.4;
    metallic = 0.0;
    rimPower = 2.0;
    fakeSpecularPower = 32.0;
    fakeSpecularColor = float3(1.0, 1.0, 1.0);

    ior = 1.45;
    refractionStrength = 0.5;
    refractionTint = float3(1.0, 1.0, 1.0);
}

void scene_float(float3 colour, float t, out float4 FragCol)
{
    if (t > 0.0)
    {
        FragCol = float4(colour, 1.0);
    }
    else
    {
        FragCol = float4(0.0, 0.0, 0.0, 1.0);
    }

}

void sdfSphere_float(float3 p, float3 centre, float radius, out float sighedDistance)
{
    sighedDistance = length((p - centre)) - radius;
}

void sdfRoundBox_float(float3 p, float3 centre, float3 size, float radius, out float sighedDistance)
{
    float3 p2 = p - centre;
    float3 q = abs(p2) - size + radius;
    sighedDistance = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - radius;
}

void sdfTorus_float(float3 p, float3 centre, float3 size, out float sighedDistance)
{
    float3 p2 = p - centre;
    // length(p.xy) - radius.x measures how far this point is from the torus ring center in the XY-plane.
    float2 q = float2(length(p.xy) - size.x, p2.z);
    sighedDistance = length(q) - size.y;
}
