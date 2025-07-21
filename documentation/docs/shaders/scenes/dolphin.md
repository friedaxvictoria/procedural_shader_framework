<!-- this one is to display the shader output either by locally storing in the directory under static/images/...
or, external link like of a github can be added -->

<!-- this is for locally stored images -->
<!-- <img src="image directory stored locally inside project" alt="TIE Fighter" width="400" height="225"> -->
<!-- this is for external  link  -->
<!-- <img src="https://......." width="400" alt="TIE Fighter Animation"> -->



<!-- this is for locally stored videos -->
<!-- <video controls width="640" height="360" > -->
  <!-- <source src="video path stored locally" type="video/mp4"> -->
  <!-- Your browser does not support the video tag. -->
<!-- </video> -->

<!-- this is for external link, copy the embed code for given video and paste it here -->
<!-- <iframe width="640" height="360"  -->
  <!-- src="https://www.youtube.com/embed/VIDEO_ID"  -->
  <!-- title="TIE Fighter Shader Demo" -->
  <!-- frameborder="0" allowfullscreen></iframe> -->



<div class="container">
    <h1 class="main-heading">Dolphin Shader</h1>
    <blockquote class="author">by Saeed Shamseldin</blockquote>
</div>

---

## Overview
This GLSL shader creates an animated 3D dolphin model using signed distance fields (SDFs) and procedural animation techniques. The shader supports multiple dolphin instances with independent animations and movements.

## Key Features

- Procedurally animated dolphin with smooth swimming motion

- Multiple dolphin instances (configurable count)

- Signed distance field rendering for smooth surfaces

- Detailed body shape with fins and tail

- Time-based animations for natural movement

## Constants

- **DOLPHIN_COUNT**: Number of dolphin instances

- **NO_OF_SEGMENTS**: Number of spine segments for dolphin body

- **F_NO_OF_SEGMENTS**: Floating point version of segment count

## Dolphin Struct
```glsl
struct Dolphin {
    vec3 position;      // Base position in world space
    float timeOffset;   // Animation phase offset
    float speed;        // Movement speed
    vec3 direction;     // Movement direction
};
```

## Core Functions
### `lineSegmentDistance(vec3 point, vec3 start, vec3 end)`
Calculates the shortest distance from a point to a line segment.

### Parameters:

- **point**: 3D point to test

- **start**: Start of line segment

- **end**: End of line segment

### Returns:

- **`vec2`**: x = squared distance, y = projection parameter along segment

### `distanceToBox(vec3 point, vec3 halfExtent, float radius)`
Calculates distance to a rounded box.

### Parameters:

- **point**: 3D point to test

- **halfExtent**: Half dimensions of the box

- **radius**: Corner rounding radius

### `smoothUnion(float distance1, float distance2, float smoothFactor)`
Smoothly blends two distance fields.

### `dolphinAnimation(float position, float time, float timeOffset)`
Generates animation parameters for dolphin segments.

#### Returns:

- **`vec2`**: x = angle, y = thickness

**`dolphinMovement(float time, float timeOffset, vec3 basePosition, float speed, vec3 direction)`**
Calculates dolphin's movement through space.

**`dolphinDistance(vec3 point, Dolphin dolphin, float time)`**
Main distance function for the dolphin.

#### Returns:

- **`vec2`**: x = signed distance, y = normalized position along body

**`dolphinNormal(vec3 point, int dolphinIDX, float time)`**
Calculates surface normal at a point.

**`getDolhpinColor(vec3 position, out vec3 color)`**
Determines dolphin's color at a given position.

## Animation System
The dolphin animation combines several wave functions to create natural swimming motion:

- Body undulation using cosine waves

- Jumping behavior with vertical movement

- Independent fin and tail animations

## Technical Details
- Uses signed distance fields for smooth surfaces

- Implements smooth blending between body parts

- Transforms points into local coordinate systems for fins and tail

- Uses segment-based approach for body construction

## Usage
1. Initialize dolphin instances in the `dolphins` array

2. For each frame:

    - Calculate dolphin movement with `dolphinMovement`

    - Evaluate distance field with `dolphinDistance`

    - Calculate normals with `dolphinNormal` for lighting

    - Apply coloring with `getDolhpinColor`

## Customization
To modify the shader:

  - Adjust **`DOLPHIN_COUNT`** for more/less dolphins

  - Change **`NO_OF_SEGMENTS`** for more/less body detail

  - Modify animation parameters in **`dolphinAnimation`**

  - Adjust movement patterns in **`dolphinMovement`**

  - Change color calculations in **`getDolhpinColor`**

<details>
<summary>Show Code</summary>

```glsl
#define DOLPHIN_COUNT 2
#define NO_OF_SEGMENTS 11
#define F_NO_OF_SEGMENTS 11.0

// dolphin global variables
float jumping;
float time;
float segmentIdx = 0.0;
vec3 ccd, ccp;

// Dolphin struct to hold instance data
struct Dolphin {
    vec3 position;
    float timeOffset;
    float speed;
    vec3 direction;
};

Dolphin dolphins[2];

// This function gives you the shortest distance from a 2D point p to a finite line segment between a and b.
vec2 lineSegmentDistance(vec3 point, vec3 start, vec3 end) {
	// Calculate the vector from the start of the line segment to the point
	vec3  startToPoint = point - start;
	// Calculate the vector from the start of the line segment to the end
	vec3  startToEnd = end - start;
	// Calculate the projection of the point onto the line segment
	float projection = clamp(dot(startToPoint, startToEnd) / dot(startToEnd, startToEnd), 0.0, 1.0);
	// Calculate the closest point on the line segment to the point
	vec3 vecToClosestPoint = startToPoint - projection * startToEnd;
	// Calculate the length of the vector to the closest point
	return vec2(dot(vecToClosestPoint,vecToClosestPoint), projection);
}

float distanceToBox(vec3 point, vec3 halfExtent, float radius) {
	// Calculate the distance from the point to the box
	vec3 distanceToBox = abs(point) - halfExtent;
	// Returns: Negative inside the rounded box, Zero on the surface, Positive outside.
	return length(max(distanceToBox, 0.0)) - radius;
}

// Blends two distances smoothly, instead of taking the harsh minimum (min()), which gives a hard union in SDFs.
float smoothUnion(float distance1, float distance2, float smoothFactor) {
	// h decides how much to interpolate between distance2 and distance1
	float h = clamp(0.5 + 0.5 * (distance2 - distance1) / smoothFactor, 0.0, 1.0);
	return mix(distance2, distance1, h) - smoothFactor * h * (1.0 - h);
}

// Modified animation function with instance parameters
vec2 dolphinAnimation(float position, float time, float timeOffset) {
    float adjustedTime = time + timeOffset;
    float angle1 = 0.9*(0.5+0.2*position)*cos(5.0*position - 3.0*adjustedTime + 6.2831/4.0);
    float angle2 = 1.0*cos(3.5*position - 1.0*adjustedTime + 6.2831/4.0);
    float jumping = 0.5 + 0.5*cos(-0.4+0.5*adjustedTime);
    float finalAngle = mix(angle1, angle2, jumping);
    float thickness = 0.4*cos(4.0*position - 1.0*adjustedTime)*(1.0-0.5*jumping);
    return vec2(finalAngle, thickness);
}

// generates a 3D animation offset vector used to animate some aspect of the dolphin

// Modified movement function with instance parameters
vec3 dolphinMovement(float time, float timeOffset, vec3 basePosition, float speed, vec3 direction) {
    float adjustedTime = time + timeOffset;
    float jumping = 0.5 + 0.5*cos(-0.4+0.5*adjustedTime);
    
    vec3 movement1 = vec3(0.0, sin(3.0*adjustedTime + 6.2831/4.0), 0.0);
    vec3 movement2 = vec3(0.0, 1.5 + 2.5*cos(1.0*adjustedTime), 0.0);
    vec3 finalMovement = mix(movement1, movement2, jumping);
    finalMovement.y *= 0.5;
    finalMovement.x += 0.1*sin(0.1 - 1.0*adjustedTime)*(1.0-jumping);
    
    // Apply linear movement
    vec3 worldOffset = vec3(0.0, 0.0, mod(-speed * time, 10.0) - 5.0);
    
    return basePosition + finalMovement + worldOffset;
}

//returning: res.x: The signed distance from point p to the dolphin. res.y: A parameter h that stores a normalized position along the dolphin's body (used for further shaping/decorating).
vec2 dolphinDistance(vec3 point, Dolphin dolphin, float time) {

	// Initialize the result to a very large distance and an auxiliary value of 0. We'll minimize this value over the dolphin's body parts.
	vec2 result = vec2( 1000.0, 0.0);
	// Transform Point into Dolphin Local Space
	// Initialize the start point for the dolphin's body
	vec3 startPoint = dolphinMovement(time, dolphin.timeOffset, dolphin.position, dolphin.speed, dolphin.direction);

	vec3 position1 = startPoint;
	vec3 position2 = startPoint;
	vec3 position3 = startPoint;
	vec3 direction1 = vec3(0.0,0.0,0.0);
	vec3 direction2 = vec3(0.0,0.0,0.0);
	vec3 direction3 = vec3(0.0,0.0,0.0);
	vec3 closestPoint = startPoint;
	// Iterates through all the dolphin’s spine segments (same concept as in dolphinSignedDistance)
	for(int i=0; i<NO_OF_SEGMENTS; i++)
	{
		// Compute Normalized Segment Index and Animation
		float segmentPosition = float(i)/F_NO_OF_SEGMENTS;
		vec2 segmentAnimation = dolphinAnimation(segmentPosition, time, dolphin.timeOffset);
		// The length of segments
		float segmentLength = 0.48; if( i==0 ) segmentLength=0.655;
		// endPoint is the end point of the current segment. The orientation of the segment is controlled by angles (segmentAnimation.x, segmentAnimation.y). This creates a wavy, sinuous body as the dolphin swims.
		vec3 endPoint = startPoint + segmentLength*normalize(vec3(sin(segmentAnimation.y), sin(segmentAnimation.x), cos(segmentAnimation.x)));
		// Calculate the distance from the point to the line segment defined by startPoint and endPoint
		vec2 dist = lineSegmentDistance(point, startPoint, endPoint);

		if(dist.x < result.x)
		{
			result = vec2(dist.x,segmentPosition+dist.y/F_NO_OF_SEGMENTS);
			closestPoint = startPoint + dist.y*(endPoint-startPoint);
			ccd = endPoint - startPoint; // This is the direction vector of the segment

		}
		// Store Specific Segment Info for Fins and Tail
		if(i==3) 
		{position1 = startPoint; direction1 = endPoint-startPoint;}
		if(i==4)
		{position3 = startPoint; direction3 = endPoint-startPoint;}
		if(i==(NO_OF_SEGMENTS-1))
		{position2 = endPoint; direction2 = endPoint-startPoint;}
		// Move Forward to Next Segment
		startPoint = endPoint;
	}
	   // Save Closest Point (This is the Target Line)
		ccp = closestPoint;
		// It lies in the range [0.0,1.0][0.0,1.0], where 0 is near the head and 1 is at the tail.
		float bodyRadius = result.y;
		// The radius of the dolphin's body at that point. This shapes the body to be thickest near the middle and tapering toward head and tail.
		float radius = 0.05 + bodyRadius*(1.0-bodyRadius)*(1.0-bodyRadius)*2.7;
		//This adds a bump in the radius near the front of the dolphin (around bodyRadius ≈ 0.04), which decays rapidly afterward.
		radius += 7.0*max(0.0,bodyRadius-0.04)*exp(-30.0*max(0.0,bodyRadius-0.04)) * smoothstep(-0.1, 0.1, point.y-closestPoint.y);
		// Reduces radius near the center line (point.y ≈ closestPoint.y) and only in the front part (h < 0.1).
		radius -= 0.03*(smoothstep(0.0, 0.1, abs(point.y-closestPoint.y)))*(1.0-smoothstep(0.0,0.1,bodyRadius));
		// Add Thickness Near the Head
		radius += 0.05*clamp(1.0-3.0*bodyRadius,0.0,1.0);
		radius += 0.035*(1.0-smoothstep( 0.0, 0.025, abs(bodyRadius-0.1) ))* (1.0-smoothstep(0.0, 0.1, abs(point.y-closestPoint.y)));
		// The true signed distance is the distance from point p to the spine (closestPoint) minus the radius at that location. Scaled by 0.75 to compress or adjust the final SDF
		result.x = 0.75 * (distance(point, closestPoint) - radius);	

		// fin part
		direction3 = normalize(direction3);
		float k = sqrt(1.0 - direction3.y*direction3.y);
		// Create a transformation matrix to align the local coordinate system with the dolphin's fin direction
		mat3 ms = mat3(
			direction3.z/k, -direction3.x*direction3.y/k, direction3.x,
			0.0,			k,							  direction3.y,
			-direction3.x/k, -direction3.y*direction3.z/k, direction3.z);
		// Transform the point into the local coordinate system of the fin
		vec3 ps = ms * (point - position3);
		ps.z -= 0.1; // This is the offset for the fin
		float distance5 = length(ps.yz) - 0.9;
		distance5 = max(distance5, -(length(ps.yz-vec2(0.6,0.0)) - 0.35) );
		distance5 = max(distance5, distanceToBox(ps+vec3(0.0,-0.5,0.5), vec3(0.0,0.5,0.5), 0.02 ) );
		result.x = smoothUnion(result.x, distance5, 0.1);

		// fin 
		direction1 = normalize(direction1);
		k = sqrt(1.0 - direction1.y*direction1.y);
		ms = mat3(
			direction1.z/k, -direction1.x*direction1.y/k, direction1.x,
			0.0, k, direction1.y,
			-direction1.x/k, -direction1.y*direction1.z/k, direction1.z);

		ps = point - position1;
		ps = ms * ps;
		ps.x = abs(ps.x);
		float l = ps.x;
		l = clamp((l-0.4)/0.5, 0.0, 1.0);
		l = 4.0 * l * (1.0 - l);
		l *= 1.0-clamp(5.0*abs(ps.z+0.2),0.0,1.0);
		ps.xyz += vec3(-0.2,0.36,-0.2);
		distance5 = length(ps.xz) - 0.8;
		distance5 = max(distance5, -(length(ps.xz-vec2(0.2,0.4)) - 0.8) );
		distance5 = max(distance5, distanceToBox(ps+vec3(0.0,0.0,0.0), vec3(1.0,0.0,1.0), 0.015+0.05*l ) );
		result.x = smoothUnion(result.x, distance5, 0.12);

		// tail part
		direction2 = normalize(direction2);
		mat2 mf = mat2(
			direction2.z, direction2.y,
			-direction2.y, direction2.z);
		vec3 pf = point - position2 - direction2*0.25;
		pf.yz = mf * pf.yz;
		float distance4 = length(pf.xz) - 0.6;
		distance4 = max(distance4, -(length(pf.xz-vec2(0.0,0.8)) - 0.9) );
		distance4 = max(distance4, distanceToBox(pf, vec3(1.0,0.005,1.0), 0.005 ) );
		result.x = smoothUnion(result.x, distance4, 0.1);
		// Return the signed distance and the auxiliary value
		return result;
}

vec3 dolphinNormal(vec3 point, int dolphinIDX, float time) {
    vec3 normal = vec3(0.0);
    const float eps = 0.08; // Smaller epsilon for more accurate normals
    
    for(int i = 0; i < 4; i++) {
        vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
        vec2 dist = dolphinDistance(point + eps*e, dolphins[dolphinIDX], time);
        normal += e * dist.x; // Use the distance field value
    }
    
    return normalize(normal);
}
void getDolhpinColor(vec3 position, out vec3 color){
        vec3 material;
		material.xyz = mix( vec3(0.3,0.38,0.46)*0.6, vec3(0.8,0.9,1.0), smoothstep(-0.05,0.05,position.y-segmentIdx*0.5+0.1) ); // Base color of the dolphin
		material.xyz *= smoothstep( 0.0, 0.06, distance(vec3(abs(position.x),position.yz)*vec3(1.0,1.0,4.0),vec3(0.35,0.0,0.4)));  
		material.xyz *= 1.0 - 0.75*(1.0-smoothstep( 0.0, 0.02, abs(position.y) ))*(1.0-smoothstep( 0.07, 0.11, segmentIdx ));
		material.xyz *= 0.1*0.23*0.6;
        color = material;
        }
```
</details>