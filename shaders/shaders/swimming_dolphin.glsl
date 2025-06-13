#define NO_OF_SEGMENTS 11
#define F_NO_OF_SEGMENTS 11.0

float jumping;
float jumping2;
float time;
vec3 dolphinPosition;

vec3 ccd, ccp;

const vec3 light = vec3(0.86,0.15,0.48);  // Light direction

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



//This function is responsible for computing the position and orientation of different parts of a model
vec2 animation(float position, float time)
{
	// position is a float parameter indexing the position along the dolphin's body
	// This generates a cosine wave animation across the dolphin's body.
	float angle1 = 0.9*(0.5+0.2*position)*cos(5.0*position - 3.0*time + 6.2831/4.0);
	// A slightly different wave pattern (lower frequency and slower time). Possibly for when the dolphin is in the air (jumping)
	float angle2 = 1.0*cos(3.5*position - 1.0*time + 6.2831/4.0);
	// The mix() function is used to blend between the two angles based on the jumping variable.
	float finalAngle = mix(angle1, angle2, jumping);
	// controls a thickness or radial expansion/contraction, making the body more streamlined when jumping
	float thickness = 0.4*cos(4.0*position - 1.0*time)*(1.0-0.5*jumping);

	return vec2(finalAngle, thickness);
}

// generates a 3D animation offset vector used to animate some aspect of the dolphin

vec3 animation2(void)
{
	// Represents vertical bobbing while swimming. This gives the dolphin a rhythmic up-down motion in water.
	vec3 movement1 = vec3(0.0,sin(3.0*time+6.2831/4.0),0.0);
	// Used when the dolphin is jumping. Constant vertical offset (1.5) + dynamic cosine bounce
	vec3 movement2 =  vec3(0.0,1.5+2.5*cos(1.0*time),0.0);
	// Smooth interpolation between a1 and a2
	vec3 finalMovement = mix(movement1, movement2, jumping);
	// This prevents overly exaggerated vertical movement and keeps the dolphin’s motion more natural.
	finalMovement.y *=0.5;
	// Adds a small x-axis offset (horizontal sway) only when the dolphin is not jumping
	finalMovement.x += 0.1*sin(0.1 - 1.0*time)*(1.0-jumping);

	return finalMovement;
}

float dolphinSignedDistance(vec3 point)
{
    // We translate the point to be in local space of the dolphin, so all calculations can be done as if the dolphin is centered at the origin.
	point -= dolphinPosition;
	// Get the Dolphin's Current Animation Offset
	vec3 startPoint = animation2();
	// initialize to a very large number
	float x = 100000.0;

	for(int i=0; i<NO_OF_SEGMENTS; i++)
	{
		// Calculate the position of the dolphin's body segment
		float segmentPosition = float(i)/F_NO_OF_SEGMENTS;
		// Get Animation for this Segment
		vec2 segmentAnimation = animation(segmentPosition, time);
		// the length of segments
		float segmentLength = 0.48; if( i==0 ) segmentLength=0.655;
		// endPoint is the end point of the current segment. The orientation of the segment is controlled by angles (segmentAnimation.x, segmentAnimation.y). This creates a wavy, sinuous body as the dolphin swims.
		vec3 endPoint = startPoint + segmentLength*normalize(vec3(sin(segmentAnimation.y), sin(segmentAnimation.x), cos(segmentAnimation.x)));
		// Calculate the distance from the point to the line segment defined by startPoint and endPoint
		vec2 dist = lineSegmentDistance(point, startPoint, endPoint);
		float factor = segmentPosition+dist.y/F_NO_OF_SEGMENTS;
		// the radius of the dolphin's body at that point.
		float radius = 0.04 + factor*(1.0-factor)*(1.0-factor)*2.7;
		// Update the Minimum Distance
		x = min(x, sqrt(dist.x) - radius);
		// Update the startPoint for the next segment
		startPoint = endPoint;
	}
	return 0.75*x; // The function returns the signed distance from point to the dolphin body.
}


//returning: res.x: The signed distance from point p to the dolphin. res.y: A parameter h that stores a normalized position along the dolphin's body (used for further shaping/decorating).
vec2 dolphinDistance(vec3 point)
{
	// Initialize the result to a very large distance and an auxiliary value of 0. We'll minimize this value over the dolphin's body parts.
	vec2 result = vec2( 1000.0, 0.0);
	// Transform Point into Dolphin Local Space
	point -= dolphinPosition;
	// Initialize the start point for the dolphin's body
	vec3 startPoint = animation2();

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
		vec2 segmentAnimation = animation(segmentPosition, time);
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


vec2 dolphenIntersection(in vec3 ro, in vec3 rd)
{
	const float maxDistance = 10.0;   // Prevents infinite loops. Rays going too far are assumed to miss.
	const float minDistance = 0.001;  // Determines how close we need to get to say “we’ve hit the surface.”
	float t = 0.0; // Distance along the ray
	float segmentIdx = 0.0; // Index of the segment we are currently checking
	for (int i = 0; i < 128; i++) {
		vec3 p = ro + t * rd; // Current point along the ray
		vec2 result = dolphinDistance(p); // Get the signed distance and auxiliary value
		float dist = result.x; // The signed distance from the point to the dolphin
		segmentIdx = result.y; // Segment index (used for shading, coloring, etc.)
		if (dist < minDistance || t > maxDistance) 
		break; // If we are close enough to the surface or have gone too far, exit the loop
		t += dist; // Move along the ray by the signed distance
	}
	if (t > maxDistance) 
		t = -1.0; // If we went too far, return -1 to indicate no intersection
		
	return vec2(t, segmentIdx); // Return the distance along the ray and the segment index
}


vec3 dolphinNormal(vec3 point)
{
	vec3 normal = vec3(0.0);
	for(int i = 0; i < 4; i++)
	{
	    // For each of the 8 directions, we perturb the point slightly in that direction and compute the signed distance.
		vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
		normal += e * dolphinDistance(point + 0.08*e).x;
	}
	return normalize(normal);
}

float dolphinShadow(vec3 ro, vec3 rd, float mint, float k)
{
	float result = 1.0; // Initialize the shadow factor to 1 (no shadow)
	float t = mint; // Start from the minimum distance
	float dist;
	for(int i = 0; i < 25; i++)
	{
		dist = dolphinSignedDistance(ro + t * rd); // Get the signed distance at the current point
		result = min(result, k * dist/t); // Update the shadow factor
		t += clamp(dist, 0.05, 0.5); // Move along the ray by the signed distance, ensuring we don't move too little
		if(dist < 0.0001)
		break; // If we are very close to the surface, break out of the loop
	}
	return clamp(result, 0.0, 1.0); // Return the shadow factor, clamped between 0 and 1

}

vec3 dolphinColor(vec3 pos, vec3 nor, vec3 rd, float glossy, float glossy2, float shadows, vec3 col, float occlusion)
{
	vec3 halfWay = normalize(light - rd); // Calculate the halfway vector between the light direction and the ray direction
	vec3 reflection = reflect(rd, nor); // Calculate the reflection vector
	
	float sky = clamp(nor.y, 0.0, 1.0); 
	float ground = clamp(-nor.y, 0.0, 1.0); 
	float diff = max(0.0, dot(nor, light)); // Lambertian diffuse lighting 
	float back = max(0.3 + 0.7*dot(nor,-vec3(light.x, 0.0, light.z)), 0.0); // backlighting

	float shadow = 1.0 -shadows;
	if(shadows * diff > 0.001)
	{
		shadow = dolphinShadow(pos+0.01*nor, light, 0.0005, 32.0);
	}

	float fresnel = pow(clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 5.0 );
	float specular = max(0.0, pow(clamp(dot(halfWay, nor), 0.0, 1.0), 0.01 + glossy)); 

	float sss = pow(clamp(1.0 + dot(nor, rd), 0.0, 1.0), 2.0);

	float sh = 1.0;
	if(shadows > 0.0)
	{
		sh = dolphinShadow(pos + 0.01*nor, normalize(reflection+vec3(0.0,1.0,0.0)), 0.0005, 8.0 );
	}

	vec3 BRDF = vec3(0.0);  // Initialize the BRDF (Bidirectional Reflectance Distribution Function) to zero

	BRDF += 20.0*diff*vec3(4.00,2.20,1.40)*vec3(sh,sh*0.5+0.5*sh*sh,sh*sh);
    BRDF += 11.0*sky*vec3(0.20,0.40,0.55)*(0.5+0.5*occlusion);
    BRDF += 1.0*back*vec3(0.40,0.60,0.70);//*occ;
    BRDF += 11.0*ground*vec3(0.05,0.30,0.50);
    BRDF += 5.0*sss*vec3(0.40,0.40,0.40)*(0.3+0.7*diff*sh)*glossy*occlusion;
    BRDF += 0.8*specular*vec3(1.30,1.00,0.90)*sh*diff*(0.1+0.9*fresnel)*glossy*glossy;
    BRDF += sh*40.0*glossy*vec3(1.0,1.0,1.0)*occlusion*smoothstep( -0.3+0.3*glossy2, 0.2, reflection.y )*(0.5+0.5*smoothstep( -0.2+0.2*glossy2, 1.0, reflection.y ))*(0.04+0.96*fresnel);
    col = col*BRDF;
    col += sh*(0.1 + 1.6*fresnel)*occlusion*glossy2*glossy2*40.0*vec3(1.0,0.9,0.8)*smoothstep( 0.0, 0.2, reflection.y )*(0.5+0.5*smoothstep( 0.0, 1.0, reflection.y ));//*smoothstep(-0.1,0.0,dif);
    col += 1.2*glossy*pow(specular,4.0)*vec3(1.4,1.1,0.9)*sh*diff*(0.04+0.96*fresnel)*occlusion;
	
	return col;

}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 point = -1.0 + 2.0 * uv;
	point.x *= iResolution.x / iResolution.y; // Adjust aspect ratio
	vec2 mouse = vec2(0.5);
	if(iMouse.z > 0.0)
	mouse = iMouse.xy / iResolution.xy;

	// animation
	time = 0.6 + 2.0*iTime - 20.0;
	dolphinPosition = vec3( 0.0, 0.0-0.2, -1.1*time );
	jumping  = 0.5 + 0.5*cos(-0.4+0.5*time);
	jumping2 = 0.5 + 0.5*cos( 0.6+0.5*time);
	float jumping3 = 0.5 + 0.5*cos(-1.4+0.5*time);

	// camera
	float cameraAngle = 1.2 + 0.1*iTime - 12.0*(mouse.x-0.5); // camera angle around the dolphin (animated with time and affected by mouse
	vec3 target = vec3(dolphinPosition.x,0.8,dolphinPosition.z) - vec3(0.0,0.0,-2.0);  // target point (where the camera looks): near the dolphin, 0.8 above it.
	vec3 ro = target + vec3(4.0*sin(cameraAngle),3.1,4.0*cos(cameraAngle));

	// shake
	ro += 0.05*sin(4.0*iTime*vec3(1.1,1.2,1.3)+vec3(3.0,0.0,1.0) );
	target += 0.05*sin(4.0*iTime*vec3(1.7,1.5,1.6)+vec3(1.0,2.0,1.0) );

	// camera matrix
	vec3 forward = normalize(target - ro); // Forward vector (looking direction)
	vec3 right = normalize(vec3(-forward.z, 0.0, forward.x));  // Right vector (perpendicular to forward)
	vec3 up = normalize(cross(right, forward)); // Up vector (perpendicular to both forward and right)
	
	// view ray direction
	vec3 rd = normalize( point.x*right + point.y*up + 2.0*forward*(1.0+0.7*smoothstep(-0.4,0.4,sin(0.34*iTime))) );

	// render 
	float t = 1000.0; // Initialize the distance to a large value
	vec3 col = vec3(0.0); // Initialize color to black
	// skips tracing the empty upper sky and starts raymarching closer to where the dolphin geometry actually is.
	float pt = (3.2-ro.y)/rd.y;
	if( rd.y<0.0 && pt>0.0 ) ro=ro+rd*pt;

	vec2 intersect = dolphenIntersection(ro, rd);
	if(intersect.x > 0.0)
	{
		t = intersect.x; // If we hit the dolphin, get the distance
		vec3 pos = ro + t * rd; // Calculate the position of the intersection
		vec3 nor = dolphinNormal(pos); // Calculate the normal at the intersection point
		vec3 reflection = reflect(rd, nor); // Calculate the reflection vector
		vec3 localPos = pos - dolphinPosition; // Local position relative to the dolphin

		vec3 tangetV = normalize(vec3(-ccd.z, 0.0, ccd.x)); // Tangent vector along the dolphin's body
		vec3 bitangentV = normalize(cross(ccd, tangetV));  // Bitangent vector (perpendicular to both tangent and ccd)
		vec3 position = vec3(dot(localPos-ccp,tangetV), dot(localPos-ccp,bitangentV), intersect.y );
		vec2 uv = vec2( 1.0*atan(position.x,position.y)/3.1416, 4.0*position.z );  

		vec4 material;
		material.xyz = mix( vec3(0.3,0.38,0.46)*0.6, vec3(0.8,0.9,1.0), smoothstep(-0.05,0.05,position.y-intersect.y*0.5+0.1) ); // Base color of the dolphin
		material.xyz *= smoothstep( 0.0, 0.06, distance(vec3(abs(position.x),position.yz)*vec3(1.0,1.0,4.0),vec3(0.35,0.0,0.4)));  
		material.xyz *= 1.0 - 0.75*(1.0-smoothstep( 0.0, 0.02, abs(position.y) ))*(1.0-smoothstep( 0.07, 0.11, intersect.y ));
		material.xyz *= 0.1*0.23*0.6;

		col = dolphinColor(pos, nor, rd, 0.0, 0.0, 0.0, material.xyz, 1.0);
	}

	// gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.45));

	fragColor = vec4(col, 1.0); // Set the fragment color
}
