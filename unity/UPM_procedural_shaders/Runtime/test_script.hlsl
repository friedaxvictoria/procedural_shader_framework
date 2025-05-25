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

#endif