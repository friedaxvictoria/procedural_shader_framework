// ==========================================
// Module: Compute Occlusion Shader
// Category: Volume Lighting / Occlusion
// Description:
//   Estimates light occlusion through a volume by raymarching from a point along the light direction.
//   This is used to simulate soft shadows.
// ==========================================

// ------------------------------------------------------------
// Cloud Occlusion Function
// Inputs:
//   - vec3: startPos: World-space starting point (typically shading point)
//   - vec3: lightDir: Direction to light source (normalized)
//
// Output:
//   - float: occlusion: Scalar value in [0, 1], where 1 = fully occluded
// ------------------------------------------------------------
float computeCloudOcclusion(vec3 startPos, vec3 lightDir) {
    const float maxDistance = 10.0;  
    const float stepSize = 0.3;  
    const float extinctionScale = 2.0;

    float t = 0.1;                 
    float accumulatedDensity = 0.0;

    for (int i = 0; i < 32; ++i) {
        vec3 samplePos = startPos + t * lightDir;
        float density = map(samplePos, 5); 
        accumulatedDensity += density * stepSize;

        t += stepSize;
        if (t > maxDistance) break;
    }

    float occlusion = 1.0 - exp(-accumulatedDensity * extinctionScale);
    return clamp(occlusion, 0.0, 1.0);
}