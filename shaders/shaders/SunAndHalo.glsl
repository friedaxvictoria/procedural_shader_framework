// ==========================================
// Shader: Sun and halo Shader
// Category: Lighting & Atmospheric Scattering
// Description: Computes a realistic sun appearance with core glow, halo, and atmospheric absorption.
// Screenshot: screenshots/SunAndHalo.png
// ==========================================

/*
 * This module renders a physically inspired sun disk with surrounding halo and atmospheric attenuation.
 * It simulates both the optical core and Mie scattering halo, and applies sky-based absorption and tone mapping.
 *
 * Main Components:
 * - getSunPoint(): Computes the sharp sun disk based on distance to light direction.
 * - getMie(): Models the soft scattering halo around the sun using a falloff function.
 * - getSkyAbsorption(): Simulates atmospheric light absorption based on height.
 * - jodieReinhardTonemap(): Tone mapping function for displaying HDR lighting effects.
 * - getAtmosphericSun(): Full sun color composition using all above components.
 *
 * Inputs:
 *   fragUV     - vec2 : current fragment's UV position (normalized screen space)
 *   lightUV    - vec2 : sun's position on screen (normalized screen space)
 *   fov        - float: field of view angle used in projection (in radians)
 *
 * Output:
 *   vec3 : RGB color of the sun at the given fragment position, tone-mapped and combined
 *          from core glow, halo, and atmospheric absorption
 *
 * Notes:
 * - Assumes input coordinates are normalized in [0,1].
 * - Designed to be used in skybox / background passes.
 * - Halo sharpness adapts to sun elevation for dynamic transition from horizon to zenith.
 */

// ---------- Simple Sun Constants ----------
const float PI = 3.14159265358979323846;
const float density = 0.5;
const float zenithOffset = 0.48;
const vec3 skyColor = vec3(0.37, 0.55, 1.0);  // base sky color

#define zenithDensity(x) density / pow(max(x - zenithOffset, 0.0035), 0.75)
#define fov tan(radians(70.0))  // Field of view

// ---------- Sun Core and Halo ----------
float getSunPoint(vec2 p, vec2 lp) {
    return smoothstep(0.04 * (fov / 2.0), 0.026 * (fov / 2.0), distance(p, lp)) * 50.0;
}

float getMie(vec2 p, vec2 lp) {
    float sharpness = lp.y < 0.5 ? (lp.y + 0.5) * pow(0.05, 20.0) : 0.05;
    float disk = clamp(1.0 - pow(distance(p, lp), sharpness), 0.0, 1.0);
    return disk * disk * (3.0 - 2.0 * disk) * 0.25 * PI;
}

// ---------- Light Absorption ----------
vec3 getSkyAbsorption(vec3 x, float y) {
    vec3 absorption = x * y;
    absorption = pow(absorption, 1.0 - (y + absorption) * 0.5) / x / y;
    return absorption;
}

vec3 jodieReinhardTonemap(vec3 c) {
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
    vec3 tc = c / (c + 1.0);
    return mix(c / (l + 1.0), tc, tc);
}

// ---------- Final Atmospheric Sun Function ----------
vec3 getAtmosphericSun(vec2 fragUV, vec2 lightUV) {
    float zenithFactor = zenithDensity(fragUV.y);
    float sunHeight = clamp(length(max(lightUV.y + 0.1 - zenithOffset, 0.0)), 0.0, 1.0);
    
    vec3 skyAbsorption = getSkyAbsorption(skyColor, zenithFactor);
    vec3 sunAbsorption = getSkyAbsorption(skyColor, zenithDensity(lightUV.y + 0.1));
    
    vec3 sunCore = getSunPoint(fragUV, lightUV) * skyAbsorption;
    vec3 mieHalo = getMie(fragUV, lightUV) * sunAbsorption;
    
    vec3 totalSky = sunCore + mieHalo;
    totalSky *= sunAbsorption * 0.5 + 0.5 * length(sunAbsorption);

    vec3 finalColor = jodieReinhardTonemap(totalSky);
    return finalColor;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Aspect ratio and scale factor
    float AR = iResolution.x / iResolution.y;
    float M = 1.0;

    // Mouse-based sun position, with fallback
    vec2 uvMouse = iMouse.xy / iResolution.xy;
    uvMouse.x *= AR;
    if (uvMouse.y == 0.0) uvMouse.y = 0.7 - (0.05 * fov);
    if (uvMouse.x == 0.0) uvMouse.x = 1.0 - (0.05 * fov);

    // Screen UV coordinates
    vec2 uv1 = fragCoord.xy / iResolution.xy;
    uv1 *= M;
    uv1.x *= AR;

    // Initialize color with atmospheric base background
    vec3 color = vec3(0.2, 0.3, 0.5) * (1.0 - uv1.y);  // Simple vertical gradient

    // Add sun glow
    vec3 sunColor = getAtmosphericSun(uv1, uvMouse);
    color += sunColor;

    // Output with gamma correction
    fragColor = vec4(pow(color, vec3(1.0 / 2.2)), 1.0);
}
