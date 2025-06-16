#define NO_OF_SEGMENTS 11
#define F_NO_OF_SEGMENTS 11.0

float jumping;
float jumping2;
float time;
vec3 dolphinPosition;

float segmentIdx = 0.0; // Index of the segment we are currently checking

vec3 ccd, ccp;

const vec3 light = vec3(0.86,0.15,0.48);  // Light direction

// Blends two distances smoothly, instead of taking the harsh minimum (min()), which gives a hard union in SDFs.
float smoothUnion(float distance1, float distance2, float smoothFactor) {
	// h decides how much to interpolate between distance2 and distance1
	float h = clamp(0.5 + 0.5 * (distance2 - distance1) / smoothFactor, 0.0, 1.0);
	return mix(distance2, distance1, h) - smoothFactor * h * (1.0 - h);
}

struct CameraState {
    vec3 eye;     // Camera position (origin)
    vec3 target;  // Look-at point
    vec3 up;      // Up direction
};

// ===============================
// === Camera animation config ===
// ===============================
struct CameraAnimParams {
    int mode;         // Animation mode: 0=static, 1=orbit, 2=ping-pong, 3=first-person
    float speed;      // Playback speed
    float offset;     // Time offset
    vec3 center;      // Center point to look at
    float radius;     // Radius for orbiting
};

// ======================================
// === Build camera direction matrix  ===
// ======================================
mat3 get_camera_matrix(CameraState cam) {
    vec3 f = normalize(cam.target - cam.eye);   // Forward direction
    vec3 r = normalize(cross(f, cam.up));       // Right direction
    vec3 u = cross(r, f);                       // Recomputed up
    return mat3(r, u, -f);  // Column-major: [right, up, -forward]
}

CameraState animate_camera(float time, CameraAnimParams param) {
    CameraState cam;
    float t = time * param.speed + param.offset;

    if (param.mode == 0) {
        // Static camera
        cam.eye = vec3(0.0, 2.0, 5.0);
        cam.target = param.center;
    }
    else if (param.mode == 1) {
        // Orbit around center (Y-axis)
    float angle = t;
    float x = param.center.x + param.radius * cos(angle);
    float z = param.center.z + param.radius * sin(angle);
    float y = param.center.y + 2.0; // Optional elevation
    cam.eye = vec3(x, y, z);
    cam.target = param.center;
    }
    else if (param.mode == 2) {
        // Back-and-forth (Z-axis)
        cam.eye = vec3(0.0, 1.5, sin(t) * param.radius + 5.0);
        cam.target = param.center;
    }
    else if (param.mode == 3) {
        // First-person forward movement
        cam.eye = vec3(t * param.radius, 1.0, 0.0);
        cam.target = cam.eye + vec3(0.0, 0.0, -1.0);
    }
    else {
        // Fallback
        cam.eye = vec3(0.0, 1.5, 5.0);
        cam.target = param.center;
    }

    cam.up = vec3(0.0, 1.0, 0.0);
    return cam;
}


// structure for SDF functions
struct SDF {
    int   type;       // 0 for sphere, 1 for round box, 2 for torus
    vec3  position;  // position of the shape in world space
    vec3  size;      // for round box this is the size of the box, for torus this is the major radius and minor radius
    float radius;   // For sphere this is the radius, for round box, this is the corner radius
};

int gHitID;       // ID of the closest hit shape

SDF sdfArray[10]; // Array to hold SDF shapes

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          noise module                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////
vec2 GetGradient(vec2 intPos, float t) {
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return vec2(cos(angle), sin(angle));
}

float Pseudo3dNoise(vec3 pos) {
    vec2 i = floor(pos.xy);
    vec2 f = fract(pos.xy);
    vec2 blend = f * f * (3.0 - 2.0 * f);

    float a = dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0.0, 0.0));
    float b = dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1.0, 0.0));
    float c = dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0.0, 1.0));
    float d = dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1.0, 1.0));

    float xMix = mix(a, b, blend.x);
    float yMix = mix(c, d, blend.x);
    return mix(xMix, yMix, blend.y) / 0.7; // Normalize
}

float fbmPseudo3D(vec3 p, int octaves) {
    float result = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; ++i) {
        result += amplitude * Pseudo3dNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return result;
}

// -----------------------------------------------------------------------------------
vec4 hash44(vec4 p) {
    p = fract(p * vec4(0.1031, 0.1030, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    return fract((p.xxyz + p.yzzw) * p.zywx);
}

float n31(vec3 p) {
    const vec3 S = vec3(7.0, 157.0, 113.0); // step vector: pairwise-prime
    vec3 ip = floor(p);
    p = fract(p);
    p = p * p * (3.0 - 2.0 * p); // Hermite smoother

    vec4 h = vec4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    h = mix(hash44(h), hash44(h + S.x), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

float fbm_n31(vec3 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < octaves; ++i) {
        value += amplitude * n31(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

/////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                         animation module                                          //
///////////////////////////////////////////////////////////////////////////////////////////////////////


// ===== Time modulation =====
// mode = 0 → linear
// mode = 1 → sin(t)
// mode = 2 → abs(sin(t))
float applyTimeMode(float t, int mode) {
    if (mode == 1) return sin(t);
    if (mode == 2) return abs(sin(t));
    return t;
}

// ===== Type 1: Sinusoidal translation =====
void forwardBackword(int sdfIndx, float t, vec4 param, int mode) {
    t = applyTimeMode(t, mode);
    vec3 dir = param.xyz;
    float speed = param.w;
    sdfArray[sdfIndx].position += dir * sin(t * speed);
}

// ===== Type 1: Sinusoidal translation =====
void backwordForward(int sdfIndx, float t, vec4 param, int mode) {
    t = applyTimeMode(t, mode);
    vec3 dir = param.xyz;
    float speed = param.w;
    sdfArray[sdfIndx].position -= dir * sin(t * speed);
}


// ===== Type 2: Rotation around own axis =====
void animateRotateSelf(int sdfIndx, float t, vec4 axisSpeed, int mode) {
    t = applyTimeMode(t, mode);
    float speed = axisSpeed.w;
    if (speed < 0.0001)
    vec3 axis = normalize(axisSpeed.xyz);
    float angle = t * speed;
    // No change to position yet; placeholder for normal rotation
}
//This function is responsible for computing the position and orientation of different parts of a model
vec2 dolphinAnimation(float position, float time)
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

vec3 dolphinAnimation2(void)
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
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           SDF module                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Signed distance functions for different shapes
float sdSphere( vec3 position, float radius )
{
  return length(position)-radius;
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

// radius.x is the major radius, radius.y is the minor radius
float sdTorus( vec3 p, vec2 radius )
{
    // length(p.xy) - radius.x measures how far this point is from the torus ring center in the XY-plane.
  vec2 q = vec2(length(p.xy)-radius.x,p.z);
  return length(q)-radius.y;
}

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

float dolphinSignedDistance(vec3 point)
{
    // We translate the point to be in local space of the dolphin, so all calculations can be done as if the dolphin is centered at the origin.
	point -= dolphinPosition;
	// Get the Dolphin's Current Animation Offset
	vec3 startPoint = dolphinAnimation2();
	// initialize to a very large number
	float x = 100000.0;

	for(int i=0; i<NO_OF_SEGMENTS; i++)
	{
		// Calculate the position of the dolphin's body segment
		float segmentPosition = float(i)/F_NO_OF_SEGMENTS;
		// Get Animation for this Segment
		vec2 segmentAnimation = dolphinAnimation(segmentPosition, time);
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
	vec3 startPoint = dolphinAnimation2();

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
		vec2 segmentAnimation = dolphinAnimation(segmentPosition, time);
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
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          material module                                          //
///////////////////////////////////////////////////////////////////////////////////////////////////////
struct MaterialParams {
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

MaterialParams createDefaultMaterialParams() {
    MaterialParams mat;
    mat.baseColor = vec3(1.0);
    mat.specularColor = vec3(1.0);
    mat.specularStrength = 1.0;
    mat.shininess = 32.0;

    mat.roughness = 0.5;
    mat.metallic = 0.0;
    mat.rimPower = 2.0;
    mat.fakeSpecularPower = 32.0;
    mat.fakeSpecularColor = vec3(1.0);

    mat.ior = 1.45;                    
    mat.refractionStrength = 0.0;     
    mat.refractionTint = vec3(1.0);
    return mat;
}

MaterialParams makePlastic(vec3 color) {
    MaterialParams mat = createDefaultMaterialParams();
    mat.baseColor = color;
    mat.metallic = 0.0;
    mat.roughness = 0.4;
    mat.specularStrength = 0.5;
    return mat;
}

struct LightingContext {
    vec3 position;    // World-space fragment position
    vec3 normal;      // Normal at the surface point (normalized)
    vec3 viewDir;     // Direction from surface to camera (normalized)
    vec3 lightDir;    // Direction from surface to light (normalized)
    vec3 lightColor;  // RGB intensity of the light source
    vec3 ambient;     // Ambient light contribution
};

vec3 applyPhongLighting(LightingContext ctx, MaterialParams mat) {
    float diff = max(dot(ctx.normal, ctx.lightDir), 0.0); // Lambertian diffuse

    vec3 R = reflect(-ctx.lightDir, ctx.normal);          // Reflected light direction
    float spec = pow(max(dot(R, ctx.viewDir), 0.0), mat.shininess); // Phong specular

    vec3 diffuse = diff * mat.baseColor * ctx.lightColor;
    vec3 specular = spec * mat.specularColor * mat.specularStrength;

    return ctx.ambient + diffuse + specular;
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////

// Evaluate the signed distance function for a given SDF shape
float evalSDF(SDF s, vec3 p) {
    if (s.type == 0) {
        return sdSphere((p - s.position), s.radius);
    } else if (s.type == 1) {
        return sdRoundBox(p - s.position, s.size, s.radius);
    }
    else if(s.type == 2)
        return sdTorus(p - s.position, s.size.yz);
        else if(s.type == 3){
            vec2 result = dolphinDistance(p);
            segmentIdx = result.y;
            return result.x;
            }
    return 1e5;
}
// Evaluate the scene by checking all SDF shapes
float evaluateScene(vec3 p) {
    float d = 1e5;
    int bestID = -1;
    for (int i = 0; i < 10; ++i) {
        float di = evalSDF(sdfArray[i], p);
        if(di < d)
        {
            d = di; // Update the closest distance
            bestID = i; // Update the closest hit ID
        }
    }
    gHitID = bestID;  // Store the ID of the closest hit shape
    return d;
}
// Estimate normal by central differences
vec3 getNormal(vec3 p) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    return normalize(
        k.xyy * evaluateScene(p + k.xyy * h) +
        k.yyx * evaluateScene(p + k.yyx * h) +
        k.yxy * evaluateScene(p + k.yxy * h) +
        k.xxx * evaluateScene(p + k.xxx * h)
    );
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
// Raymarching function
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;     // Current point in the ray
        float noise = fbmPseudo3D(p, 1);    // here you can replace fbmPseudo3D with fbm_n31 for different noise
        float d = evaluateScene(p) + noise*0.3*0.0; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }
    return -1.0; // No hit
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
     // replcae fragCoord and iResolution with your engine variables
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;  
    uv.x *= iResolution.x / iResolution.y;
    // Initialize SDF shapes
    SDF circle = SDF(0, vec3(0.0), vec3(0.0), 1.0);
    SDF roundBox = SDF(1, vec3(1.9,0.0,0.0), vec3(1.0,1.0,1.0), 0.2);
    SDF roundBox2 = SDF(1, vec3(-1.9,0.0,0.0), vec3(1.0,1.0,1.0), 0.2);
    SDF torus = SDF(2, vec3(0.0), vec3(1.0,5.0,1.5), 0.2);
    SDF dolphin = SDF(3, vec3(0.0), vec3(0.0), 0.0);
    // Add shapes to the array
    sdfArray[0] = circle;
    sdfArray[1] = roundBox;
    sdfArray[2] = roundBox2;
    sdfArray[3] = torus;
    sdfArray[4] = dolphin;

    CameraAnimParams camParams = CameraAnimParams(1, 1.5, 4.0, vec3(0), 12.0);
    CameraState camState;
    camState = animate_camera(iTime, camParams);
    mat3 camMat = get_camera_matrix(camState);
    
    forwardBackword(3, iTime, vec4(0.0, 0.0, 4.0, 0.5), 0);
    backwordForward(0, iTime, vec4(0.0, 0.0, 4.0, 0.5), 0);
    forwardBackword(1, iTime, vec4(4.0, 0.0, 0.0, 0.5), 0);
    backwordForward(2, iTime, vec4(4.0, 0.0, 0.0, 0.5), 0);

    // vec3 ro = camState.eye;
    vec3 ro = vec3(3.0, 0.0, 5.0);         // Ray origin
    //vec3 rd = normalize(camMat * normalize(vec3(uv, -1))); // Ray direction
    vec3 rd = normalize(vec3(uv, -1));

    vec3 hitPos;
    float t = raymarch(ro, rd, hitPos);  // Raymarching to find the closest hit point
    
    vec3 color;
    if (t > 0.0) {
    if(gHitID == 4)
    {
        vec3 nor = dolphinNormal(hitPos); // Calculate the normal at the intersection point
		vec3 reflection = reflect(rd, nor); // Calculate the reflection vector
		vec3 localPos = hitPos - dolphinPosition; // Local position relative to the dolphin

		vec3 tangetV = normalize(vec3(-ccd.z, 0.0, ccd.x)); // Tangent vector along the dolphin's body
		vec3 bitangentV = normalize(cross(ccd, tangetV));  // Bitangent vector (perpendicular to both tangent and ccd)
		vec3 position = vec3(dot(localPos-ccp,tangetV), dot(localPos-ccp,bitangentV), segmentIdx );
		vec2 uv = vec2( 1.0*atan(position.x,position.y)/3.1416, 4.0*position.z );  

		vec4 material;
		material.xyz = mix( vec3(0.3,0.38,0.46)*0.6, vec3(0.8,0.9,1.0), smoothstep(-0.05,0.05,position.y-segmentIdx*0.5+0.1) ); // Base color of the dolphin
		material.xyz *= smoothstep( 0.0, 0.06, distance(vec3(abs(position.x),position.yz)*vec3(1.0,1.0,4.0),vec3(0.35,0.0,0.4)));  
		material.xyz *= 1.0 - 0.75*(1.0-smoothstep( 0.0, 0.02, abs(position.y) ))*(1.0-smoothstep( 0.07, 0.11, segmentIdx ));
		material.xyz *= 0.1*0.23*0.6;

		color = dolphinColor(hitPos, nor, rd, 0.0, 0.0, 0.0, material.xyz, 1.0);
    }
    
   else{
    vec3 normal = getNormal(hitPos);  // Estimate normal at the hit point
    vec3 viewDir = normalize(ro-hitPos); // Direction from hit point to camera
    
    vec3 lightPos   = vec3(5.0, 5.0, 5.0);  // Light position in world space
    vec3 lightColor = vec3(1.0);            // Light color (white)
    vec3 L = normalize(lightPos - hitPos);  // Direction from hit point to light source
        
    vec3 ambientCol = vec3(0.1);     // Ambient light color
    
    // Prepare lighting context
    LightingContext ctx;
    ctx.position   = hitPos;
    ctx.normal     = normal;
    ctx.viewDir    = viewDir;
    ctx.lightDir   = L;
    ctx.lightColor = lightColor;
    ctx.ambient    = ambientCol;
    
    MaterialParams mat; // Material parameters for the hit object
    
    if (gHitID == 0) {  // Sphere
    mat = makePlastic(vec3(0.2,0.2,1.0));       // red sphere
    } else if (gHitID == 1 || gHitID == 2) {  // Round boxes
    mat = makePlastic(vec3(0.2,1.0,0.2));       // green boxes
    } else if (gHitID == 3) {    // Torus
    mat = createDefaultMaterialParams();
    mat.baseColor = vec3(1.0,0.2,0.2);          // blue torus
    mat.shininess = 64.0;
    } else {
    mat = createDefaultMaterialParams();     
    }

        color = applyPhongLighting(ctx, mat); // final color
        }
    } else {
        color = vec3(0.0); // Background
    }

    fragColor = vec4(color, 1.0);
}
