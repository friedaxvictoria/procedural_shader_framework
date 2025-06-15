#ifndef MODULAR_SHADER_LIB
#define MODULAR_SHADER_LIB


// --- External declarations (defined in main shader) ---
extern sampler2D _MainTex;
extern float4 _MainTex_TexelSize;
extern float4 _Mouse;
extern float _GammaCorrect;
extern float _Resolution;

// --- Constants ---
#define iResolution float3(_Resolution, _Resolution, _Resolution)
#define glsl_mod(x,y) (((x)-(y)*floor((x)/(y))))


float SimpleNoise(float2 p)
{
    return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

float PerlinNoise(float2 p)
{
    return (SimpleNoise(p) + SimpleNoise(p * 2.0) * 0.5 + SimpleNoise(p * 4.0) * 0.25);
}

float3 ApplyPerlinNoise(float3 color, float2 uv, float time)
{
    float n = PerlinNoise(uv * 5.0 + time);
    return color * n;
}

float3 ApplySimpleNoise(float3 color, float2 uv, float time)
{
    float n = SimpleNoise(uv * 10.0 + time);
    return color * n;
}

float3 ApplyPulse(float3 color, float time)
{
    float pulse = abs(sin(time * 2.0));
    return color * pulse;
}

float3 ApplyVerticalStripes(float3 color, float2 uv, float time)
{
    float stripe = step(0.5, frac(uv.y * 10 + time));
    return color * stripe;
}

float3 ApplyHorizontalStripes(float3 color, float2 uv, float time)
{
    float stripe = step(0.5, frac(uv.x * 10 + time));
    return color * stripe;
}

float3 ApplyRippleGeometry(float3 pos, float time, float rippleStrength)
{
    pos.y += sin(pos.x * 10 + time) * rippleStrength;
    return pos;
}

float3 ApplyTwistGeometry(float3 pos, float twistStrength)
{
    float angle = pos.y * twistStrength;
    float c = cos(angle);
    float s = sin(angle);
    float2 xz = float2(c * pos.x - s * pos.z, s * pos.x + c * pos.z);
    pos.x = xz.x;
    pos.z = xz.y;
    return pos;
}

float3 ApplySpinGeometry(float3 pos, float time, float spinSpeed)
{
    float angle = time * spinSpeed;
    float c = cos(angle);
    float s = sin(angle);
    float2 xz = float2(c * pos.x - s * pos.z, s * pos.x + c * pos.z);
    pos.x = xz.x;
    pos.z = xz.y;
    return pos;
}


// WATER SHADER

static float waveTime, globalTimeWrapped, noiseBias = 0., waveStrength = 0., globalAccum = 0.;
static float3 controlPoint, rotatedPos, wavePoint, surfacePos, surfaceNormal, texSamplePos;

struct WaterShaderState
{
    float waveTime;
    float globalTimeWrapped;
    float noiseBias;
    float waveStrength;
    float globalAccum;
    float3 controlPoint;
    float3 rotatedPos;
    float3 wavePoint;
    float3 surfacePos;
    float3 surfaceNormal;
    float3 texSamplePos;
};

float2x2 computeRotationMatrix(float angle)
{
    float c = cos(angle), s = sin(angle);
    return transpose(float2x2(c, s, -s, c));
}

static const float2x2 rotationMatrixSlow = transpose(float2x2(cos(0.023), sin(0.023), -cos(0.023), sin(0.023)));
float hashNoise(float3 p)
{
    float3 f = floor(p), magic = float3(7, 157, 113);
    p -= f;
    float4 h = float4(0, magic.yz, magic.y + magic.z) + dot(f, magic);
    p *= p * (3. - 2. * p);
    h = lerp(frac(sin(h) * 43785.5), frac(sin(h + magic.x) * 43785.5), p.x);
    h.xy = lerp(h.xz, h.yw, p.y);
    return lerp(h.x, h.y, p.z);
}

float computeWave(float3 pos, int iterationCount, float writeOut)
{
    float3 warped = pos - float3(0, 0, globalTimeWrapped * 3.);
    float direction = sin(_Time.y * 0.15);
    float angle = 0.001 * direction;
    float2x2 rotation = computeRotationMatrix(angle);
    float accum = 0., amplitude = 3.;
    for (int i = 0; i < iterationCount; i++)
    {
        accum += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * (amplitude *= 0.51);
        warped.xy = mul(warped.xy, rotation);
        warped *= 1.75;
    }
    if (writeOut > 0.)
    {
        controlPoint = warped;
        waveStrength = accum;
    }
                
    float height = pos.y + accum;
    height *= 0.5;
    height += 0.3 * sin(_Time.y + pos.x * 0.3);
    return height;
}

float2 evaluateDistanceField(float3 pos, float writeOut)
{
    return float2(computeWave(pos, 7, writeOut), 5.);
}

float2 traceWater(float3 rayOrigin, float3 rayDir)
{
    float2 d, hit = ((float2) 0.1);
    for (int i = 0; i < 128; i++)
    {
        d = evaluateDistanceField(rayOrigin + rayDir * hit.x, 1.);
        if (d.x < 0.0001 || hit.x > 43.)
            break;
                        
        hit.x += d.x;
        hit.y = d.y;
    }
    if (hit.x > 43.)
        hit.y = 0.;
                    
    return hit;
}

float3x3 computeCameraBasis(float3 forward, float3 up)
{
    float3 right = normalize(cross(forward, up));
    float3 camUp = cross(right, forward);
    return transpose(float3x3(right, camUp, forward));
}

float4 sampleNoiseTexture(float2 uv, sampler2D tex)
{
    float f = 0.;
    f += tex2D(tex, uv * 0.125).r * 0.5;
    f += tex2D(tex, uv * 0.25).r * 0.25;
    f += tex2D(tex, uv * 0.5).r * 0.125;
    f += tex2D(tex, uv * 1.).r * 0.125;
    f = pow(f, 1.2);
    return ((float4) f * 0.45 + 0.05);
}

#define CAMERA_POSITION float3(0., 2.5, 8.)

// --- Main Water Effect ---
void ApplyWaterEffect(float2 INuv, out float4 frgColor4)
{
    float4 frgColor = 0;
    float2 fragCoord = INuv * _Resolution;
    float2 uv = (fragCoord.xy / iResolution.xy - 0.5) / float2(iResolution.y / iResolution.x, 1.);
    globalTimeWrapped = glsl_mod(_Time.y, 62.83);
    float2 m = all((_Mouse.xy) == (((float2) 0.))) ? ((float2) 0.) : _Mouse.xy / iResolution.xy;
    float yaw = 6.2831 * (m.x - 0.5);
    float pitch = 1.5 * 3.1416 * (m.y - 0.5);
    float cosPitch = cos(pitch);
    float3 viewDir = normalize(float3(sin(yaw) * cosPitch, sin(pitch), cos(yaw) * cosPitch));
    float3 rayOrigin = CAMERA_POSITION;
    float3x3 cameraBasis = computeCameraBasis(viewDir, float3(0, 1, 0));
    float3 rayDir = mul(cameraBasis, normalize(float3(uv, 1.)));
    float3 baseColor = float3(0.05, 0.07, 0.1);
    float3 color = baseColor;
    float2 hit = traceWater(rayOrigin, rayDir);
    if (hit.y > 0.)
    {
        surfacePos = rayOrigin + rayDir * hit.x;
        float3 grad = normalize(float3(computeWave(surfacePos + float3(0.01, 0., 0.), 7, 0.) - computeWave(surfacePos - float3(0.01, 0., 0.), 7, 0.), 0.02, computeWave(surfacePos + float3(0., 0., 0.01), 7, 0.) - computeWave(surfacePos - float3(0., 0., 0.01), 7, 0.)));
        float fresnel = pow(1. - dot(grad, -rayDir), 5.);
        float highlight = clamp(fresnel * 1.5, 0., 1.);
        float texNoiseVal = sampleNoiseTexture(controlPoint.xz * 0.0005, _MainTex).r + sampleNoiseTexture(controlPoint.xz * 0.005, _MainTex).r * 0.5;
        float3 deepColor = float3(0.05, 0.1, 0.2);
        float3 brightColor = float3(0.1, 0.3, 0.9);
        float shading = clamp(waveStrength * 0.1 + texNoiseVal * 0.8, 0., 1.);
        float3 waterColor = lerp(deepColor, brightColor, shading);
        waterColor += ((float3) 1.) * highlight * 0.4;
        float fog = exp(-0.00005 * hit.x * hit.x * hit.x);
        color = lerp(baseColor, waterColor, fog);
    }
                
    frgColor = float4(pow(color + globalAccum * 0.2 * float3(0.7, 0.2, 0.1), ((float3) 0.55)), 1.);
    if (_GammaCorrect)
        frgColor.rgb = pow(frgColor.rgb, 2.2);
    frgColor4 = float4(frgColor.rgb, 1);
}



// Integration Shader

struct SDF
{
    int type;
    float3 position;
    float3 size;
    float radius;
};
static int gHitID;
static SDF sdfArray[10];
float sdSphere(float3 position, float radius)
{
    return length(position) - radius;
}

float sdRoundBox(float3 p, float3 b, float r)
{
    float3 q = abs(p) - b + r;
    return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.) - r;
}

float sdTorus(float3 p, float2 radius)
{
    float2 q = float2(length(p.xy) - radius.x, p.z);
    return length(q) - radius.y;
}

float evalSDF(SDF s, float3 p)
{
    if (s.type == 0)
    {
        return sdSphere(p - s.position, s.radius);
    }
    else if (s.type == 1)
    {
        return sdRoundBox(p - s.position, s.size, s.radius);
    }
    else if (s.type == 2)
        return sdTorus(p - s.position, s.size.yz);
                    
    return 100000.;
}

float evaluateScene(float3 p)
{
    float d = 100000.;
    int bestID = -1;
    for (int i = 0; i < 10; ++i)
    {
        float di = evalSDF(sdfArray[i], p);
        if (di < d)
        {
            d = di;
            bestID = i;
        }
                    
    }
    gHitID = bestID;
    return d;
}

float3 getNormal(float3 p)
{
    float h = 0.0001;
    float2 k = float2(1, -1);
    return normalize(k.xyy * evaluateScene(p + k.xyy * h) + k.yyx * evaluateScene(p + k.yyx * h) + k.yxy * evaluateScene(p + k.yxy * h) + k.xxx * evaluateScene(p + k.xxx * h));
}

float2 GetGradient(float2 intPos, float t)
{
    float rand = frac(sin(dot(intPos, float2(12.9898, 78.233))) * 43758.547);
    float angle = 6.283185 * rand + 4. * t * rand;
    return float2(cos(angle), sin(angle));
}

float Pseudo3dNoise(float3 pos)
{
    float2 i = floor(pos.xy);
    float2 f = frac(pos.xy);
    float2 blend = f * f * (3. - 2. * f);
    float a = dot(GetGradient(i + float2(0, 0), pos.z), f - float2(0., 0.));
    float b = dot(GetGradient(i + float2(1, 0), pos.z), f - float2(1., 0.));
    float c = dot(GetGradient(i + float2(0, 1), pos.z), f - float2(0., 1.));
    float d = dot(GetGradient(i + float2(1, 1), pos.z), f - float2(1., 1.));
    float xMix = lerp(a, b, blend.x);
    float yMix = lerp(c, d, blend.x);
    return lerp(xMix, yMix, blend.y) / 0.7;
}

float fbmPseudo3D(float3 p, int octaves)
{
    float result = 0.;
    float amplitude = 0.5;
    float frequency = 1.;
    for (int i = 0; i < octaves; ++i)
    {
        result += amplitude * Pseudo3dNoise(p * frequency);
        frequency *= 2.;
        amplitude *= 0.5;
    }
    return result;
}

float4 hash44(float4 p)
{
    p = frac(p * float4(0.1031, 0.103, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    return frac((p.xxyz + p.yzzw) * p.zywx);
}

float n31(float3 p)
{
    const float3 S = float3(7., 157., 113.);
    float3 ip = floor(p);
    p = frac(p);
    p = p * p * (3. - 2. * p);
    float4 h = float4(0., S.yz, S.y + S.z) + dot(ip, S);
    h = lerp(hash44(h), hash44(h + S.x), p.x);
    h.xy = lerp(h.xz, h.yw, p.y);
    return lerp(h.x, h.y, p.z);
}

float fbm_n31(float3 p, int octaves)
{
    float value = 0.;
    float amplitude = 0.5;
    for (int i = 0; i < octaves; ++i)
    {
        value += amplitude * n31(p);
        p *= 2.;
        amplitude *= 0.5;
    }
    return value;
}

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
    mat.baseColor = ((float3) 1.);
    mat.specularColor = ((float3) 1.);
    mat.specularStrength = 1.;
    mat.shininess = 32.;
    mat.roughness = 0.5;
    mat.metallic = 0.;
    mat.rimPower = 2.;
    mat.fakeSpecularPower = 32.;
    mat.fakeSpecularColor = ((float3) 1.);
    mat.ior = 1.45;
    mat.refractionStrength = 0.;
    mat.refractionTint = ((float3) 1.);
    return mat;
}

MaterialParams makePlastic(float3 color)
{
    MaterialParams mat = createDefaultMaterialParams();
    mat.baseColor = color;
    mat.metallic = 0.;
    mat.roughness = 0.4;
    mat.specularStrength = 0.5;
    return mat;
}

struct LightingContext
{
    float3 position;
    float3 normal;
    float3 viewDir;
    float3 lightDir;
    float3 lightColor;
    float3 ambient;
};
float3 applyPhongLighting(LightingContext ctx, MaterialParams mat)
{
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.);
    float3 R = reflect(-ctx.lightDir, ctx.normal);
    float spec = pow(max(dot(R, ctx.viewDir), 0.), mat.shininess);
    float3 diffuse = diff * mat.baseColor * ctx.lightColor;
    float3 specular = spec * mat.specularColor * mat.specularStrength;
    return ctx.ambient + diffuse + specular;
}

float raymarch(float3 ro, float3 rd, out float3 hitPos)
{
    hitPos = 0;
    float t = 0.;
    for (int i = 0; i < 100; i++)
    {
        float3 p = ro + rd * t;
        float noise = fbmPseudo3D(p, 1);
        float d = evaluateScene(p) + noise * 0.3;
        if (d < 0.001)
        {
            hitPos = p;
            return t;
        }
                    
        if (t > 50.)
            break;
                        
        t += d;
    }
    return -1.;
}


SDF createSphere(float3 position, float radius)
{
    SDF s;
    s.type = 0; // 0 = Sphere
    s.position = position;
    s.size = float3(0, 0, 0);
    s.radius = radius;
    return s;
}

SDF createRoundedBox(float3 position, float3 size, float radius)
{
    SDF s;
    s.type = 1; // 1 = Rounded Box
    s.position = position;
    s.size = size;
    s.radius = radius;
    return s;
}

SDF createTorus(float3 position, float3 size, float radius)
{
    SDF s;
    s.type = 2; // 2 = Torus
    s.position = position;
    s.size = size;
    s.radius = radius;
    return s;
}

struct ObjectInput
{
    int type; // 0 = sphere, 1 = box, 2 = torus
    float3 position;
    float3 size;
    float radius;
    float3 color;
};

void Integration(float2 INuv, out float4 frgColor3,
float3 torusColor = float3(1., 0.2, 0.2), float torusRadius = 0.2, float3 torusSize = float3(1.0, 5.0, 1.5), float3 torusPosition = float3(0.0, 0.0, 0.0),
float3 cubeColor = float3(0.2, 1., 0.2), float3 cubeSize = float3(1.0, 1.0, 1.0), float3 cubePosition1 = float3(1.9, 0.0, 0.0), float3 cubePosition2 = float3(-1.9, 0.0, 0.0),
float3 sphereColor = float3(0.2, 0.2, 1.), float sphereRadius = 1.0, float3 spherePosition = float3(0.0, 0.0, 0.0),
float3 lightPosition = float3(5.0, 5.0, 5.0)
)
{
    float4 frgColor = 0;
    float2 fragCoord = INuv * _Resolution;
    float2 uv = fragCoord / iResolution.xy * 2. - 1.;
    uv.x *= iResolution.x / iResolution.y;

    uv.x *= iResolution.x / iResolution.y;

    SDF circle;
    circle.type = 0;
    circle.position = spherePosition;
    circle.size = float3(0.0, 0.0, 0.0);
    circle.radius = sphereRadius;

    SDF roundBox;
    roundBox.type = 1;
    roundBox.position = cubePosition1;
    roundBox.size = cubeSize;
    roundBox.radius = 0.2;

    SDF roundBox2;
    roundBox2.type = 1;
    roundBox2.position = cubePosition2;
    roundBox2.size = cubeSize;
    roundBox2.radius = 0.2;

    SDF torus;
    torus.type = 2;
    torus.position = torusPosition;
    torus.size = torusSize;
    torus.radius = torusRadius;

    sdfArray[0] = circle;
    sdfArray[1] = roundBox;
    sdfArray[2] = roundBox2;
    sdfArray[3] = torus;
    float3 ro = float3(0, 0, 7); // Camera position
    float3 rd = normalize(float3(uv, -1)); // Ray direction
    float3 hitPos;
    float t = raymarch(ro, rd, hitPos);
    float3 color;
    if (t > 0.)
    {
        float3 normal = getNormal(hitPos);
        float3 viewDir = normalize(ro - hitPos);
        float3 lightPos = lightPosition;
        float3 lightColor = ((float3) 1.);
        float3 L = normalize(lightPos - hitPos);
        float3 ambientCol = ((float3) 0.1);
        LightingContext ctx;
        ctx.position = hitPos;
        ctx.normal = normal;
        ctx.viewDir = viewDir;
        ctx.lightDir = L;
        ctx.lightColor = lightColor;
        ctx.ambient = ambientCol;
        MaterialParams mat;
        if (gHitID == 0)
        {
            mat = makePlastic(sphereColor);
        }
        else if (gHitID == 1 || gHitID == 2)
        {
            mat = makePlastic(cubeColor);
        }
        else if (gHitID == 3)
        {
            mat = createDefaultMaterialParams();
            mat.baseColor = torusColor;
            mat.shininess = 64.;
        }
        else
        {
            mat = createDefaultMaterialParams();
        }
        color = applyPhongLighting(ctx, mat);
    }
    else
    {
        color = ((float3) 0.);
    }
    frgColor = float4(color, 1.);
    if (_GammaCorrect)
        frgColor.rgb = pow(frgColor.rgb, 2.2);
        
    frgColor3 = frgColor;
}

#ifndef MAX_OBJECTS
#define MAX_OBJECTS 10
#endif

void IntegrationFlexible(float2 INuv, out float4 frgColor3, ObjectInput objInputs[MAX_OBJECTS], int inputCount, float3 lightPosition = float3(5.0, 5.0, 5.0), int combineWater = 0)
{
    float4 frgColor = 0;
    float2 fragCoord = INuv * _Resolution;
    float2 uv = fragCoord / iResolution.xy * 2. - 1.;
    uv.x *= iResolution.x / iResolution.y;

    for (int i = 0; i < inputCount; ++i)
    {
        int t = objInputs[i].type;
        if (t == 0)
            sdfArray[i] = createSphere(objInputs[i].position, objInputs[i].radius);
        else if (t == 1)
            sdfArray[i] = createRoundedBox(objInputs[i].position, objInputs[i].size, objInputs[i].radius);
        else if (t == 2)
            sdfArray[i] = createTorus(objInputs[i].position, objInputs[i].size, objInputs[i].radius);
    }

    float3 ro = float3(0, 0, 7); // Camera origin
    float3 rd = normalize(float3(uv, -1)); // Ray direction
    float3 hitPos;
    float t = raymarch(ro, rd, hitPos);
    float3 color;

    if (t > 0.)
    {
        float3 normal = getNormal(hitPos);
        float3 viewDir = normalize(ro - hitPos);
        float3 lightColor = float3(1., 1., 1.);
        float3 L = normalize(lightPosition - hitPos);
        float3 ambientCol = float3(0.1, 0.1, 0.1);

        LightingContext ctx;
        ctx.position = hitPos;
        ctx.normal = normal;
        ctx.viewDir = viewDir;
        ctx.lightDir = L;
        ctx.lightColor = lightColor;
        ctx.ambient = ambientCol;

        MaterialParams mat;
        if (gHitID >= 0 && gHitID < MAX_OBJECTS)
        {
            mat = makePlastic(objInputs[gHitID].color);
        }
        else
        {
            mat = createDefaultMaterialParams();
        }

        color = applyPhongLighting(ctx, mat);
    }
    else
    {
        if (combineWater == 1)
        {
            ApplyWaterEffect(INuv, frgColor);
            frgColor3 = frgColor;
            return;
        }
        else
        {
            color = float3(0.0, 0.0, 0.0);  
        }
    }

    frgColor = float4(color, 1.0);
    if (_GammaCorrect)
        frgColor.rgb = pow(frgColor.rgb, 2.2);

    frgColor3 = frgColor;
}




#endif
