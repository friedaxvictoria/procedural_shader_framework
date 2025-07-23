#define DOLPHIN_COUNT 2
#define NO_OF_SEGMENTS 11
#define F_NO_OF_SEGMENTS 11.0

float layer1Amp = 2.0;
float later2Amp = 1.0;
float layer3Amp = 1.0;

float layer1Freq = 0.2;
float later2Freq = 0.275;
float layer3Freq = 0.5*3.0;

vec3 desertColor1 = vec3(1.0,.95,.7);
vec3 desertColor2 = vec3(.9,.6,.4);
  

// Desert noise functions
float n2D(vec2 p) {
    vec2 i = floor(p); p -= i; 
    p *= p*(3. - p*2.);   
    return dot(mat2(fract(sin(mod(vec4(0, 1, 113, 114) + dot(i, vec2(1, 113)), 6.2831853))*
               43758.5453))*vec2(1. - p.y, p.y), vec2(1. - p.x, p.x) );
}

float surfFunc( in vec3 p){
    p /= 2.5;
    float layer1 = n2D(p.xz*layer1Freq)*layer1Amp - .5;
    layer1 = smoothstep(0., 1.05, layer1);
    float layer2 = n2D(p.xz*later2Freq) * later2Amp;
    layer2 = 1. - abs(layer2 - .5)*2.;
    layer2 = smoothstep(.2, 1., layer2*layer2);
    float layer3 = n2D(p.xz*layer3Freq) * layer3Amp;
    float res = layer1*.7 + layer2*.25 + layer3*.05;
    return res;
}

float mapDesert(vec3 p){
    float sf = surfFunc(p);
    return p.y + (.5-sf)*2.; 
}

// Desert ripple functions
mat2 rot2(in float a){ float c = cos(a), s = sin(a); return mat2(c, s, -s, c); }

vec2 hash22(vec2 p) {
    float n = sin(dot(p, vec2(113, 1)));
    p = fract(vec2(2097152, 262144)*n)*2. - 1.;
    return p;
}

float gradN2D(in vec2 f){
    const vec2 e = vec2(0, 1);
    vec2 p = floor(f);
    f -= p;
    vec2 w = f*f*(3. - 2.*f);
    float c = mix(mix(dot(hash22(p + e.xx), f - e.xx), dot(hash22(p + e.yx), f - e.yx), w.x),
                  mix(dot(hash22(p + e.xy), f - e.xy), dot(hash22(p + e.yy), f - e.yy), w.x), w.y);
    return c*.5 + .5;
}

float grad(float x, float offs){
    x = abs(fract(x/6.283 + offs - .25) - .5)*2.;
    float x2 = clamp(x*x*(-1. + 2.*x), 0., 1.);
    x = smoothstep(0., 1., x);
    return mix(x, x2, .15);
}

float sandL(vec2 p){
    vec2 q = rot2(3.14159/18.)*p;
    q.y += (gradN2D(q*18.) - .5)*.05;
    float grad1 = grad(q.y*80., 0.);
   
    q = rot2(-3.14159/20.)*p;
    q.y += (gradN2D(q*12.) - .5)*.05;
    float grad2 = grad(q.y*80., .5);
      
    q = rot2(3.14159/4.)*p;
    float a2 = dot(sin(q*12. - cos(q.yx*12.)), vec2(.25)) + .5;
    float a1 = 1. - a2;
    float c = 1. - (1. - grad1*a1)*(1. - grad2*a2);
    return c;
}

float sand(vec2 p){
    p = vec2(p.y - p.x, p.x + p.y)*.7071/4.;
    float c1 = sandL(p);
    vec2 q = rot2(3.14159/12.)*p;
    float c2 = sandL(q*1.25);
    return mix(c1, c2, smoothstep(.1, .9, gradN2D(p*vec2(4))));
}

float bumpSurf3D( in vec3 p){
    float n = surfFunc(p);
    vec3 px = p + vec3(.001, 0, 0);
    float nx = surfFunc(px);
    vec3 pz = p + vec3(0, 0, .001);
    float nz = surfFunc(pz);
    return sand(p.xz + vec2(n - nx, n - nz)/.001*1.);
}

vec3 doBumpMap(in vec3 p, in vec3 nor, float bumpfactor){
    const vec2 e = vec2(0.001, 0); 
    float ref = bumpSurf3D(p);
    vec3 grad = (vec3(bumpSurf3D(p - e.xyy),
                      bumpSurf3D(p - e.yxy),
                      bumpSurf3D(p - e.yyx)) - ref)/e.x; 
    grad -= nor*dot(nor, grad);          
    return normalize(nor + grad*bumpfactor);
}

// dolphin global variables
float jumping;
float time;
float segmentIdx = 0.0;
vec3 ccd, ccp;

// Global variables for raymarching
int gHitID;       // ID of the closest hit shape

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

float dolphinSignedDistance(vec3 point, Dolphin dolphin, float time) {

    // We translate the point to be in local space of the dolphin, so all calculations can be done as if the dolphin is centered at the origin.
	// Get the Dolphin's Current Animation Offset
	    vec3 startPoint = dolphinMovement(time, dolphin.timeOffset, dolphin.position, dolphin.speed, dolphin.direction);
	// initialize to a very large number
	float x = 100000.0;

	for(int i=0; i<NO_OF_SEGMENTS; i++)
	{
		// Calculate the position of the dolphin's body segment
		float segmentPosition = float(i)/F_NO_OF_SEGMENTS;
		// Get Animation for this Segment
		vec2 segmentAnimation = dolphinAnimation(segmentPosition, time, dolphin.timeOffset);
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
// structure for SDF functions
struct SDF {
    int   type;       // 0 for sphere, 1 for round box, 2 for torus
    vec3  position;  // position of the shape in world space
    vec3  size;      // for round box this is the size of the box, for torus this is the major radius and minor radius
    float radius;   // For sphere this is the radius, for round box, this is the corner radius
    vec3 color;
};

SDF sdfArray[10]; // Array to hold SDF shapes

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          noise module                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////
void GetGradient(vec2 intPos, float t, out vec2 result) {
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    result =  vec2(cos(angle), sin(angle));
}

void Pseudo3dNoise(vec3 pos, out float result) {
    vec2 i = floor(pos.xy);
    vec2 f = fract(pos.xy);
    vec2 blend = f * f * (3.0 - 2.0 * f);
    vec2 gradient;
    GetGradient(i + vec2(0, 0), pos.z, gradient);
    float a = dot(gradient, f - vec2(0.0, 0.0));
    GetGradient(i + vec2(1, 0), pos.z, gradient);
    float b = dot(gradient, f - vec2(1.0, 0.0));
    GetGradient(i + vec2(0, 1), pos.z, gradient);
    float c = dot(gradient, f - vec2(0.0, 1.0));
    GetGradient(i + vec2(1, 1), pos.z, gradient);
    float d = dot(gradient, f - vec2(1.0, 1.0));

    float xMix = mix(a, b, blend.x);
    float yMix = mix(c, d, blend.x);
    result = mix(xMix, yMix, blend.y) / 0.7; // Normalize
}

void fbmPseudo3D(vec3 p, int octaves, out float result) {
    result = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    float noise;

    for (int i = 0; i < octaves; ++i) {
        Pseudo3dNoise(p * frequency, noise);
        result += amplitude * noise;
        frequency *= 2.0;
        amplitude *= 0.5;
    }
}

// -----------------------------------------------------------------------------------
void hash44(vec4 p, vec4 result) {
    p = fract(p * vec4(0.1031, 0.1030, 0.0973, 0.1099));
    p += dot(p, p.wzxy + 33.33);
    result = fract((p.xxyz + p.yzzw) * p.zywx);
}

void n31(vec3 p, float result) {
    const vec3 S = vec3(7.0, 157.0, 113.0); // step vector: pairwise-prime
    vec3 ip = floor(p);
    p = fract(p);
    p = p * p * (3.0 - 2.0 * p); // Hermite smoother

    vec4 h = vec4(0.0, S.yz, S.y + S.z) + dot(ip, S);
    vec4 hash1, hash2;
    hash44(h, hash1);
    hash44(h + S.x, hash2);
    h = mix(hash1, hash2, p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    result = mix(h.x, h.y, p.z);
}

void fbm_n31(vec3 p, int octaves, out float value) {
    value = 0.0;
    float amplitude = 0.5;
    float nnn;
    for (int i = 0; i < octaves; ++i) {
        n31(p, nnn);
        value += amplitude *nnn;
        p *= 2.0;
        amplitude *= 0.5;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          material module                                          //
///////////////////////////////////////////////////////////////////////////////////////////////////////


void MakePlasticMaterial(
    vec3 Color,
    vec3 specularcolor,
    float specularstrength,
    float shininess,
    // Base Parameters
    out vec3 BaseColor,
    out vec3 SpecularColor,
    out float SpecularStrength,
    out float Shininess
){
    BaseColor = Color;
    SpecularColor = SpecularColor;
    SpecularStrength = SpecularStrength;
    Shininess = shininess;
    
}


void applyPhongLighting(
    // Surface Properties
    vec3 Position,
    vec3 Normal,
    vec3 ViewDir,
    
    // Light Properties
    vec3 LightPos,
    vec3 LightColor,
    vec3 AmbientColor,
    
    // Material Properties
    vec3 BaseColor,
    vec3 SpecularColor,
    float SpecularStrength,
    float Shininess,
    
    out vec3 OutputColor
){
    vec3 L = normalize(LightPos - Position);
    float diff = max(dot(Normal, L), 0.0);
    
    vec3 R = reflect(-L, Normal);
    float spec = pow(max(dot(R, ViewDir), 0.0), Shininess);
    
    vec3 diffuse = diff * BaseColor * LightColor;
    vec3 specular = spec * SpecularColor * SpecularStrength;
    
    OutputColor = AmbientColor + diffuse + specular;
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
    else if(s.type == 3) {
    return mapDesert(p - s.position);
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
    
           // Check all dolphins
    for (int i = 0; i < DOLPHIN_COUNT; ++i) {
        float di = dolphinDistance(p, dolphins[i], time).x;
        if(di < d) {
            d = di;
            bestID = 10 + i; // Use IDs >= 10 for dolphins
        }
    }
    
    gHitID = bestID;  // Store the ID of the closest hit shape
    return d;
}
// Estimate normal by central differences
vec3 SDFsNormal(vec3 p) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    return normalize(
        k.xyy * evaluateScene(p + k.xyy * h) +
        k.yyx * evaluateScene(p + k.yyx * h) +
        k.yxy * evaluateScene(p + k.yxy * h) +
        k.xxx * evaluateScene(p + k.xxx * h)
    );
}

// Raymarching function
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;     // Current point in the ray
        float noise;
        fbmPseudo3D(p, 1, noise);    // here you can replace fbmPseudo3D with fbm_n31 for different noise
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

void getDesertColor(vec3 p, out vec3 color) {
    float ripple = sand(p.xz);
    color = mix(desertColor1, desertColor2, ripple);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
     // replcae fragCoord and iResolution with your engine variables
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;  
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 lightPos   = vec3(5.0, 5.0, 5.0);  // Light position in world space
    vec3 lightColor = vec3(1.0);
    vec3 ambientCol = vec3(0.1);     // Ambient light color
    vec3 color;
        // dolphin animation
	time = 0.6 + 2.0*iTime - 20.0;
	jumping  = 0.5 + 0.5*cos(-0.4+0.5*time);
    
    
    // Initialize SDF shapes
    SDF circle = SDF(0, vec3(0.0), vec3(0.0), 1.0, vec3(0.2,0.2,1.0));
    SDF roundBox = SDF(1, vec3(1.9,0.0,0.0), vec3(1.0,1.0,1.0), 0.2,vec3(0.2,1.0,0.2));
    SDF roundBox2 = SDF(1, vec3(-1.9,0.0,0.0), vec3(1.0,1.0,1.0), 0.2, vec3(0.2,1.0,0.2));
    SDF torus = SDF(2, vec3(0.0), vec3(1.0,5.0,1.5), 0.2, vec3(1.0,0.2,0.2));
    SDF desert = SDF(3, vec3(0.0, -5.0, 0.0), vec3(0.0), 0.0, vec3(1.0, 0.95, 0.7));
    // Add shapes to the array
    sdfArray[0] = circle;
    sdfArray[1] = roundBox;
    sdfArray[2] = roundBox2;
    sdfArray[3] = torus;
    sdfArray[4] = desert; 
    // Initialize dolphins
    dolphins[0] = Dolphin(
        vec3(0.0, 0.0, 0.0), // position
        0.0,                 // timeOffset
        1.5,                 // speed
        vec3(0.0, 0.0, -1.0) // direction
    );
    dolphins[1] = Dolphin(
        vec3(2.0, 0.5, 1.0), // position
        3.0,                 // timeOffset
        1.2,                 // speed
        vec3(-0.3, 0.0, -0.7)// direction
    ); 

    int dolphinCount = 2;   // used to draw all dolphins

    vec3 ro = vec3(0.0, 0.0, 8.0);         // Ray origin
    vec3 rd = normalize(vec3(uv, -1));

    vec3 hitPos;
    float t = raymarch(ro, rd, hitPos);  // Raymarching to find the closest hit point
    
    vec3 viewDir = normalize(ro-hitPos); // Direction from hit point to camera
    
    vec3 BaseColor;
    vec3 SpecularColor;
    float SpecularStrength;
    float Shininess;
    
    if (t > 0.0) {
    if(sdfArray[gHitID].type == 3) {
    // Desert-specific rendering
    vec3 normal = SDFsNormal(hitPos);
    normal = doBumpMap(hitPos, normal, 0.07); 
    
     SpecularColor = vec3(0.1);
     SpecularStrength = 0.2;
     Shininess = 8.0;
    
    getDesertColor(hitPos, BaseColor);
    
    applyPhongLighting(hitPos, normal, viewDir, lightPos, lightColor, ambientCol, 
                      BaseColor, SpecularColor, SpecularStrength, Shininess, color);
     }
     else
      {
    if(gHitID < 10){
    vec3 normal = SDFsNormal(hitPos);  // Estimate normal at the hit point
     SpecularColor = vec3(0.1);
     SpecularStrength = 0.2;
     Shininess = 8.0;
     
     MakePlasticMaterial(sdfArray[gHitID].color,vec3(1.0), 1.0, 32.0,BaseColor,SpecularColor,SpecularStrength,Shininess);    
     applyPhongLighting(hitPos, normal, viewDir, lightPos, lightColor, ambientCol, BaseColor, SpecularColor, SpecularStrength, Shininess, color);
    }
    
    else
    {
        int dolhpinID = gHitID-10;
        vec3 normal = dolphinNormal(hitPos, dolhpinID, time);
        vec3 dolphinColor;
        
        // Material calculation (using segmentIdx from dolphinDistance)
        vec3 tangentV = normalize(vec3(-ccd.z, 0.0, ccd.x));
        vec3 bitangentV = normalize(cross(ccd, tangentV));
        vec3 position = vec3(
            dot(hitPos-ccp, tangentV),
            dot(hitPos-ccp, bitangentV),
            segmentIdx
        );
        
        getDolhpinColor(position, dolphinColor);
        	float diff = max(0.0, dot(normal, lightPos)); // Lambertian diffuse lighting 

        vec3 BRDF = 20.0*diff*vec3(4.00,2.20,1.40);
        dolphinColor*=BRDF;

    applyPhongLighting(hitPos, normal, viewDir, lightPos, lightColor, ambientCol, dolphinColor, vec3(0.0), 0.0, 0.0, color);
    
        }
    }
}
    else {
        color = vec3(0.0); // Background
    }

    fragColor = vec4(color, 1.0);
}