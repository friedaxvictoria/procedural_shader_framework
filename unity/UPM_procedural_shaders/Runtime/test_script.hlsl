#ifndef ADDITIONAL_LIGHT_INCLUDED
#define ADDITIONAL_LIGHT_INCLUDED

float rand(float2 co)
{
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float noise(float2 p)
{
    float2 ip = floor(p);
    float2 u = frac(p);
    u = u*u*(3.0-2.0*u);

    float res = lerp(lerp(rand(ip),rand(ip+float2(1.0,0.0)),u.x),
                        lerp(rand(ip+float2(0.0,1.0)),rand(ip+float2(1.0,1.0)),u.x),u.y);
    return res;
}

void perlin_noise_float(float2 uv, float scale, float4 noise_colour, out float4 colour){
    float n = noise(uv*scale);
    colour = float4(n, n, n, 1) * noise_colour;
}

void simple_noise_float(float2 uv, float4 noise_colour, float3 user_input, out float4 colour){
    float noise = frac(sin(dot(uv, user_input.xy)) * user_input.z);
    colour = float4(noise, noise, noise, 1) * noise_colour;
}

void ripple_geometry_float(float2 uv, float3 vertex, float speed, float frequency, float amplitude, out float3 out_vertex){
    float time = _Time.y * speed;
    float displacement = sin(uv.x * frequency + time) * amplitude;
    vertex.y += displacement;
    out_vertex = vertex;
}

void twist_geometry_float(float3 vertex, float twist_strength, out float3 out_vertex){
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


struct SDF {
    int type;
    float3 position;
    float3 size;
    float radius;
};

SDF sdfArray[10];

float sdRoundBox(float3 p, float3 b, float r)
{
  float3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}


float evalSDF(SDF s, float3 p)
{
    if (s.type == 0) {
        return length(p - s.position) - s.radius;
    } else if (s.type == 1) {
        return sdRoundBox(p - s.position, s.size, s.radius);
    }
    return 1e5;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return lerp(b, a, h) - k * h * (1.0 - h);
}


float evaluateScene(float3 p)
{
    float d = 1e5;
    for (int i = 0; i < 10; ++i) {
        d = min(d, evalSDF(sdfArray[i], p));
    }
    return d;
}

// Signed distance to scene (only one object for now)
float map(float3 p)
{
    return evaluateScene(p); // Sphere radius = 1.0
}

// Estimate normal by central differences
float3 getNormal(float3 p)
{
    float h = 0.0001;
    float2 k = float2(1, -1);
    return normalize(
        k.xyy * map(p + k.xyy * h) +
        k.yyx * map(p + k.yyx * h) +
        k.yxy * map(p + k.yxy * h) +
        k.xxx * map(p + k.xxx * h)
    );
}

// Basic lighting
float3 getLighting(float3 p, float3 eye)
{
    float3 lightDir = normalize(float3(0.0, 0.0, 0.3));
    float3 normal = getNormal(p);
    float diff = clamp(dot(normal, lightDir), 0.0, 1.0);
    float3 color = float3(0.4, 0.7, 1.0) * diff;
    return color;
}

// Raymarching function
float raymarch(float3 ro, float3 rd, out float3 hitPos)
{
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        float3 p = ro + rd * t;
        float d = map(p);
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }
    return -1.0; // No hit
}

void SDF_float(out float4 fragColor, in float2 fragCoord, in float2 screenParams)
{
    float2 uv = fragCoord / screenParams.xy * 2.0 - 1.0;
    uv.x *= screenParams.x / screenParams.y;
    
    SDF circle;
    circle.type = 0;
    circle.position = float3(0.0);
    circle.size = float3(0.0);
    circle.radius = 1.0;
    SDF roundBox;
    roundBox.type = 1;
    roundBox.position = float3(1.2, 0.0, 0.0);
    roundBox.size = float3(1.0, 1.0, 1.0);
    roundBox.radius = 0.2;
    SDF roundBox2;
    roundBox.type = 1;
    roundBox.position = float3(-1.7, 0.0, 0.0);
    roundBox.size = float3(1.0, 1.0, 1.0);
    roundBox.radius = 0.2;
    sdfArray[0] = circle;
    sdfArray[1] = roundBox;
    sdfArray[2] = roundBox2;

    float3 ro = float3(0, 0, 3); // Ray origin
    float3 rd = normalize(float3(uv, -1)); // Ray direction

    float3 hitPos;
    float t = raymarch(ro, rd, hitPos);

    float3 color;
    if (t > 0.0) {
        color = getLighting(hitPos, ro);
    } else {
        color = float3(0.0); // Background
    }

    fragColor = float4(color, 1.0);
}



#endif