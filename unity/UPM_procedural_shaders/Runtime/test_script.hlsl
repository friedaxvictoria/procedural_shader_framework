#ifndef TEST_SHADER_FILE
#define TEST_SHADER_FILE

float2 _mousePoint;

float rand(float2 co)
{
    return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float noise(float2 p)
{
    float2 ip = floor(p);
    float2 u = frac(p);
    u = u * u * (3.0 - 2.0 * u);

    float res = lerp(lerp(rand(ip), rand(ip + float2(1.0, 0.0)), u.x),
                        lerp(rand(ip + float2(0.0, 1.0)), rand(ip + float2(1.0, 1.0)), u.x), u.y);
    return res;
}

void perlin_noise_float(float2 uv, float scale, float4 noise_colour, out float4 colour)
{
    float n = noise(uv * scale);
    colour = float4(n, n, n, 1) * noise_colour;
}

void simple_noise_float(float2 uv, float4 noise_colour, float3 user_input, out float4 colour)
{
    float noise = frac(sin(dot(uv, user_input.xy)) * user_input.z);
    colour = float4(noise, noise, noise, 1) * noise_colour;
}

void ripple_geometry_float(float2 uv, float3 vertex, float speed, float frequency, float amplitude, out float3 out_vertex)
{
    float time = _Time.y * speed;
    float displacement = sin(uv.x * frequency + time) * amplitude;
    vertex.y += displacement;
    out_vertex = vertex;
}

void twist_geometry_float(float3 vertex, float twist_strength, out float3 out_vertex)
{
    // Scale strength to a reasonable range
    float angle = vertex.y * twist_strength * 3.1415;
    float s = sin(angle);
    float c = cos(angle);

    // Rotate xz
    float x = c * vertex.x - s * vertex.z;
    float z = s * vertex.x + c * vertex.z;

    vertex.x = x;
    vertex.z = z;

    out_vertex = vertex;
}


// ---------- Global State ----------
float2 offsetA, offsetB = float2(0.00035, -0.00035), dummyVec = float2(-1.7, 1.7);
float waveTime, globalTimeWrapped, noiseBias = 0.0, waveStrength = 0.0, globalAccum = 0.0;
float3 controlPoint, rotatedPos, wavePoint, surfacePos, surfaceNormal, texSamplePos;

// ---------- Utilities ----------

/**
 * Computes a 2D rotation matrix.
 */
float2x2 computeRotationMatrix(float angle)
{
    float c = cos(angle), s = sin(angle);
    return float2x2(c, s, -s, c);
}

/**
 * Legacy rotation matrix from original shader (unused).
 */
const float2x2 rotationMatrixSlow = float2x2(cos(0.023), sin(0.023), -cos(0.023), sin(0.023));

/**
 * Hash-based procedural 3D noise.
 * Returns: float in [0,1]
 */
float hashNoise(float3 p)
{
    float3 f = floor(p), magic = float3(7, 157, 113);
    p -= f;
    float4 h = float4(0, magic.yz, magic.y + magic.z) + dot(f, magic);
    p *= p * (3.0 - 2.0 * p);
    h = lerp(frac(sin(h) * 43785.5), frac(sin(h + magic.x) * 43785.5), p.x);
    h.xy = lerp(h.xz, h.yw, p.y);
    return lerp(h.x, h.y, p.z);
}

// ---------- Wave Generation ----------

/**
 * Computes wave height using multi-octave sine-noise accumulation.
 *
 * Inputs:
 *   pos         - vec3 : world-space position
 *   iterationCount - int : number of noise layers
 *   writeOut    - float: whether to export internal wave variables
 *
 * Returns:
 *   float : signed height field
 */
float computeWave(float3 pos, int iterationCount, float writeOut)
{
    float3 warped = pos - float3(0, 0, globalTimeWrapped * 3.0);

    float direction = sin(_Time.y * 0.15);
    float angle = 0.001 * direction;
    float2x2 rotation = computeRotationMatrix(angle);

    float accum = 0.0, amplitude = 3.0;
    for (int i = 0; i < iterationCount; i++)
    {
        accum += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * (amplitude *= 0.51);
        warped.xy = mul(warped.xy, rotation);
        warped *= 1.75;
    }

    if (writeOut > 0.0)
    {
        controlPoint = warped;
        waveStrength = accum;
    }

    float height = pos.y + accum;
    height *= 0.5;
    height += 0.3 * sin(_Time.y + pos.x * 0.3); // slight bobbing

    return height;
}

/**
 * Maps a point to distance field for raymarching.
 */
float2 evaluateDistanceField(float3 pos, float writeOut)
{
    return float2(computeWave(pos, 7, writeOut), 5.0);
}

/**
 * Performs raymarching against the wave surface SDF.
 */
float2 traceWater(float3 rayOrigin, float3 rayDir)
{
    float2 d = float2(0.1, 0.1);
    float2 hit = float2(0.1, 0.1);
    for (int i = 0; i < 128; i++)
    {
        d = evaluateDistanceField(rayOrigin + rayDir * hit.x, 1.0);
        if (d.x < 0.0001 || hit.x > 43.0)
            break;
        hit.x += d.x;
        hit.y = d.y;
    }
    if (hit.x > 43.0)
        hit.y = 0.0;
    return hit;
}

/**
 * Constructs camera basis from forward and up vectors.
 */
float3x3 computeCameraBasis(float3 forward, float3 up)
{
    float3 right = normalize(cross(forward, up));
    float3 camUp = cross(right, forward);
    return float3x3(right, camUp, forward);
}

/**
 * Samples layered noise from texture for detail enhancement.
 */
float4 sampleNoiseTexture(float2 uv, sampler2D tex)
{
    float f = 0.0;
    f += tex2D(tex, uv * 0.125).r * 0.5;
    f += tex2D(tex, uv * 0.25).r * 0.25;
    f += tex2D(tex, uv * 0.5).r * 0.125;
    f += tex2D(tex, uv * 1.0).r * 0.125;
    f = pow(f, 1.2);
    return float4(f * 0.45 + 0.05, f * 0.45 + 0.05, f * 0.45 + 0.05, f * 0.45 + 0.05);
}

// ---------- Main Entry ----------

#define CAMERA_POSITION float3(0.0, 2.5, 8.0)

void water_surface_float(float4 fragCoord, float noise, out float4 fragColor)
{
    //float2 uv = (fragCoord.xy / _ScreenParams.xy - 0.5) / float2(_ScreenParams.y / _ScreenParams.x, 1.0);
    // Calculate centered UV with aspect ratio correction
    float2 uv = (fragCoord.xy - 0.5) / float2(_ScreenParams.y / _ScreenParams.x, 1.0);
    //float2 uv = fragCoord.xy;
    globalTimeWrapped = _Time.y % 62.83;

    // Orbit camera: yaw/pitch from mouse
    float2 m = (_mousePoint.xy == float2(0.0, 0.0)) ? float2(0.0, 0.0) : _mousePoint.xy / _ScreenParams.xy;
    //float2 m = float2(0,0) / _ScreenParams.xy;
    float yaw = 6.2831 * (m.x - 0.5);
    float pitch = 1.5 * 3.1416 * (m.y - 0.5);
    float cosPitch = cos(pitch);

    float3 viewDir = normalize(float3(
        sin(yaw) * cosPitch,
        sin(pitch),
        cos(yaw) * cosPitch
    ));
    

    float3 rayOrigin = CAMERA_POSITION;
    float3x3 cameraBasis = computeCameraBasis(viewDir, float3(0, 1, 0));
    float3 rayDir = mul(normalize(float3(uv, 1.0)), cameraBasis);
       

    // Default background color
    float3 baseColor = float3(0.05, 0.07, 0.1);
    float3 color = baseColor;

    // Raymarching
    float2 hit = traceWater(rayOrigin, rayDir);
    
    if (hit.y > 0.0)
    {
        surfacePos = rayOrigin + rayDir * hit.x;

        // Gradient-based normal estimation
        float3 grad = normalize(float3(
            computeWave(surfacePos + float3(0.01, 0.0, 0.0), 7, 0.0) -
            computeWave(surfacePos - float3(0.01, 0.0, 0.0), 7, 0.0),
            0.02,
            computeWave(surfacePos + float3(0.0, 0.0, 0.01), 7, 0.0) -
            computeWave(surfacePos - float3(0.0, 0.0, 0.01), 7, 0.0)
        ));

        // Fresnel-style highlight
        float fresnel = pow(1.0 - dot(grad, -rayDir), 5.0);
        float highlight = clamp(fresnel * 1.5, 0.0, 1.0);

        // Texture detail sampling
        float texNoiseVal = noise;

        // Water shading: deep vs bright
        float3 deepColor = float3(0.05, 0.1, 0.6);
        float3 brightColor = float3(0.1, 0.3, 0.9);
        float shading = clamp(waveStrength * 0.1 + texNoiseVal * 0.8, 0.0, 1.0);
        float3 waterColor = lerp(deepColor, brightColor, shading);

        // Add highlight
        waterColor += float3(1.0, 1, 1) * highlight * 0.4;

        // Depth-based fog
        float fog = exp(-0.00005 * hit.x * hit.x * hit.x);
        color = lerp(baseColor, waterColor, fog);
    }

    // Gamma correction
    fragColor = float4(pow(color + globalAccum * 0.2 * float3(0.7, 0.2, 0.1), float3(0.55, 0.55, 0.55)), 1.0);

}



#endif