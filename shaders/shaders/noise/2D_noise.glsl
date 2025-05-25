// ==========================================
// Shader: Procedural Noise with FBM
// Category: Noise Generation
// Description: Generates smooth procedural textures using hash-based noise and fractal Brownian motion (FBM).
// Screenshot: screenshots/noise/2d noise.png
// ==========================================

/*
 * This shader creates procedural textures by implementing hash-based value noise 
 * and combining multiple octaves of it using fractal Brownian motion (FBM).
 * 
 * It visualizes the result as a dynamic, colorful field that evolves over time.
 *
 * Main Components:
 * - hash(): 1D and 2D hash functions that return pseudo-random values.
 * - noise(): 1D and 2D smooth interpolated noise based on hash functions.
 * - fbm(): Combines several octaves of noise with decreasing amplitude and increasing frequency.
 *
 * Inputs:
 *   fragCoord  - vec2 : the pixel position in screen space
 *   iResolution - vec2: resolution of the screen
 *   iTime       - float: global shader playback time
 *
 * Output:
 *   fragColor - vec4 : RGB visualization of noise value using color mapping
 *                      with dynamic animation based on time.
 * 
 * Notes:
 * - `NOISE` is a macro set to either `noise` (single octave) or `fbm` (multi-octave).
 * - Uses matrix rotation in FBM to reduce axis-aligned artifacts.
 */

// For multiple octaves
#define NOISE fbm
#define NUM_NOISE_OCTAVES 5

// Precision-adjusted variations of https://www.shadertoy.com/view/4djSRW
float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}


float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    // Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
    vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}


float fbm(float x) {
	float v = 0.0;
	float a = 0.5;
	float shift = float(100);
	for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}


float fbm(vec2 x) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
		v += a * noise(x);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float v = 0.0;
    vec2 coord = fragCoord.xy * 0.1 - vec2(iTime * 5.0, iResolution.y / 2.0);
    v = NOISE(coord);
    // Visualize with a fun color map	
	fragColor.rgb = pow(v, 0.35) * 1.3 * normalize(vec3(0.5, fragCoord.xy / iResolution.xy)) + vec3(v * 0.25);
}
