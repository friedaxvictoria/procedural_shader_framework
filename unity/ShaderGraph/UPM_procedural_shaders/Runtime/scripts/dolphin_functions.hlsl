#ifndef DOLPHIN_FILE
#define DOLPHIN_FILE

#include "helper_functions.hlsl"
#include "global_variables.hlsl"

/*
#define NO_OF_SEGMENTS 11
#define F_NO_OF_SEGMENTS 11.0




float jumping;
float jumping2;
float time;
float3 dolphinPosition;

float3 ccd, ccp;

const float3 light = float3(0.86, 0.15, 0.48); // Light direction

// This function gives you the shortest distance from a 2D point p to a finite line segment between a and b.
float2 lineSegmentDistance(float3 p, float3 start, float3 end)
{
	// Calculate the vector from the start of the line segment to the point
    float3 startToPoint = p-start;
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



//This function is responsible for computing the position and orientation of different parts of a model
float2 animation(float position, float time)
{
	// position is a float parameter indexing the position along the dolphin's body
	// This generates a cosine wave animation across the dolphin's body.
    float angle1 = 0.9 * (0.5 + 0.2 * position) * cos(5.0 * position - 3.0 * time + 6.2831 / 4.0);
	// A slightly different wave pattern (lower frequency and slower time). Possibly for when the dolphin is in the air (jumping)
    float angle2 = 1.0 * cos(3.5 * position - 1.0 * time + 6.2831 / 4.0);
	// The mix() function is used to blend between the two angles based on the jumping variable.
    float finalAngle = lerp(angle1, angle2, jumping);
	// controls a thickness or radial expansion/contraction, making the body more streamlined when jumping
    float thickness = 0.4 * cos(4.0 * position - 1.0 * time) * (1.0 - 0.5 * jumping);

    return float2(finalAngle, thickness);
}

// generates a 3D animation offset vector used to animate some aspect of the dolphin

float3 animation2()
{
	// Represents vertical bobbing while swimming. This gives the dolphin a rhythmic up-down motion in water.
    float3 movement1 = float3(0.0, sin(3.0 * time + 6.2831 / 4.0), 0.0);
	// Used when the dolphin is jumping. Constant vertical offset (1.5) + dynamic cosine bounce
    float3 movement2 = float3(0.0, 1.5 + 2.5 * cos(1.0 * time), 0.0);
	// Smooth interpolation between a1 and a2
    float3 finalMovement = lerp(movement1, movement2, jumping);
	// This prevents overly exaggerated vertical movement and keeps the dolphin’s motion more natural.
    finalMovement.y *= 0.5;
	// Adds a small x-axis offset (horizontal sway) only when the dolphin is not jumping
    finalMovement.x += 0.1 * sin(0.1 - 1.0 * time) * (1.0 - jumping);

    return finalMovement;
}

float dolphinSignedDistance(float3 p)
{
    // We translate the point to be in local space of the dolphin, so all calculations can be done as if the dolphin is centered at the origin.
	p -= dolphinPosition;
	// Get the Dolphin's Current Animation Offset
	float3 startPoint = animation2();
		// initialize to a very large number
	float x = 100000.0;

	for(int i = 0;i<NO_OF_SEGMENTS; i++){
			// Calculate the position of the dolphin's body segment
		float segmentPosition = float(i) / F_NO_OF_SEGMENTS;
				// Get Animation for this Segment
        float2 segmentAnimation = animation(segmentPosition, time);
				// the length of segments
		float segmentLength = 0.48;
		if( i==0 ) segmentLength=0.655;
				// endPoint is the end point of the current segment. The orientation of the segment is controlled by angles (segmentAnimation.x, segmentAnimation.y). This creates a wavy, sinuous body as the dolphin swims.
        float3 endPoint = startPoint + segmentLength * normalize(float3(sin(segmentAnimation.y), sin(segmentAnimation.x), cos(segmentAnimation.x)));
				// Calculate the distance from the point to the line segment defined by startPoint and endPoint
        float2 dist = lineSegmentDistance(p, startPoint, endPoint);
		float factor = segmentPosition + dist.y / F_NO_OF_SEGMENTS;
				// the radius of the dolphin's body at that point.
		float radius = 0.04 + factor * (1.0 - factor) * (1.0 - factor) * 2.7;
				// Update the Minimum Distance
				x = min(x, sqrt(dist.x) - radius);
				// Update the startPoint for the next segment
				startPoint = endPoint;
	}
	return 0.75*x; // The function returns the signed distance from point to the dolphin body.
}


//returning: res.x: The signed distance from point p to the dolphin. res.y: A parameter h that stores a normalized position along the dolphin's body (used for further shaping/decorating).
float2 dolphinDistance(float3 p)
{
	// Initialize the result to a very large distance and an auxiliary value of 0. We'll minimize this value over the dolphin's body parts.
    float2 result = float2(1000.0, 0.0);
	// Transform Point into Dolphin Local Space
	p -= dolphinPosition;
	// Initialize the start point for the dolphin's body
    float3 startPoint = animation2();

    float3 position1 = startPoint;
    float3 position2 = startPoint;
    float3 position3 = startPoint;
    float3 direction1 = float3(0.0, 0.0, 0.0);
    float3 direction2 = float3(0.0, 0.0, 0.0);
    float3 direction3 = float3(0.0, 0.0, 0.0);
    float3 closestPoint = startPoint;
	// Iterates through all the dolphin’s spine segments (same concept as in dolphinSignedDistance)
	for(int i = 0;i<NO_OF_SEGMENTS; i++){
		// Compute Normalized Segment Index and Animation
        float segmentPosition = float(i) / F_NO_OF_SEGMENTS;
        float2 segmentAnimation = animation(segmentPosition, time);
		// The length of segments
        float segmentLength = 0.48;if( i==0 ) segmentLength=0.655;
		// endPoint is the end point of the current segment. The orientation of the segment is controlled by angles (segmentAnimation.x, segmentAnimation.y). This creates a wavy, sinuous body as the dolphin swims.
        float3 endPoint = startPoint + segmentLength * normalize(float3(sin(segmentAnimation.y), sin(segmentAnimation.x), cos(segmentAnimation.x)));
		// Calculate the distance from the point to the line segment defined by startPoint and endPoint
        float2 dist = lineSegmentDistance(p, startPoint, endPoint);

		if(dist.x < result.x)
		{
            result = float2(dist.x, segmentPosition + dist.y / F_NO_OF_SEGMENTS);
			closestPoint = startPoint + dist.y*(endPoint-startPoint);
			ccd = endPoint - startPoint; // This is the direction vector of the segment

		}
		// Store Specific Segment Info for Fins and Tail
		if(i==3) 
		{
            position1 = startPoint; 
            direction1 = endPoint - startPoint;
        }
		if(i==4)
		{
            position3 = startPoint; 
            direction3 = endPoint - startPoint;
        }
		if(i==(NO_OF_SEGMENTS-1))
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
	radius += 7.0*max(0.0,bodyRadius-0.04)*exp(-30.0*max(0.0,bodyRadius-0.04)) * smoothstep(-0.1, 0.1, p.y-closestPoint.y);
	// Reduces radius near the center line (point.y ≈ closestPoint.y) and only in the front part (h < 0.1).
	radius -= 0.03*(smoothstep(0.0, 0.1, abs(p.y-closestPoint.y)))*(1.0-smoothstep(0.0,0.1,bodyRadius));
	// Add Thickness Near the Head
	radius += 0.05*clamp(1.0-3.0*bodyRadius,0.0,1.0);
	radius += 0.035*(1.0-smoothstep( 0.0, 0.025, abs(bodyRadius-0.1) ))* (1.0-smoothstep(0.0, 0.1, abs(p.y-closestPoint.y)));
	// The true signed distance is the distance from point p to the spine (closestPoint) minus the radius at that location. Scaled by 0.75 to compress or adjust the final SDF
	result.x = 0.75 * (distance(p, closestPoint) - radius);	

	// fin part
	direction3 = normalize(direction3);
    float k = sqrt(1.0 - direction3.y * direction3.y);
	// Create a transformation matrix to align the local coordinate system with the dolphin's fin direction
    float3x3 ms = float3x3(direction3.z / k, 0.0, -direction3.x / k, 
    -direction3.x * direction3.y / k, k, -direction3.y * direction3.z / k, 
    direction3.x, direction3.y, direction3.z);
	// Transform the point into the local coordinate system of the fin
    float3 ps = mul(ms,(p - position3));
	ps.z -= 0.1; // This is the offset for the fin
    float distance5 = length(ps.yz) - 0.9;
    distance5 = max(distance5, -(length(ps.yz - float2(0.6, 0.0)) - 0.35));
    distance5 = max(distance5, distanceToBox(ps + float3(0.0, -0.5, 0.5), float3(0.0, 0.5, 0.5), 0.02));
	result.x = smoothUnion(result.x, distance5, 0.1);

	// fin 
	direction1 = normalize(direction1);
	k = sqrt(1.0 - direction1.y*direction1.y);
    ms = float3x3(direction3.z / k, 0.0, -direction3.x / k,
    -direction3.x * direction3.y / k, k, -direction3.y * direction3.z / k,
    direction3.x, direction3.y, direction3.z);

	ps = p - position1;
    ps = mul(ms, ps);
	ps.x = abs(ps.x);
    float l = ps.x;
	l = clamp((l-0.4)/0.5, 0.0, 1.0);
	l = 4.0 * l * (1.0 - l);
	l *= 1.0-clamp(5.0*abs(ps.z+0.2),0.0,1.0);
    ps.xyz += float3(-0.2, 0.36, -0.2);
	distance5 = length(ps.xz) - 0.8;
    distance5 = max(distance5, -(length(ps.xz - float2(0.2, 0.4)) - 0.8));
    distance5 = max(distance5, distanceToBox(ps + float3(0.0, 0.0, 0.0), float3(1.0, 0.0, 1.0), 0.015 + 0.05 * l));
	result.x = smoothUnion(result.x, distance5, 0.12);

	// tail part
	direction2 = normalize(direction2);
    float2x2 mf = float2x2(direction2.z, -direction2.y, direction2.y, direction2.z);
    float3 pf = p-position2 - direction2 * 0.25;
    pf.yz = mul(mf, pf.yz);
    float distance4 = length(pf.xz) - 0.6;
    distance4 = max(distance4, -(length(pf.xz - float2(0.0, 0.8)) - 0.9));
    distance4 = max(distance4, distanceToBox(pf, float3(1.0, 0.005, 1.0), 0.005));
	result.x = smoothUnion(result.x, distance4, 0.1);
	// Return the signed distance and the auxiliary value
	return result;
}


float2 dolphenIntersection(in float3 ro, in float3 rd, out float3 hitPosition)
{
    const float maxDistance = 10.0; // Prevents infinite loops. Rays going too far are assumed to miss.
    const float minDistance = 0.001; // Determines how close we need to get to say “we’ve hit the surface.”
    float t = 0.0; // Distance along the ray
    float segmentIdx = 0.0; // Index of the segment we are currently checking
    for (int i = 0; i < 128; i++)
    {
        float3 p = ro + t * rd; // Current point along the ray
        float2 result = dolphinDistance(p); // Get the signed distance and auxiliary value
        float dist = result.x; // The signed distance from the point to the dolphin
        segmentIdx = result.y; // Segment index (used for shading, coloring, etc.)
        hitPosition = p;
        if (dist < minDistance || t > maxDistance)
        {
            break; // If we are close enough to the surface or have gone too far, exit the loop
        }
        t += dist; // Move along the ray by the signed distance
    }
    if (t > maxDistance)
    {
        hitPosition = float3(0, 0, 0);
        t = -1.0; // If we went too far, return -1 to indicate no intersection
    }
		
    return float2(t, segmentIdx); // Return the distance along the ray and the segment index
}


float3 dolphinNormal(float3 p)
{
    float3 normal = float3(0.0, 0,0);
	for(int i = 0;i < 4; i++)
	{
	    // For each of the 8 directions, we perturb the point slightly in that direction and compute the signed distance.
        float3 e = 0.5773 * (2.0 * float3((((i + 3) >> 1) & 1), ((i >> 1) & 1), (i & 1)) - 1.0);
		normal += e * dolphinDistance(p + 0.08*e).
x;
	}
	return normalize(normal);
}

float dolphinShadow(float3 ro, float3 rd, float mint, float k)
{
    float result = 1.0; // Initialize the shadow factor to 1 (no shadow)
    float t = mint; // Start from the minimum distance
    float dist;
    for (int i = 0; i < 25; i++)
    {
        dist = dolphinSignedDistance(ro + t * rd); // Get the signed distance at the current point
        result = min(result, k * dist / t); // Update the shadow factor
        t += clamp(dist, 0.05, 0.5); // Move along the ray by the signed distance, ensuring we don't move too little
        if (dist < 0.0001)
            break; // If we are very close to the surface, break out of the loop
    }
    return clamp(result, 0.0, 1.0); // Return the shadow factor, clamped between 0 and 1

}

float3 dolphinColor(float3 pos, float3 nor, float3 rd, float glossy, float glossy2, float shadows, float3 col, float occlusion)
{
    float3 halfWay = normalize(light - rd); // Calculate the halfway vector between the light direction and the ray direction
    float3 reflection = reflect(rd, nor); // Calculate the reflection vector
	
    float sky = clamp(nor.y, 0.0, 1.0);
    float ground = clamp(-nor.y, 0.0, 1.0);
    float diff = max(0.0, dot(nor, light)); // Lambertian diffuse lighting 
    float back = max(0.3 + 0.7 * dot(nor, -float3(light.x, 0.0, light.z)), 0.0); // backlighting

    float shadow = 1.0 - shadows;
    if (shadows * diff > 0.001)
    {
        shadow = dolphinShadow(pos + 0.01 * nor, light, 0.0005, 32.0);
    }

    float fresnel = pow(clamp(1.0 + dot(nor, rd), 0.0, 1.0), 5.0);
    float specular = max(0.0, pow(clamp(dot(halfWay, nor), 0.0, 1.0), 0.01 + glossy));

    float sss = pow(clamp(1.0 + dot(nor, rd), 0.0, 1.0), 2.0);

    float sh = 1.0;
    if (shadows > 0.0)
    {
        sh = dolphinShadow(pos + 0.01 * nor, normalize(reflection + float3(0.0, 1.0, 0.0)), 0.0005, 8.0);
    }

    float3 BRDF = float3(0.0,0,0); // Initialize the BRDF (Bidirectional Reflectance Distribution Function) to zero

    BRDF += 20.0 * diff * float3(4.00, 2.20, 1.40) * float3(sh, sh * 0.5 + 0.5 * sh * sh, sh * sh);
    BRDF += 11.0 * sky * float3(0.20, 0.40, 0.55) * (0.5 + 0.5 * occlusion);
    BRDF += 1.0 * back * float3(0.40, 0.60, 0.70); //*occ;
    BRDF += 11.0 * ground * float3(0.05, 0.30, 0.50);
    BRDF += 5.0 * sss * float3(0.40, 0.40, 0.40) * (0.3 + 0.7 * diff * sh) * glossy * occlusion;
    BRDF += 0.8 * specular * float3(1.30, 1.00, 0.90) * sh * diff * (0.1 + 0.9 * fresnel) * glossy * glossy;
    BRDF += sh * 40.0 * glossy * float3(1.0, 1.0, 1.0) * occlusion * smoothstep(-0.3 + 0.3 * glossy2, 0.2, reflection.y) * (0.5 + 0.5 * smoothstep(-0.2 + 0.2 * glossy2, 1.0, reflection.y)) * (0.04 + 0.96 * fresnel);
    col = col * BRDF;
    col += sh * (0.1 + 1.6 * fresnel) * occlusion * glossy2 * glossy2 * 40.0 * float3(1.0, 0.9, 0.8) * smoothstep(0.0, 0.2, reflection.y) * (0.5 + 0.5 * smoothstep(0.0, 1.0, reflection.y)); //*smoothstep(-0.1,0.0,dif);
    col += 1.2 * glossy * pow(specular, 4.0) * float3(1.4, 1.1, 0.9) * sh * diff * (0.04 + 0.96 * fresnel) * occlusion;
	
    return col;

}

void mainImage_float(float2 uv, float3 rayDirection, out float4 fragColor, out float3 hitPosition)
{
    float2 p = -1.0 + 2.0 * uv;

	// animation
    time = 0.6 + 2.0 * _Time.y - 20.0;
    dolphinPosition = float3(0.0, 0.0 - 0.2, -1.1 * time);
    jumping = 0.5 + 0.5 * cos(-0.4 + 0.5 * time);
    jumping2 = 0.5 + 0.5 * cos(0.6 + 0.5 * time);
    float jumping3 = 0.5 + 0.5 * cos(-1.4 + 0.5 * time);

	// render 
    float t = 1000.0; // Initialize the distance to a large value
    float3 col = float3(0.0,0,0); // Initialize color to black
	// skips tracing the empty upper sky and starts raymarching closer to where the dolphin geometry actually is.
    float pt = (3.2 - _rayOrigin.y) / rayDirection.y;
    if (rayDirection.y < 0.0 && pt > 0.0)
        _rayOrigin = _rayOrigin + rayDirection * pt;

    float2 intersect = dolphenIntersection(_rayOrigin, rayDirection, hitPosition);
    if (intersect.x > 0.0)
    {
        t = intersect.x; // If we hit the dolphin, get the distance
        float3 pos = _rayOrigin + t * rayDirection; // Calculate the position of the intersection
        float3 nor = dolphinNormal(pos); // Calculate the normal at the intersection point
        float3 reflection = reflect(rayDirection, nor); // Calculate the reflection vector
        float3 localPos = pos - dolphinPosition; // Local position relative to the dolphin

        float3 tangetV = normalize(float3(-ccd.z, 0.0, ccd.x)); // Tangent vector along the dolphin's body
        float3 bitangentV = normalize(cross(ccd, tangetV)); // Bitangent vector (perpendicular to both tangent and ccd)
        float3 position = float3(dot(localPos - ccp, tangetV), dot(localPos - ccp, bitangentV), intersect.y);
        float2 uv = float2(1.0 * atan(position.x/ position.y) / 3.1416, 4.0 * position.z);

        float4 material;
        material.xyz = lerp(float3(0.3, 0.38, 0.46) * 0.6, float3(0.8, 0.9, 1.0), smoothstep(-0.05, 0.05, position.y - intersect.y * 0.5 + 0.1)); // Base color of the dolphin
        material.xyz *= smoothstep(0.0, 0.06, distance(float3(abs(position.x), position.yz) * float3(1.0, 1.0, 4.0), float3(0.35, 0.0, 0.4)));
        material.xyz *= 1.0 - 0.75 * (1.0 - smoothstep(0.0, 0.02, abs(position.y))) * (1.0 - smoothstep(0.07, 0.11, intersect.y));
        material.xyz *= 0.1 * 0.23 * 0.6;

        col = dolphinColor(pos, nor, rayDirection, 0.0, 0.0, 0.0, material.xyz, 1.0);
    }

	// gamma
    col = pow(clamp(col, 0.0, 1.0), float3(0.45, 0.45, 0.45));
    
    fragColor = float4(col, 1.0); // Set the fragment color
}*/

#define DOLPHIN_COUNT 2
#define NO_OF_SEGMENTS 11
#define F_NO_OF_SEGMENTS 11.0

// dolphin global variables
float jumping;
float time;
float segmentIdx = 0.0;
float3 ccd, ccp;

// This function gives you the shortest distance from a 2D point p to a finite line segment between a and b.
float2 lineSegmentDistance(float3 p, float3 start, float3 end)
{
	// Calculate the vector from the start of the line segment to the point
    float3 startToPoint = p-start;
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
    float3 worldOffset = float3(0.0, 0.0, fmod(-speed * time, 10.0) - 5.0);
    
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
        float2 dist = lineSegmentDistance(p,startPoint, endPoint);

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
    -radius);

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
    -position1;
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
    -position2 - direction2 * 0.25;
    pf.yz = mul(pf.yz, mf);
    float distance4 = length(pf.xz) - 0.6;
    distance4 = max(distance4, -(length(pf.xz - float2(0.0, 0.8)) - 0.9));
    distance4 = max(distance4, distanceToBox(pf, float3(1.0, 0.005, 1.0), 0.005));
    result.x = smoothUnion(result.x, distance4, 0.1);
		// Return the signed distance and the auxiliary value
    return result;
}

float3 dolphinNormal(float3 p, int dolphinIDX, float time)
{
    float3 normal = float3(0.0, 0, 0);
    const float eps = 0.08; // Smaller epsilon for more accurate normals
    
    for (int i = 0; i < 4; i++)
    {
        float3 e = 0.5773 * (2.0 * float3((((i + 3) >> 1) & 1), ((i >> 1) & 1), (i & 1)) - 1.0);
        float2 dist = dolphinDistance(p
        + eps * e, _positionDolphinFloat[dolphinIDX], _timeOffsetDolphinFloat[dolphinIDX], _speedDolphinFloat[dolphinIDX], _directionDolphinFloat[dolphinIDX], time);
        normal += e * dist.x; // Use the distance field value
    }
    
    return normalize(normal);
}
void getDolhpinColor(float3 position, out float3 color)
{
    float3 material;
    material.xyz = lerp(float3(0.3, 0.38, 0.46) * 0.6, float3(0.8, 0.9, 1.0), smoothstep(-0.05, 0.05, position.y - segmentIdx * 0.5 + 0.1)); // Base color of the dolphin
    material.xyz *= smoothstep(0.0, 0.06, distance(float3(abs(position.x), position.yz) * float3(1.0, 1.0, 4.0), float3(0.35, 0.0, 0.4)));
    material.xyz *= 1.0 - 0.75 * (1.0 - smoothstep(0.0, 0.02, abs(position.y))) * (1.0 - smoothstep(0.07, 0.11, segmentIdx));
    material.xyz *= 0.1 * 0.23 * 0.6;
    color = material;
}

void addDolphin_float(float index, float3 position, float timeOffset, float speed, float3 direction, out float indexOut)
{
    for (int i = 0; i <= index; i++)
    {
        if (i == index)
        {
            _positionDolphinFloat[i] = position;
            _timeOffsetDolphinFloat[i] = timeOffset;
            _speedDolphinFloat[i] = speed;
            _directionDolphinFloat[i] = direction;
        }
    }
    indexOut = index + 1;
}

void raymarchDolphin_float(float numDolphins, float2 uv, float3x3 camMatrix, out float3 hitPos, out float gHitID, out float3 normal)
{
    float3 rayDirection = normalize(mul(half3(uv, -1.0), camMatrix));
    time = 0.6 + 2.0 * _Time.y - 20.0;
    jumping = 0.5 + 0.5 * cos(-0.4 + 0.5 * time);
    float t = 0.0;
    hitPos = float3(0, 0, 0);
    for (int i = 0; i < 100; i++)
    {
        float3 p = _rayOrigin + rayDirection * t; // Current point in the ray
        half noise = get_noise(p);
        float d = 1e5;
        int bestID = -1;
        for (int i = 0; i < numDolphins; ++i)
        {
            float di = dolphinDistance(p, _positionDolphinFloat[i], _timeOffsetDolphinFloat[i], _speedDolphinFloat[i], _directionDolphinFloat[i], time).x;
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
            normal = dolphinNormal(hitPos, gHitID, time);
            break;
        }
        if (t > 50.0)
            break;
        t += d;
    }
}
#endif