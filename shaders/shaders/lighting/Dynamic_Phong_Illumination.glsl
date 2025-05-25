// ==========================================
// Dynamic Phong Illumination Module
// Category: Lighting
// Description:
//  Calculate the surface normal.
//  Compute the mirror reflection, diffuse reflection, and ambient light 
//  according to the Phong model with dynamic light sources..
// Screenshot: screenshots/lighting/dynamic_phong_lighting.png
// ==========================================

// ------------------------------------------
// Input: A sample point in the Signed Distance Function (SDF).
// Output: The surface normal direction at the position of point p.
// Description: The function estimates the surface normal using the finite difference method, 
//              specifically by calculating the SDF (Signed Distance Function) differences between a point and its neighbors.
// ------------------------------------------
vec3 estimateNormal(vec3 p) {
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}

// ------------------------------------------
// Input: vec3 k_d: Diffuse reflection coefficient
//        vec3 k_s: Specular reflection coefficient
//        float alpha: Shininess coefficient
//        vec3 p: Point on the surface
//        vec3 eye: Camera or observer position
//        vec3 lightPos: Light source position
//        vec3 lightIntensity: Light intensity
// Output: The lighting color contribution from a single light source.
// Description: A wrapper function to facilitate the setup of multiple dynamic light sources.
// ------------------------------------------
vec3 phongContribForLight(vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye,
                          vec3 lightPos, vec3 lightIntensity) {
    vec3 N = estimateNormal(p);
    vec3 L = normalize(lightPos - p);
    vec3 V = normalize(eye - p);
    vec3 R = normalize(reflect(-L, N));
    
    float dotLN = dot(L, N);
    float dotRV = dot(R, V);
    
    if (dotLN < 0.0) {
        // Light not visible from this point on the surface
        return vec3(0.0, 0.0, 0.0);
    } 
    
    if (dotRV < 0.0) {
        // Light reflection in opposite direction as viewer, apply only diffuse
        // component
        return lightIntensity * (k_d * dotLN);
    }
    return lightIntensity * (k_d * dotLN + k_s * pow(dotRV, alpha));
}

// ------------------------------------------
// Input: vec3 k_a: Ambient reflection coefficient
//        vec3 k_d: Diffuse reflection coefficient
//        vec3 k_s: Specular reflection coefficient
//        float alpha: Shininess coefficient
//        vec3 p: Point on the surface
//        vec3 eye: Camera or observer position
// Output: Final lighting color
// Description: Calculates the lighting contribution from multiple light sources and ambient light on the surface of an object. 
//              This function supports dynamic light sources, with light positions updated over time using iTime.
// ------------------------------------------
vec3 phongIllumination(vec3 k_a, vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye) {
    const vec3 ambientLight = 0.5 * vec3(1.0, 1.0, 1.0);
    vec3 color = ambientLight * k_a;
    
    vec3 light1Pos = vec3(4.0 * sin(iTime),
                          2.0,
                          4.0 * cos(iTime));
    vec3 light1Intensity = vec3(0.4, 0.4, 0.4);
    
    color += phongContribForLight(k_d, k_s, alpha, p, eye,
                                  light1Pos,
                                  light1Intensity);
    
    vec3 light2Pos = vec3(2.0 * sin(0.37 * iTime),
                          2.0 * cos(0.37 * iTime),
                          2.0);
    vec3 light2Intensity = vec3(0.4, 0.4, 0.4);
    
    color += phongContribForLight(k_d, k_s, alpha, p, eye,
                                  light2Pos,
                                  light2Intensity);    
    return color;
}
