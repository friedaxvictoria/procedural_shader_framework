// ==========================================
// 3D Noise Function
// Category: Noise
// Description: 3D noise is generated through various techniques and serves as the foundation for numerous applications, 
//              such as volumetric cloud rendering, terrain generation, and procedural texture creation.
// ==========================================

uniform sampler3D texture3DInput;
uniform sampler2D texture2DInput;

// ------------------------------------------
// Input: vec3 x: The position of the point for noise calculation.
//        sampler3D texture3DInput
// Output: A float representing the noise value at the given point, ranging from -1.0 to 1.0.
// Description: Directly sample data from a 3D texture and perform smooth interpolation 
//              to generate noise that satisfies LOD requirements.
// 32.0 matching to the resolution
// ------------------------------------------
float texture3DInterNoise(in vec3 x, sampler3D texture3DInput)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    x = p + f;
    return textureLod(texture3DInput, (x + 0.5) / 32.0, 0.0).x * 2.0 - 1.0;
}

// ------------------------------------------
// Input: vec3 x: The position of the point for noise calculation.
//        sampler2D texture2DInput
// Output: A float representing the noise value at the given point, ranging from -1.0 to 1.0.
// Description: Compute noise at a given point by sampling from a 2D texture.
//              By using the constants 37.0 and 239.0, the influence of the z coordinate 
//              is applied to the x and y directions, creating different texture offsets, 
//              ensuring the mapping of 3D coordinates into the 2D texture space.
// 256.0 matching to the resolution
// ------------------------------------------
float dis3DSampling2DNoise(in vec3 x, sampler2D texture2DInput)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    vec2 uv = (p.xy + vec2(37.0, 239.0) * p.z) + f.xy;
    vec2 rg = textureLod(texture2DInput, (uv + 0.5) / 256.0, 0.0).yx;
    return mix(rg.x, rg.y, f.z) * 2.0 - 1.0;
}

// ------------------------------------------
// Input: vec3 x: The position of the point for noise calculation.
//        sampler3D texture2DInput
// Output: A float representing the noise value at the given point, ranging from -1.0 to 1.0.
// Description: Generates noise by sampling a 2D texture.
//              Fetch texel data from the texture, and performs bilinear interpolation 
//              between the adjacent texels to calculate the noise value at the given point.
// 255 matching to the resolution
// ------------------------------------------
float sample3Dfrom2DNoise(in vec3 x, sampler2D texture2DInput)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    ivec3 q = ivec3(p);
    ivec2 uv = q.xy + ivec2(37, 239) * q.z;
    vec2 rg = mix(mix(texelFetch(texture2DInput, (uv) & 255, 0),
                      texelFetch(texture2DInput, (uv + ivec2(1, 0)) & 255, 0), 
                      f.x),
                  mix(texelFetch(texture2DInput, (uv + ivec2(0, 1)) & 255, 0),
                      texelFetch(texture2DInput, (uv + ivec2(1, 1)) & 255, 0), 
                      f.x), 
                  f.y).yx;
    return mix(rg.x, rg.y, f.z) * 2.0 - 1.0;  
}

// ------------------------------------------
// Input: vec3 p: 3D point for noise calculation
//        int oct: number of octaves (layers of noise detail)
//        Array<float> scales: array of scaling factors for each octave (frequency scaling)
// Output: A float value representing the FBM result at the point p, in the range [-1, 1]
// Description: This 3D FBM is designed to generate time-varying noise by dynamically adjusting the input coordinates over time, creating a visual progression effect.
//              And supports passing scaling factors for each octave, enabling control over the frequency and detail of the generated noise.
//              The noise function can be replaced as needed.
// ------------------------------------------
uniform float scales[8];

float fbm3D(in vec3 p, int oct)
{
    if (oct > 8) return 0.0;

    float q = p - float3(0.0, 0.1, 1.0) * iTime; 
    float g = 0.5 + 0.5 * noise(q * 0.3);
    float f = 0.5 * noise(q);
    float amp = 0.5;

    for(int i = 1; i < oct; i++){
        f += amp * noise(q);
        q *= scales[i-1];
        amp *= 0.5;
    }

    f += amp * noise(q);
    f = mix(f * 0.1 - 0.5, f, g * g);
    return 1.5 * f - 0.5 - p.y;
}
