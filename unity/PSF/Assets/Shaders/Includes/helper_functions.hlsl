#ifndef HELPER_FILE
#define HELPER_FILE

#include "global_variables.hlsl"

#define NO_OF_SEGMENTS 11
#define F_NO_OF_SEGMENTS 11.0

float jumping;
float time;
float segmentIdx = 0.0;
float3 ccd, ccp;

// This function gives you the shortest distance from a 2D point p to a finite line segment between a and b.
float2 lineSegmentDistance(float3 p, float3 start, float3 end)
{
	// Calculate the vector from the start of the line segment to the point
    float3 startToPoint = p - start;
	// Calculate the vector from the start of the line segment to the end
    float3 startToEnd = end - start;
	// Calculate the projection of the point onto the line segment
    float projection = clamp(dot(startToPoint, startToEnd) / dot(startToEnd, startToEnd), 0.0, 1.0);
	// Calculate the closest point on the line segment to the point
    float3 vecToClosestPoint = startToPoint - projection * startToEnd;
	// Calculate the length of the vector to the closest point
    return float2(dot(vecToClosestPoint, vecToClosestPoint), projection);
}

float distanceToBox(float3 p, float3 halfExtent, float radius)
{
	// Calculate the distance from the point to the box
    float3 distanceToBox = abs(p) - halfExtent;
	// Returns: Negative inside the rounded box, Zero on the surface, Positive outside.
    return length(max(distanceToBox, 0.0)) - radius;
}

// Blends two distances smoothly, instead of taking the harsh minimum (min()), which gives a hard union in SDFs.
float smoothUnion(float distance1, float distance2, float smoothFactor)
{
	// h decides how much to interpolate between distance2 and distance1
    float h = clamp(0.5 + 0.5 * (distance2 - distance1) / smoothFactor, 0.0, 1.0);
    return lerp(distance2, distance1, h) - smoothFactor * h * (1.0 - h);
}

// Modified animation function with instance parameters
float2 dolphinAnimation(float position, float time, float timeOffset)
{
    float adjustedTime = time + timeOffset;
    float angle1 = 0.9 * (0.5 + 0.2 * position) * cos(5.0 * position - 3.0 * adjustedTime + 6.2831 / 4.0);
    float angle2 = 1.0 * cos(3.5 * position - 1.0 * adjustedTime + 6.2831 / 4.0);
    float jumping = 0.5 + 0.5 * cos(-0.4 + 0.5 * adjustedTime);
    float finalAngle = lerp(angle1, angle2, jumping);
    float thickness = 0.4 * cos(4.0 * position - 1.0 * adjustedTime) * (1.0 - 0.5 * jumping);
    return float2(finalAngle, thickness);
}

// generates a 3D animation offset vector used to animate some aspect of the dolphin

// Modified movement function with instance parameters
float3 dolphinMovement(float time, float timeOffset, float3 basePosition, float speed, float3 direction)
{
    float adjustedTime = time + timeOffset;
    float jumping = 0.5 + 0.5 * cos(-0.4 + 0.5 * adjustedTime);
    
    float3 movement1 = float3(0.0, sin(3.0 * adjustedTime + 6.2831 / 4.0), 0.0);
    float3 movement2 = float3(0.0, 1.5 + 2.5 * cos(1.0 * adjustedTime), 0.0);
    float3 finalMovement = lerp(movement1, movement2, jumping);
    finalMovement.y *= 0.5;
    finalMovement.x += 0.1 * sin(0.1 - 1.0 * adjustedTime) * (1.0 - jumping);
    
    // Apply linear movement
    float3 worldOffset = float3(0.0, 0.0, fmod(-speed * time, 20.0) - 5.0);
    
    return basePosition + finalMovement + worldOffset;
}

//returning: res.x: The signed distance from point p to the dolphin. res.y: A parameter h that stores a normalized position along the dolphin's body (used for further shaping/decorating).
float2 dolphinDistance(float3 p, float3 position, float timeOffset, float speed, float3 direction, float time)
{

	// Initialize the result to a very large distance and an auxiliary value of 0. We'll minimize this value over the dolphin's body parts.
    float2 result = float2(1000.0, 0.0);
	// Transform Point into Dolphin Local Space
	// Initialize the start point for the dolphin's body
    float3 startPoint = dolphinMovement(time, timeOffset, position, speed, direction);

    float3 position1 = startPoint;
    float3 position2 = startPoint;
    float3 position3 = startPoint;
    float3 direction1 = float3(0.0, 0.0, 0.0);
    float3 direction2 = float3(0.0, 0.0, 0.0);
    float3 direction3 = float3(0.0, 0.0, 0.0);
    float3 closestPoint = startPoint;
	// Iterates through all the dolphin’s spine segments (same concept as in dolphinSignedDistance)
    for (int i = 0; i < NO_OF_SEGMENTS; i++)
    {
		// Compute Normalized Segment Index and Animation
        float segmentPosition = float(i) / F_NO_OF_SEGMENTS;
        float2 segmentAnimation = dolphinAnimation(segmentPosition, time, timeOffset);
		// The length of segments
        float segmentLength = 0.48;
        if (i == 0)
            segmentLength = 0.655;
		// endPoint is the end point of the current segment. The orientation of the segment is controlled by angles (segmentAnimation.x, segmentAnimation.y). This creates a wavy, sinuous body as the dolphin swims.
        float3 endPoint = startPoint + segmentLength * normalize(float3(sin(segmentAnimation.y), sin(segmentAnimation.x), cos(segmentAnimation.x)));
		// Calculate the distance from the point to the line segment defined by startPoint and endPoint
        float2 dist = lineSegmentDistance(p, startPoint, endPoint);

        if (dist.x < result.x)
        {
            result = float2(dist.x, segmentPosition + dist.y / F_NO_OF_SEGMENTS);
            closestPoint = startPoint + dist.y * (endPoint - startPoint);
            ccd = endPoint - startPoint; // This is the direction vector of the segment

        }
		// Store Specific Segment Info for Fins and Tail
        if (i == 3)
        {
            position1 = startPoint;
            direction1 = endPoint - startPoint;
        }
        if (i == 4)
        {
            position3 = startPoint;
            direction3 = endPoint - startPoint;
        }
        if (i == (NO_OF_SEGMENTS - 1))
        {
            position2 = endPoint;
            direction2 = endPoint - startPoint;
        }
		// Move Forward to Next Segment
        startPoint = endPoint;
    }
	   // Save Closest Point (This is the Target Line)
    ccp = closestPoint;
		// It lies in the range [0.0,1.0][0.0,1.0], where 0 is near the head and 1 is at the tail.
    float bodyRadius = result.y;
		// The radius of the dolphin's body at that point. This shapes the body to be thickest near the middle and tapering toward head and tail.
    float radius = 0.05 + bodyRadius * (1.0 - bodyRadius) * (1.0 - bodyRadius) * 2.7;
		//This adds a bump in the radius near the front of the dolphin (around bodyRadius ≈ 0.04), which decays rapidly afterward.
    radius += 7.0 * max(0.0, bodyRadius - 0.04) * exp(-30.0 * max(0.0, bodyRadius - 0.04)) * smoothstep(-0.1, 0.1, p.
    y - closestPoint.y);
		// Reduces radius near the center line (point.y ≈ closestPoint.y) and only in the front part (h < 0.1).
    radius -= 0.03 * (smoothstep(0.0, 0.1, abs(p.
    y - closestPoint.y))) * (1.0 - smoothstep(0.0, 0.1, bodyRadius));
		// Add Thickness Near the Head
    radius += 0.05 * clamp(1.0 - 3.0 * bodyRadius, 0.0, 1.0);
    radius += 0.035 * (1.0 - smoothstep(0.0, 0.025, abs(bodyRadius - 0.1))) * (1.0 - smoothstep(0.0, 0.1, abs(p.
    y - closestPoint.y)));
		// The true signed distance is the distance from point p to the spine (closestPoint) minus the radius at that location. Scaled by 0.75 to compress or adjust the final SDF
    result.x = 0.75 * (distance(p,
    closestPoint)
    - radius);

		// fin part
    direction3 = normalize(direction3);
    float k = sqrt(1.0 - direction3.y * direction3.y);
		// Create a transformation matrix to align the local coordinate system with the dolphin's fin direction
    float3x3 ms = float3x3(
			direction3.z / k, -direction3.x * direction3.y / k, direction3.x,
			0.0, k, direction3.y,
			-direction3.x / k, -direction3.y * direction3.z / k, direction3.z);
		// Transform the point into the local coordinate system of the fin
    float3 ps = mul((p
    - position3), ms);
    ps.z -= 0.1; // This is the offset for the fin
    float distance5 = length(ps.yz) - 0.9;
    distance5 = max(distance5, -(length(ps.yz - float2(0.6, 0.0)) - 0.35));
    distance5 = max(distance5, distanceToBox(ps + float3(0.0, -0.5, 0.5), float3(0.0, 0.5, 0.5), 0.02));
    result.x = smoothUnion(result.x, distance5, 0.1);

		// fin 
    direction1 = normalize(direction1);
    k = sqrt(1.0 - direction1.y * direction1.y);
    ms = float3x3(
			direction1.z / k, -direction1.x * direction1.y / k, direction1.x,
			0.0, k, direction1.y,
			-direction1.x / k, -direction1.y * direction1.z / k, direction1.z);

    ps = p
    - position1;
    ps = mul(ps, ms);
    ps.x = abs(ps.x);
    float l = ps.x;
    l = clamp((l - 0.4) / 0.5, 0.0, 1.0);
    l = 4.0 * l * (1.0 - l);
    l *= 1.0 - clamp(5.0 * abs(ps.z + 0.2), 0.0, 1.0);
    ps.xyz += float3(-0.2, 0.36, -0.2);
    distance5 = length(ps.xz) - 0.8;
    distance5 = max(distance5, -(length(ps.xz - float2(0.2, 0.4)) - 0.8));
    distance5 = max(distance5, distanceToBox(ps + float3(0.0, 0.0, 0.0), float3(1.0, 0.0, 1.0), 0.015 + 0.05 * l));
    result.x = smoothUnion(result.x, distance5, 0.12);

		// tail part
    direction2 = normalize(direction2);
    float2x2 mf = float2x2(
			direction2.z, direction2.y,
			-direction2.y, direction2.z);
    float3 pf = p
    - position2 - direction2 * 0.25;
    pf.yz = mul(pf.yz, mf);
    float distance4 = length(pf.xz) - 0.6;
    distance4 = max(distance4, -(length(pf.xz - float2(0.0, 0.8)) - 0.9));
    distance4 = max(distance4, distanceToBox(pf, float3(1.0, 0.005, 1.0), 0.005));
    result.x = smoothUnion(result.x, distance4, 0.1);
		// Return the signed distance and the auxiliary value
    return result;
}

float3 getDolphinColor(float3 hitPos, float3 normal, float3 lightPosition)
{
    float3 tangentV = normalize(float3(-ccd.z, 0.0, ccd.x));
    float3 bitangentV = normalize(cross(ccd, tangentV));
    float3 position = float3(
            dot(hitPos - ccp, tangentV),
            dot(hitPos - ccp, bitangentV),
            segmentIdx
        );
        
    float3 material;
    material.xyz = lerp(float3(0.3, 0.38, 0.46) * 0.6, float3(0.8, 0.9, 1.0), smoothstep(-0.05, 0.05, position.y - segmentIdx * 0.5 + 0.1)); // Base color of the dolphin
    material.xyz *= smoothstep(0.0, 0.06, distance(float3(abs(position.x), position.yz) * float3(1.0, 1.0, 4.0), float3(0.35, 0.0, 0.4)));
    material.xyz *= 1.0 - 0.75 * (1.0 - smoothstep(0.0, 0.02, abs(position.y))) * (1.0 - smoothstep(0.07, 0.11, segmentIdx));
    material.xyz *= 0.1 * 0.23 * 0.6;
    
    float diff2 = max(0.0, dot(normal, lightPosition));

    float3 BRDF = 20.0 * diff2 * float3(4.00, 2.20, 1.40);
    material *= BRDF;
    return material;
}

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
    float2 q = float2(length(p.xy) - radius.x, p.z);
    return length(q) - radius.y;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Evaluate the signed distance function for a given SDF shape
float evalSDF(int i, float3 p)
{
    int sdfType = _sdfTypeFloat[i];
    float dist = 1e5;
    if (sdfType == 0)
    {
        dist = sdSphere((p - _sdfPositionFloat[i]), _sdfRadiusFloat[i]);
    }
    else if (sdfType == 1)
    {
        dist = sdRoundBox(p - _sdfPositionFloat[i], _sdfSizeFloat[i], _sdfRadiusFloat[i]);
    }
    else if (sdfType == 2)
        dist = sdTorus(p - _sdfPositionFloat[i], _sdfSizeFloat[i].yz);
    else if (sdfType == 3)
        dist = dolphinDistance(p, _sdfPositionFloat[i], _timeOffsetDolphinFloat[i], _speedDolphinFloat[i], _directionDolphinFloat[i], 0.6 + 2.0 * _Time.y - 20.0).x;
    return dist;
}

void lightingContext(float3 hitPos, float3 lightPosition, out float3 viewDir, out float3 lightDir, out float3 lightColor,
out float3 ambientColor)
{
    viewDir = normalize(_rayOrigin - hitPos); // Direction from hit point to camera
    lightDir = normalize(lightPosition - hitPos);
    lightColor = float3(1.0, 1.0, 1.0); // Light color (white)
    ambientColor = float3(0.1, 0.1, 0.1); // Ambient light color<
}

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

float get_noise(float3 p)
{
    if (_NoiseType == 1)
    {
        return fbmPseudo3D(p, 1);
    }
    return 0;
}

float3 get_normal(int i, float3 p)
{
    float h = 0.0001;
    float2 k = float2(1, -1);
    
    float normal1 = evalSDF(i, p + k.xyy * h);
    float normal2 = evalSDF(i, p + k.yyx * h);
    float normal3 = evalSDF(i, p + k.yxy * h);
    float normal4 = evalSDF(i, p + k.xxx * h);
    return normalize(k.xyy * normal1 + k.yyx * normal2 + k.yxy * normal3 + k.xxx * normal4);
}

float3x3 computeCameraMatrix(float3 lookAtPos, float3 eye)
{
    float3 f = normalize(lookAtPos - eye); // Forward direction
    float3 r = normalize(cross(f, float3(0, 1, 0))); // Right direction
    float3 u = cross(r, f); // Recomputed up
    return float3x3(r, u, -f); // Column-major: [right, up, -forward]
}

#endif