#define MAX_STEPS 100 // Step up to 100 times. If it hasn't hit the object yet, give up
#define MAX_DIST 100.0 // If the light travels a total distance of more than 100 units, it is also considered not to have touched the object.
#define SURF_DIST 0.01 //If the current distance from the surface of the object is less than 0.01, it is considered to have touched the surface.

/* 
input:
   ro(ray origin): world-space camera position
   rd(ray direciton): normalized, from camera to object
output: 
   bool: true  = surface hit, false = background
   dist: travelled distance along the ray when the loop stops(if hit, it is the distance from the camera to the object)
*/
bool RayMarch(vec3 ro, vec3 rd, out float dist) 
{
    float dist = 0.0;                       
    for (int i = 0; i < MAX_STEPS; i++) 
    { 
        vec3 currentPos  = ro + rd * dist;           
        float distToSDF = scene(currentPos);              /* !!! Make sure the SDF for your object is provided through a global function named scene !!! */                         
        if (distToSDF < SURF_DIST) return true;
        dist = dist + distToSDF;
        if (dist > MAX_DIST) break;
    }
    return false;                            
}
/*
1. use Ray-marching function to obtain the hit distance
2. Compute the exact hit position: currentPos  = ray_origin + ray_direction * hit_distance
3. Estimate the surface normal at the hit position
4. Then use surface normal to compute color, shadow ...

usage example:

float dist;
bool hit = RayMarch(ro, rd, dist);

vec3 color = vec3(0.0);
if (hit) {
    vec3 hitPos = ro + rd * dist;
    vec3 n = Normal(hitPos);
    color  = shadeLambert(n, baseColor, lightDir);
}
*/