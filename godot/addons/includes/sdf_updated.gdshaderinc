//========= Updated SDF System with Dolphin =====================

#include "res://addons/includes/helper_functions/helper_func.gdshaderinc"

#include "res://addons/includes/global_variables/global_variables.gdshaderinc"

//=============================
// ORIGINAL SDF FUNCTIONS
//=============================
//===============WATER SHADER======================

// WATER SHADER - Godot GDScript Shader Include
// Compatible with existing uniform structure




mat2 computeRotationMatrix(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat2(vec2(c, -s), vec2(s, c));
}

const mat2 rotationMatrixSlow = mat2(vec2(cos(0.023), -sin(0.023)), vec2(sin(0.023), cos(0.023)));

float hashNoise(vec3 p) {
    vec3 f = floor(p);
    vec3 magic = vec3(7.0, 157.0, 113.0);
    p -= f;
    vec4 h = vec4(0.0, magic.yz, magic.y + magic.z) + dot(f, magic);
    p *= p * (3.0 - 2.0 * p);
    h = mix(fract(sin(h) * 43785.5), fract(sin(h + magic.x) * 43785.5), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

float computeWave(vec3 pos, int iterationCount, float writeOut, float globalTimeWrapped,
                  inout vec3 controlPoint, inout float waveStrength) {
    vec3 warped = pos - vec3(0.0, 0.0, globalTimeWrapped * 3.0);
    float direction = sin(Tme * 0.15);
    float angle = 0.001 * direction;
    mat2 rotation = computeRotationMatrix(angle);
    float accum = 0.0;
    float amplitude = 3.0;

    for (int i = 0; i < iterationCount; i++) {
        accum += abs(sin(hashNoise(warped * 0.15) - 0.5) * 3.14) * amplitude;
        amplitude *= 0.51;
        warped.xy = rotation * warped.xy;
        warped *= 1.75;
    }

    if (writeOut > 0.0) {
        controlPoint = warped;
        waveStrength = accum;
    }

    float height = pos.y + accum;
    //float height = accum - pos.y;
    height *= 0.5;
    height += 0.3 * sin(Tme + pos.x * 0.3);
    return height;
}

vec2 evaluateDistanceField(vec3 pos, float writeOut, float globalTimeWrapped,
                          inout vec3 controlPoint, inout float waveStrength) {
    return vec2(computeWave(pos, 7, writeOut, globalTimeWrapped, controlPoint, waveStrength), 5.0);
}

vec2 traceWater(vec3 rayOrigin, vec3 rayDir, float globalTimeWrapped,
                inout vec3 controlPoint, inout float waveStrength) {
    vec2 d;
    vec2 hit = vec2(0.1);

    for (int i = 0; i < 128; i++) {
        d = evaluateDistanceField(rayOrigin + rayDir * hit.x, 1.0, globalTimeWrapped, controlPoint, waveStrength);
        if (d.x < 0.0001 || hit.x > 43.0) {
            break;
        }
        hit.x += d.x;
        hit.y = d.y;
    }

    if (hit.x > 43.0) {
        hit.y = 0.0;
    }

    return hit;
}



vec4 sampleNoiseTexture(vec2 uv, sampler2D tex) {
    return texture(tex, uv);
}

// More realistic water effect function
void ApplyWaterEffectIntegrated(vec2 INuv, out vec4 frgColor4, vec3 rayOrigin, vec3 rayDir,
                               float globalTimeWrapped, inout vec3 controlPoint, inout float waveStrength) {
    float globalAccum = 0.0;
    vec3 surfacePos = vec3(0.0);

    vec4 frgColor = vec4(0.0);
    vec2 fragCoord = INuv * screen_resolution;
    vec2 uv = fragCoord / screen_resolution.xy * 2. - 1.;
    uv.x *= screen_resolution.x / screen_resolution.y;
    //vec2 uv=INuv;
    // Brighter blue base colors
    vec3 baseColor = vec3(0.2, 0.3, 0.5);  // Much brighter blue base
    vec3 color = baseColor;

    vec2 hit = traceWater(rayOrigin, rayDir, globalTimeWrapped, controlPoint, waveStrength);

    if (hit.y > 0.0) {
        surfacePos = rayOrigin + rayDir * hit.x;

        // For gradient calculation, we need temporary variables
        vec3 tempControlPoint1 = vec3(0.0);
        vec3 tempControlPoint2 = vec3(0.0);
        vec3 tempControlPoint3 = vec3(0.0);
        vec3 tempControlPoint4 = vec3(0.0);
        float tempWaveStrength1 = 0.0;
        float tempWaveStrength2 = 0.0;
        float tempWaveStrength3 = 0.0;
        float tempWaveStrength4 = 0.0;

        // Calculate normal with smaller epsilon for better precision
        vec3 grad = normalize(vec3(
            computeWave(surfacePos + vec3(0.001, 0.0, 0.0), 7, 0.0, globalTimeWrapped, tempControlPoint1, tempWaveStrength1) -
            computeWave(surfacePos - vec3(0.001, 0.0, 0.0), 7, 0.0, globalTimeWrapped, tempControlPoint2, tempWaveStrength2),
            0.002,  // Smaller Y component for more realistic normals
            computeWave(surfacePos + vec3(0.0, 0.0, 0.001), 7, 0.0, globalTimeWrapped, tempControlPoint3, tempWaveStrength3) -
            computeWave(surfacePos - vec3(0.0, 0.0, 0.001), 7, 0.0, globalTimeWrapped, tempControlPoint4, tempWaveStrength4)
        ));

        // More realistic fresnel calculation
        float NdotV = max(0.0, dot(grad, rayDir));
        float fresnel = pow(1.0 - NdotV, 3.0);  // Less extreme fresnel

        // Calculate reflection direction for specular highlights
        vec3 reflection = reflect(rayDir, grad);

        // Assume sun direction (you should pass this as a parameter)
        vec3 sunDirection = normalize(vec3(0.0, 0.0, -0.3));
        float specular = pow(max(0.0, dot(reflection, sunDirection)), 64.0);

        // Bright blue water colors
        vec3 deepWaterColor = vec3(0.15, 0.3, 0.7);       // Bright deep blue
        vec3 shallowWaterColor = vec3(0.3, 0.5, 0.9);     // Very bright blue
        vec3 foamColor = vec3(0.8, 0.9, 1.0);             // Foam/whitecaps

        // Procedural noise for surface detail
        float noise1 = sin(surfacePos.x * 0.1 + globalTimeWrapped * 0.5) * 0.5 + 0.5;
        float noise2 = sin(surfacePos.z * 0.15 + globalTimeWrapped * 0.3) * 0.5 + 0.5;
        float surfaceNoise = (noise1 + noise2) * 0.5;

        // Combine colors based on depth, fresnel, and surface detail
        float depth = hit.x * 0.01;  // Adjust this multiplier based on your scene scale
        float depthFactor = 1.0 - exp(-depth * 0.5);

        // Base water color mixing
        vec3 waterColor = mix(shallowWaterColor, deepWaterColor, depthFactor);

        // Add surface foam based on wave strength and noise
        float foamAmount = smoothstep(0.6, 1.0, waveStrength * 0.1 + surfaceNoise * 0.3);
        waterColor = mix(waterColor, foamColor, foamAmount * 0.1);  // Subtle foam

        // Add fresnel reflection (simulating sky reflection)
        vec3 skyColor = vec3(0.4, 0.7, 1.0);  // Blue sky reflection
        waterColor = mix(waterColor, skyColor, fresnel * 0.5);  // Strong sky reflection

        // Add specular highlights
        waterColor += vec3(0.5) * specular * 0.8;  // Brighter specular highlights

        // Distance fog with more realistic falloff
        float fogDistance = hit.x;
        float fog = exp(-0.00001 * fogDistance * fogDistance);  // Much gentler fog
        fog = clamp(fog, 0.1, 1.0);  // Prevent complete fadeout

        // Final color mixing
        color = mix(baseColor, waterColor, fog);

        // Add subtle color variation based on viewing angle
        float viewAngle = abs(dot(normalize(rayDir), vec3(0.0, 1.0, 0.0)));
        color *= (0.8 + 0.2 * viewAngle);  // Slight brightness variation

        // Keep brightness up - no reduction
        // color *= 0.9;  // Removed brightness reduction
    }

    frgColor4 = vec4(color, 1.0);
}

//================================END====================
float sdSphere(vec3 position, float radius)
{
    return length(position) - radius;
}

float sdRoundBox(vec3 p, vec3 b, float r)
{
    vec3 q = abs(p) - b + r;
    return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.) - r;
}

float sdTorus(vec3 p, vec2 radius)
{
    vec2 q = vec2(length(p.xy) - radius.x, p.z);
    return length(q) - radius.y;
}
float sdHexPrism(vec3 p, vec2 height)
{
    const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0 * min(dot(k.xy, p.xy), 0.0) * k.xy;
    vec2 d = vec2(
       length(p.xy - vec2(clamp(p.x, -k.z * height.x, k.z * height.x), height.x)) * sign(p.y - height.x),
       p.z - height.y);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}
float sdOctahedron(vec3 p, float s)
{
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}

float sdEllipsoid(vec3 p, vec3 r)
{
    float k0 = length(p / r);
    float k1 = length(p / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

//=============================
// IMPROVED DESERT WITH REALISTIC RIPPLES
//=============================

// Uniforms for tweaking in the editor
/* uniform float layer1Amp = 2.0;
uniform float later2Amp = 1.0;
uniform float layer3Amp = 1.0;
 */
 uniform float layer1Amp = 2.0; // Reduce from 2.0
uniform float later2Amp = 1.5; // Reduce from 1.0  
uniform float layer3Amp = 1.5; // Reduce from 1.0
uniform float layer1Freq = 0.2;
uniform float later2Freq = 0.275;
uniform float layer3Freq = 1.5; // Original was 0.5*3.0

uniform vec3 desertColor1 = vec3(1.0, 0.95, 0.7);
uniform vec3 desertColor2 = vec3(0.9, 0.6, 0.4);

// ------ 2D Noise Function ------
float n2D(vec2 p) {
    vec2 i = floor(p); p -= i;
    p *= p * (3.0 - p * 2.0);
    vec4 r = fract(sin(mod(vec4(0, 1, 113, 114) + dot(i, vec2(1, 113)), 6.2831853)) * 43758.5453);
    return dot(mat2(vec2(r.x, r.y), vec2(r.z, r.w)) * vec2(1.0 - p.y, p.y), vec2(1.0 - p.x, p.x));
}
// ------ Dune Shape Functions ------
float surfFunc(in vec3 p) {
    p /= 2.5;
    float layer1 = n2D(p.xz * layer1Freq) * layer1Amp - 0.5;
    layer1 = smoothstep(0.0, 1.05, layer1);
    float layer2 = n2D(p.xz * later2Freq) * later2Amp;
    layer2 = 1.0 - abs(layer2 - 0.5) * 2.0;
    layer2 = smoothstep(0.2, 1.0, layer2 * layer2);
    float layer3 = n2D(p.xz * layer3Freq) * layer3Amp;
    float res = layer1 * 0.7 + layer2 * 0.25 + layer3 * 0.05;
    //return clamp(res, 0.0, 0.5);
    return res;
}

float mapDesert(vec3 p){
    float sf = surfFunc(p);
    return p.y + (1.0-sf)*2.0;  // Keep the negation for proper orientation
}

// ------ Sand Ripple Functions ------
mat2 rot2(in float a) { 
    float c = cos(a), s = sin(a); 
    return mat2(vec2(c, s), vec2(-s, c)); 
}

vec2 hash22(vec2 p) {
    float n = sin(dot(p, vec2(113, 1)));
    p = fract(vec2(2097152, 262144) * n) * 2.0 - 1.0;
    return p;
}
float gradN2D(in vec2 f) {
    const vec2 e = vec2(0, 1);
    vec2 p = floor(f);
    f -= p;
    vec2 w = f * f * (3.0 - 2.0 * f);
    float c = mix(mix(dot(hash22(p + e.xx), f - e.xx), dot(hash22(p + e.yx), f - e.yx), w.x),
                  mix(dot(hash22(p + e.xy), f - e.xy), dot(hash22(p + e.yy), f - e.yy), w.x), w.y);
    return c * 0.5 + 0.5;
}

float grad(float x, float offs) {
    x = abs(fract(x / 6.283 + offs - 0.25) - 0.5) * 2.0;
    float x2 = clamp(x * x * (-1.0 + 2.0 * x), 0.0, 1.0);
    x = smoothstep(0.0, 1.0, x);
    return mix(x, x2, 0.15);
}

float sandL(vec2 p) {
    vec2 q = rot2(3.14159 / 18.0) * p;
    q.y += (gradN2D(q * 18.0) - 0.5) * 0.05;
    float grad1 = grad(q.y * 80.0, 0.0);

    q = rot2(-3.14159 / 20.0) * p;
    q.y += (gradN2D(q * 12.0) - 0.5) * 0.05;
    float grad2 = grad(q.y * 80.0, 0.5);

    q = rot2(3.14159 / 4.0) * p;
    float a2 = dot(sin(q * 12.0 - cos(q.yx * 12.0)), vec2(0.25)) + 0.5;
    float a1 = 1.0 - a2;
    float c = 1.0 - (1.0 - grad1 * a1) * (1.0 - grad2 * a2);
    return c;
}
float sand(vec2 p) {
    p = vec2(p.y - p.x, p.x + p.y) * 0.7071 / 4.0;
    float c1 = sandL(p);
    vec2 q = rot2(3.14159 / 12.0) * p;
    float c2 = sandL(q * 1.25);
    return mix(c1, c2, smoothstep(0.1, 0.9, gradN2D(p * vec2(4))));
}

// NEW: Add the missing bump mapping functions from reference
float bumpSurf3D(in vec3 p) {
    float n = surfFunc(p);
    vec3 px = p + vec3(0.001, 0, 0);
    float nx = surfFunc(px);
    vec3 pz = p + vec3(0, 0, 0.001);
    float nz = surfFunc(pz);
    return sand(p.xz + vec2(n - nx, n - nz) / 0.001 * 1.0);
}

vec3 doBumpMap(in vec3 p, in vec3 nor, float bumpfactor) {
    const vec2 e = vec2(0.001, 0); 
    float ref = bumpSurf3D(p);
    vec3 grad = (vec3(bumpSurf3D(p - e.xyy),
                      bumpSurf3D(p - e.yxy),
                      bumpSurf3D(p - e.yyx)) - ref) / e.x; 
    grad -= nor * dot(nor, grad);          
    return normalize(nor + grad * bumpfactor);
}

// ------ Desert Color Function ------
void getDesertColor(vec3 p, out vec3 color) {
    float ripple = sand(p.xz);
    color = mix(desertColor1, desertColor2, ripple);
}

// IMPROVED: Normal calculation with bump mapping
vec3 getDesertNormal(vec3 p) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    vec3 baseNormal = normalize(k.xyy * mapDesert(p + k.xyy * h) + 
                               k.yyx * mapDesert(p + k.yyx * h) + 
                               k.yxy * mapDesert(p + k.yxy * h) + 
                               k.xxx * mapDesert(p + k.xxx * h));
    
    // Apply bump mapping for realistic ripples
    return doBumpMap(p, baseNormal, 0.1); // Adjust bumpfactor as needed
}
   
// Desert distance field function
vec2 getDesert(vec3 p) {
    float distance = mapDesert(p);
    return vec2(distance, 0.0);
}

// Desert ray marching function
vec2 traceDesert(vec3 rayOrigin, vec3 rayDir) {
    vec2 d;
    vec2 hit = vec2(0.1);
    
    for (int i = 0; i < 128; i++) {
        d = getDesert(rayOrigin + rayDir * hit.x);
        if (d.x < 0.0001 || hit.x > 43.0) {
            break;
        }
        hit.x += d.x;
        hit.y = d.y;
    }
    
    if (hit.x > 43.0) {
        hit.y = 0.0;
    }
    
    return hit;
}

//========================END==================


//=============================
// DOLPHIN SDF FUNCTIONS
//=============================

// This function gives you the shortest distance from a 2D point p to a finite line segment between a and b.
vec2 lineSegmentDistance(vec3 p, vec3 start, vec3 end) {
    vec3 startToPoint = p - start;
    vec3 startToEnd = end - start;
    float projection = clamp(dot(startToPoint, startToEnd) / dot(startToEnd, startToEnd), 0.0, 1.0);
    vec3 vecToClosestPoint = startToPoint - projection * startToEnd;
    return vec2(dot(vecToClosestPoint, vecToClosestPoint), projection);
}

float distanceToBox(vec3 p, vec3 halfExtent, float radius) {
    vec3 distanceToBox = abs(p) - halfExtent;
    return length(max(distanceToBox, 0.0)) - radius;
}

float smoothUnion(float distance1, float distance2, float smoothFactor) {
    float h = clamp(0.5 + 0.5 * (distance2 - distance1) / smoothFactor, 0.0, 1.0);
    return mix(distance2, distance1, h) - smoothFactor * h * (1.0 - h);
}

// Modified animation function with instance parameters
vec2 dolphinAnimation(float position, float time, float timeOffset) {
    float adjustedTime = time + timeOffset;
    float angle1 = 0.9 * (0.5 + 0.2 * position) * cos(5.0 * position - 3.0 * adjustedTime + 6.2831 / 4.0);
    float angle2 = 1.0 * cos(3.5 * position - 1.0 * adjustedTime + 6.2831 / 4.0);
    float jumping = 0.5 + 0.5 * cos(-0.4 + 0.5 * adjustedTime);
    float finalAngle = mix(angle1, angle2, jumping);
    float thickness = 0.4 * cos(4.0 * position - 1.0 * adjustedTime) * (1.0 - 0.5 * jumping);
    return vec2(finalAngle, thickness);
}

// Modified movement function with instance parameters
vec3 dolphinMovement(float time, float timeOffset, vec3 basePosition, float speed, vec3 direction) {
    float adjustedTime = time + timeOffset;
    float jumping = 0.5 + 0.5 * cos(-0.4 + 0.5 * adjustedTime);

    vec3 movement1 = vec3(0.0, sin(3.0 * adjustedTime + 6.2831 / 4.0), 0.0);
    vec3 movement2 = vec3(0.0, 1.5 + 2.5 * cos(1.0 * adjustedTime), 0.0);
    vec3 finalMovement = mix(movement1, movement2, jumping);
    finalMovement.y *= 0.5;
    finalMovement.x += 0.1 * sin(0.1 - 1.0 * adjustedTime) * (1.0 - jumping);

    // Apply linear movement
    vec3 worldOffset = vec3(0.0, 0.0, mod(-speed * time, 20.0) - 5.0);

    return basePosition + finalMovement + worldOffset;
}
//returning: res.x: The signed distance from point p to the dolphin. res.y: A parameter h that stores a normalized position along the dolphin's body (used for further shaping/decorating).
vec2 dolphinDistance(vec3 p, vec3 position, float timeOffset, float speed, vec3 direction, float time, inout vec3 ccd, inout vec3 ccp) {
    vec2 result = vec2(1000.0, 0.0);
    vec3 startPoint = dolphinMovement(time, timeOffset, position, speed, direction);

    vec3 position1 = startPoint;
    vec3 position2 = startPoint;
    vec3 position3 = startPoint;
    vec3 direction1 = vec3(0.0, 0.0, 0.0);
    vec3 direction2 = vec3(0.0, 0.0, 0.0);
    vec3 direction3 = vec3(0.0, 0.0, 0.0);
    vec3 closestPoint = startPoint;

    // Iterate through all the dolphin's spine segments
    for (int i = 0; i < NO_OF_SEGMENTS; i++) {
        float segmentPosition = float(i) / F_NO_OF_SEGMENTS;
        vec2 segmentAnimation = dolphinAnimation(segmentPosition, time, timeOffset);
        float segmentLength = 0.48;
        if (i == 0)
            segmentLength = 0.655;

        vec3 endPoint = startPoint + segmentLength * normalize(vec3(sin(segmentAnimation.y), sin(segmentAnimation.x), cos(segmentAnimation.x)));
        vec2 dist = lineSegmentDistance(p, startPoint, endPoint);

        if (dist.x < result.x) {
            result = vec2(dist.x, segmentPosition + dist.y / F_NO_OF_SEGMENTS);
            closestPoint = startPoint + dist.y * (endPoint - startPoint);
            ccd = endPoint - startPoint;
        }

        // Store specific segment info for fins and tail
        if (i == 3) {
            position1 = startPoint;
            direction1 = endPoint - startPoint;
        }
        if (i == 4) {
            position3 = startPoint;
            direction3 = endPoint - startPoint;
        }
        if (i == (NO_OF_SEGMENTS - 1)) {
            position2 = endPoint;
            direction2 = endPoint - startPoint;
        }
        startPoint = endPoint;
    }

    ccp = closestPoint;
    float bodyRadius = result.y;
    float radius = 0.05 + bodyRadius * (1.0 - bodyRadius) * (1.0 - bodyRadius) * 2.7;
    radius += 7.0 * max(0.0, bodyRadius - 0.04) * exp(-30.0 * max(0.0, bodyRadius - 0.04)) * smoothstep(-0.1, 0.1, p.y - closestPoint.y);
    radius -= 0.03 * (smoothstep(0.0, 0.1, abs(p.y - closestPoint.y))) * (1.0 - smoothstep(0.0, 0.1, bodyRadius));
    radius += 0.05 * clamp(1.0 - 3.0 * bodyRadius, 0.0, 1.0);
    radius += 0.035 * (1.0 - smoothstep(0.0, 0.025, abs(bodyRadius - 0.1))) * (1.0 - smoothstep(0.0, 0.1, abs(p.y - closestPoint.y)));
    result.x = 0.75 * (distance(p, closestPoint) - radius);

    // Fin part
    direction3 = normalize(direction3);
    float k = sqrt(1.0 - direction3.y * direction3.y);
    mat3 ms = mat3(
        vec3(direction3.z / k, 0.0, -direction3.x / k),
        vec3(-direction3.x * direction3.y / k, k, -direction3.y * direction3.z / k),
        vec3(direction3.x, direction3.y, direction3.z)
    );
    vec3 ps = ms * (p - position3);
    ps.z -= 0.1;
    float distance5 = length(ps.yz) - 0.9;
    distance5 = max(distance5, -(length(ps.yz - vec2(0.6, 0.0)) - 0.35));
    distance5 = max(distance5, distanceToBox(ps + vec3(0.0, -0.5, 0.5), vec3(0.0, 0.5, 0.5), 0.02));
    result.x = smoothUnion(result.x, distance5, 0.1);

    // Side fins
    direction1 = normalize(direction1);
    k = sqrt(1.0 - direction1.y * direction1.y);
    ms = mat3(
        vec3(direction1.z / k, 0.0, -direction1.x / k),
        vec3(-direction1.x * direction1.y / k, k, -direction1.y * direction1.z / k),
        vec3(direction1.x, direction1.y, direction1.z)
    );

    ps = p - position1;
    ps = ms * ps;
    ps.x = abs(ps.x);
    float l = ps.x;
    l = clamp((l - 0.4) / 0.5, 0.0, 1.0);
    l = 4.0 * l * (1.0 - l);
    l *= 1.0 - clamp(5.0 * abs(ps.z + 0.2), 0.0, 1.0);
    ps.xyz += vec3(-0.2, 0.36, -0.2);
    distance5 = length(ps.xz) - 0.8;
    distance5 = max(distance5, -(length(ps.xz - vec2(0.2, 0.4)) - 0.8));
    distance5 = max(distance5, distanceToBox(ps + vec3(0.0, 0.0, 0.0), vec3(1.0, 0.0, 1.0), 0.015 + 0.05 * l));
    result.x = smoothUnion(result.x, distance5, 0.12);

    // Tail part
    direction2 = normalize(direction2);
    mat2 mf = mat2(
        vec2(direction2.z, -direction2.y),
        vec2(direction2.y, direction2.z)
    );
    vec3 pf = p - position2 - direction2 * 0.25;
    pf.yz = mf * pf.yz;
    float distance4 = length(pf.xz) - 0.6;
    distance4 = max(distance4, -(length(pf.xz - vec2(0.0, 0.8)) - 0.9));
    distance4 = max(distance4, distanceToBox(pf, vec3(1.0, 0.005, 1.0), 0.005));
    result.x = smoothUnion(result.x, distance4, 0.1);

    return result;
}
// Main dolphin SDF function
float sdDolphin(vec3 p, vec3 position, float timeOffset, float speed, vec3 direction, float time) {
    // We need dummy variables for the full dolphin function
    vec3 dummyCcd = vec3(0.0);
    vec3 dummyCcp = vec3(0.0);

    // Use the full dolphin distance function
    vec2 result = dolphinDistance(p, position, timeOffset, speed, direction, time, dummyCcd, dummyCcp);
    return result.x; // Return just the distance
}



//=============================
// UPDATED EVAL SDF FUNCTION
//=============================

float evalSDF(int type, vec3 position, vec3 size, float radius, vec3 p, int objIndex)
{   
    // Apply pulsing to the object
    vec3 pulsedSize=size;
    float pulsedRadius=radius;
    if(animation_mode==PULSE_ANIMATION){
        pulseObject_float(size, radius, 2.0, 0.3, 1, pulsedSize, pulsedRadius);
    }
    
    if (type == TYPE_SPHERE)
    {
        return sdSphere(p - position, pulsedRadius);
    }
    else if (type == TYPE_ROUNDED_BOX)
    {
        return sdRoundBox(p - position, pulsedSize, pulsedRadius);
    }
    else if (type == TYPE_TORUS)
    {
        return sdTorus(p - position, pulsedSize.yz);
    }
    else if (type == TYPE_DOLPHIN)
    {
        // Get dolphin-specific parameters
        float speed = (objIndex >= 0 && objIndex < MAX_OBJECTS) ? obj_speed[objIndex] : 1.0;
        vec3 direction = (objIndex >= 0 && objIndex < MAX_OBJECTS) ? obj_direction[objIndex] : vec3(0.0, 0.0, 1.0);
        float timeOffset = (objIndex >= 0 && objIndex < MAX_OBJECTS) ? obj_time_offset[objIndex] : 0.0;

        return sdDolphin(p, position, timeOffset, speed, direction, Tme);
    }
    else if(type==TYPE_HEX_PRISM)
    {
        return sdHexPrism(p - position, pulsedSize.xz);
    }
    else if(type==TYPE_OCTAHEDRON)
    {
        return sdOctahedron(p - position, pulsedRadius);

    }
    else if (type==TYPE_ELLIPSOID)
    {
        return sdEllipsoid(p - position, pulsedSize);

    }
    return 100000.;
}

//=============================
// UPDATED SCENE EVALUATION
//=============================

float evaluateScene(vec3 p, out int gHitID)
{
    float d = 100000.;
    int bestID = -1;

    for (int i = 0; i < inputCount; ++i)
    {
        float di = evalSDF(obj_type[i], obj_position[i], obj_size[i], obj_radius[i], p, i);
        if (di < d)
        {
            d = di;
            bestID = i;
        }
    }

    gHitID = bestID;
    return d;
}

//=============================
// LIGHTING FUNCTION
//=============================

void applyPhongLighting_float(vec3 hitPos, int hitID, vec3 cameraPosition, vec3 normal, vec3 baseColor, vec3 specularColor, float specularStrength, float shininess, out vec3 lightingColor)
{
    vec3 viewDir, lightDir, lightColor, ambientColor;
    lightingContext(hitPos, cameraPosition, viewDir, lightDir, lightColor, ambientColor);

    normal = normalize(normal);
    float diff = max(dot(normal, lightDir), 0.15);

    vec3 R = reflect(-lightDir, normal);
    float spec = pow(max(dot(R, viewDir), 0.0), shininess);

    vec3 colour = baseColor;
    vec3 diffuse = diff * colour * lightColor;
    vec3 specular = spec * specularColor * specularStrength;

    vec3 enhancedAmbient = ambientColor * baseColor * 0.4;
    lightingColor = enhancedAmbient + diffuse + specular;
}
void applyDesertPhongLighting_float(vec3 hitPos, int hitID, vec3 cameraPosition, vec3 normal, vec3 baseColor, vec3 specularColor, float specularStrength, float shininess, out vec3 lightingColor){
    vec3 viewDir, lightDir, lightColor, ambientColor;
    desertLightingContext(hitPos, cameraPosition, viewDir, lightDir, lightColor, ambientColor);
    normal = normalize(normal);
    float diff = max(dot(normal, lightDir), 0.3);
    float subsurface = pow(max(0.0, dot(-lightDir, viewDir)), 2.0) * 0.1;
    vec3 R = reflect(-lightDir, normal);
    float spec = pow(max(dot(R, viewDir), 0.0), shininess);
    vec3 colour = baseColor;
    vec3 diffuse = diff * colour * lightColor;
    vec3 specular = spec * specularColor * specularStrength;
    vec3 enhancedAmbient = ambientColor * baseColor * 0.4;
    vec3 subsurfaceContrib = subsurface * colour * lightColor * 0.5;
    lightingColor = enhancedAmbient + diffuse + specular + subsurfaceContrib;
}
//=============================
// NORMAL CALCULATION
//=============================

vec3 getNormal(vec3 p)
{
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    int dummy;
    return normalize(k.xyy * evaluateScene(p + k.xyy * h, dummy) +
                     k.yyx * evaluateScene(p + k.yyx * h, dummy) +
                     k.yxy * evaluateScene(p + k.yxy * h, dummy) +
                     k.xxx * evaluateScene(p + k.xxx * h, dummy));
}

//=============================
// NOISE FUNCTIONS (from original)
//=============================

vec2 GetGradient(vec2 intPos, float t)
{
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.547);
    float angle = 6.283185 * rand + 4. * t * rand;
    return vec2(cos(angle), sin(angle));
}

float Pseudo3dNoise(vec3 pos)
{
    vec2 i = floor(pos.xy);
    vec2 f = fract(pos.xy);
    vec2 blend = f * f * (3. - 2. * f);
    float a = dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0., 0.));
    float b = dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1., 0.));
    float c = dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0., 1.));
    float d = dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1., 1.));
    float xMix = mix(a, b, blend.x);
    float yMix = mix(c, d, blend.x);
    return mix(xMix, yMix, blend.y) / 0.7;
}

float fbmPseudo3D(vec3 p, int octaves)
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
//helper noise function
vec4 hash44(vec4 p)
{
    p = fract(p * vec4(0.1031, 0.1030, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    return fract((p.xxyz + p.yzzw) * p.zywx);
}

float n31(vec3 p)
{
    const vec3 S = vec3(7.0, 157.0, 113.0); // step vector: pairwise-prime
    vec3 ip = floor(p);
    p = fract(p);
    p = p * p * (3.0 - 2.0 * p); // Hermite smoother
    vec4 h = vec4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    h = mix(hash44(h), hash44(h + S.x), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}



//=============================
// RAYMARCHING
//=============================
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos, out int gHitID) {
    gHitID = -1;
    hitPos = vec3(0.0);
    float t = 0.0;

    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;

        // Get base distance and object ID
        float d = evaluateScene(p, gHitID);

        // Apply noise only if we have a valid object ID
        if (gHitID >= 0) {
            int noise_type = obj_noise[gHitID];

            float noise0 = 0.0;
            float noise1 = Pseudo3dNoise(p);
            float noise2 = fbmPseudo3D(p, 1);
            float noise3 = n31(p);

            if (obj_type[gHitID] == TYPE_DOLPHIN) {
                d = d + noise0 * 0.3;
            } else if (noise_type == 1) {
                d = d + noise1 * 0.3;
            } else if (noise_type == 2) {
                d = d + noise2 * 0.3;
            } else if (noise_type == 3) {
                d = d + noise3 * 0.3;
            }
            // Default case (noise_type == 0): no additional noise
        }

        if (d < 0.001) {
            hitPos = p;
            return t;
        }

        if (t > 50.0)
            break;

        t += d;
    }

    return -1.0;
}
//=============================
// MATERIAL SYSTEM (from original)
//=============================

struct MaterialParams
{
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

MaterialParams createDefaultMaterialParams(vec3 color, vec3 specularColor, float specularStrength, float shininess)
{
    MaterialParams mat;
    mat.baseColor = color;
    mat.specularColor = specularColor;
    mat.specularStrength = specularStrength;
    mat.shininess = shininess;
    mat.roughness = 0.5;
    mat.metallic = 0.;
    mat.rimPower = 2.;
    mat.fakeSpecularPower = 32.;
    mat.fakeSpecularColor = vec3(1.0);
    mat.ior = 1.45;
    mat.refractionStrength = 0.;
    mat.refractionTint = vec3(1.0);
    return mat;
}

MaterialParams makePlastic(vec3 color, vec3 specularColor, float specularStrength, float shininess)
{
    MaterialParams mat = createDefaultMaterialParams(color, specularColor, specularStrength, shininess);
    mat.metallic = 0.;
    mat.roughness = 0.4;
    mat.specularStrength = 0.5;
    return mat;
}

//=============================
// MAIN INTEGRATION FUNCTION
//=============================

void IntegrationFlexible(vec2 INuv, out vec4 frgColor3)
{
    vec4 frgColor = vec4(0.0);
    vec2 uv;
    computeUV_float(INuv, uv);
    //=====================Animations================
    mat3 animationMatrix1;
    mat3 animationMatrix2;
    mat3 baseMatrix = mat3(1.0); // Identity matrix for mat2
    float distance;
    vec3 rayOrigin;

    vec3 position_offset1 = vec3(0.0);
    vec3 position_offset2 = vec3(0.0);
    // Get animation matrix and distance based on camera mode
    if (camera_mode1 == MOUSE_CONTROL) {
        move_via_mouse_float(animationMatrix1);
        distance = length(camera_position - look_at_position);

    } else if (camera_mode1 == AUTO_ORBIT) {
        // Automatic orbit in Y axis
        orbitY_float(orbit_axis, orbit_speed, animationMatrix1);
        distance = length(camera_position - look_at_position);

    } else if (camera_mode1 == STATIC_CAMERA) {
        animationMatrix1 = mat3(1.0);
        distance = length(camera_position - look_at_position);

    } else if (camera_mode1 == BACKANDFORTH) {
        backAndForth_scale_float(movement_speed, animationMatrix1);
        distance = length(camera_position - look_at_position);

    } else if (camera_mode1 == SHAKE) {
        shake_matrix_float(shake_intensity, shake_speed, animationMatrix1, position_offset1);
        distance = length(camera_position - look_at_position);
       // ro += position_offset;//checkkk
    } else {
        // Default case
        animationMatrix1 = mat3(1.0);
        distance = length(camera_position - look_at_position);
    }


    if (camera_mode2 == MOUSE_CONTROL) {
        move_via_mouse_float(animationMatrix2);
        distance = length(camera_position - look_at_position);

    } else if (camera_mode2 == AUTO_ORBIT) {
        // Automatic orbit in Y axis

        orbitY_float(orbit_axis, orbit_speed, animationMatrix2);
        distance = length(camera_position - look_at_position);

    } else if (camera_mode2 == STATIC_CAMERA) {
        animationMatrix2 = mat3(1.0);
        distance = length(camera_position - look_at_position);

    } else if (camera_mode2 == BACKANDFORTH) {
        backAndForth_scale_float(movement_speed, animationMatrix2);
        distance = length(camera_position - look_at_position);

    } else if (camera_mode2 == SHAKE) {
        shake_matrix_float(shake_intensity, shake_speed, animationMatrix2, position_offset2);
        distance = length(camera_position - look_at_position);
       // ro += position_offset;//checkkk
    } else {
        // Default case
        animationMatrix2 = mat3(1.0);
        distance = length(camera_position - look_at_position);
    }

    mat3 finalCameraMatrix;
    vec3 target = look_at_position;
    getCameraMatrix_float(animationMatrix1, animationMatrix2, distance, target, finalCameraMatrix, rayOrigin);

    //===============================================
    // Camera setup
    vec3 rd = normalize(finalCameraMatrix * vec3(uv, -1.5));
    vec3 ro=rayOrigin;
    if(position_offset1 != vec3(0.0)){
         ro += position_offset1;
    }else{
        ro +=position_offset2;
    }
    vec3 hitPos;
    int gHitID;
    float t = raymarch(ro, rd, hitPos, gHitID);
    vec3 color;

    //========= Water shader + Desert shader===========
    // Check if terrain modes are enabled
    bool enableWater = (terrain_mode == WATER);
    bool enableDesert = (terrain_mode == DESERT);
    
    bool sdfHitSuccess = t > 0.;

    // Initialize water shader variables
    float globalTimeWrapped = mod(Tme, 62.83);
    vec3 controlPoint = vec3(0.0);
    float waveStrength = 4.0;

    // Water tracing (only if enabled)
    vec2 waterHit = vec2(-1.0, 0.0);
    float waterT = 1000.0;
    bool waterHitSuccess = false;
    
    if (enableWater) {
        waterHit = traceWater(ro, rd, globalTimeWrapped, controlPoint, waveStrength);
        waterT = waterHit.x;
        waterHitSuccess = waterHit.y > 0.;
    }

    // Desert tracing (only if enabled)
    vec2 desertHit = vec2(-1.0, 0.0);
    float desertT = 1000.0;
    bool desertHitSuccess = false;
    
    if (enableDesert) {
        desertHit = traceDesert(ro, rd);
        desertT = desertHit.x;
        desertHitSuccess = desertT < 43.0;  // Check if desert was hit within max distance
    }
    
    // Find the closest surface
    float closestT = 1000.0;
    int closestSurface = 0; // 0 = background, 1 = sdf, 2 = water, 3 = desert
    
    if (sdfHitSuccess && t < closestT) {
        closestT = t;
        closestSurface = 1;
    }
    
    if (waterHitSuccess && waterT < closestT) {
        closestT = waterT;
        closestSurface = 2;
    }
    
    if (desertHitSuccess && desertT < closestT) {
        closestT = desertT;
        closestSurface = 3;
    }
    
    // Render based on closest surface
    if (closestSurface == 1) {
        // SDF object is closest
        vec3 normal = getNormal(hitPos);
        vec3 base_color = obj_color[gHitID];
        vec3 specular_color = specularColorFloat[gHitID];
        float shininess = shininessFloat[gHitID];
        float specular_strength = specularStrengthFloat[gHitID];
        
        if(color_mode==CYCLE_COLOR)
        {
            cycleColor_float(cycle_speed, base_color);
        }
        else if(color_mode==WAVE_COLOR){
            changingColorSin_float(wave_speed,base_color);
        }
        
        MaterialParams mat;
        if (gHitID >= 0 && gHitID < MAX_OBJECTS)
        {
            mat = makePlastic(base_color, specular_color, specular_strength, shininess);
        }
        else
        {
            mat = createDefaultMaterialParams(base_color, specular_color, specular_strength, shininess);
        }
        applyPhongLighting_float(hitPos, gHitID, ro, normal, mat.baseColor, mat.specularColor, mat.specularStrength, mat.shininess, color);
    }
    else if (closestSurface == 2) {
        // Water is closest
        ApplyWaterEffectIntegrated(INuv, frgColor, ro, rd, globalTimeWrapped, controlPoint, waveStrength);
        frgColor3 = frgColor;
        return;
    }
    else if (closestSurface == 3) {
        // Desert is closest
        vec3 desertHitPos = ro + rd * desertT;
        vec3 desertNormal = getDesertNormal(desertHitPos);
        vec3 desertColor;
        getDesertColor(desertHitPos, desertColor);
        
        // Apply Phong lighting to desert
        vec3 desertSpecularColor = vec3(0.3, 0.3, 0.2); // Subtle sandy specular
        float desertSpecularStrength = 0.1; // Low specular for sand
        float desertShininess = 2.0; // Low shininess for rough sand surface
        
        applyDesertPhongLighting_float(desertHitPos, -1, ro, desertNormal, 
                              desertColor, desertSpecularColor, desertSpecularStrength, 
                              desertShininess, color);
    }
    else {
        // Background - render any enabled terrain that wasn't closest
        if (enableWater && waterHitSuccess) {
            ApplyWaterEffectIntegrated(INuv, frgColor, ro, rd, globalTimeWrapped, controlPoint, waveStrength);
            frgColor3 = frgColor;
            return;
        }
        else if (enableDesert && desertHitSuccess) {
            vec3 desertHitPos = ro + rd * desertT;
            vec3 desertNormal = getDesertNormal(desertHitPos);
            vec3 desertColor;
            getDesertColor(desertHitPos, desertColor);
            
            vec3 desertSpecularColor = vec3(0.3, 0.3, 0.2);
            float desertSpecularStrength = 0.1;
            float desertShininess = 2.0;
            
            applyDesertPhongLighting_float(desertHitPos, -1, ro, desertNormal, 
                                   desertColor, desertSpecularColor, desertSpecularStrength, 
                                   desertShininess, color);
        }
        else {
            color = vec3(1.0, 1.0, 1.0);  // Background color
        }
    }
    
    frgColor = vec4(color, 1.0);
    frgColor3 = frgColor;
}