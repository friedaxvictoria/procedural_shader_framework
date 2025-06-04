// ==========================================
// Module: Volumetric Phase Functions
// Category: Volumetric Lighting
// Description: 
//   Provides a collection of common phase functions used in volumetric 
//   rendering to model light scattering behavior. Each function describes 
//   the angular distribution of scattered light based on view and light 
//   directions.
//
// Included Functions:
//   - Isotropic Phase Function
//   - Henyey-Greenstein Phase Function
//   - Schlick Approximation (HG fast approximation)
//   - Rayleigh Phase Function (for atmospheric scattering)
//   - Mie Phase Function (approximated using HG)
//
// Usage:
//   These functions return scalar weights to modulate scattering intensity
//   and should be multiplied by the incoming light radiance to compute
//   the final scattering contribution at a sample point.
// ==========================================

// ------------------------------------------------------
// Isotropic Phase Function
// Description: Models uniform scattering in all directions.
// Use: Simple fog or neutral volumes with no directional bias.
// Pros: Fast, simple, physically valid.
// Cons: Cannot simulate directional or forward scattering.
// ------------------------------------------------------
float computePhaseIsotropic() {
    return 1.0 / (4.0 * PI);
}

// ------------------------------------------------------
// Henyey-Greenstein Phase Function
// Description: Models anisotropic scattering based on a 
//   single anisotropy parameter g ¡Ê [-1, 1].
// Use: Natural media like clouds, fog, flame, and smoke.
// Pros: Widely used, physically plausible, tunable directionality.
// Cons: Slightly more expensive than isotropic.
// ------------------------------------------------------
float computePhaseHG(float cosTheta, float g) {
    float g2 = g * g;
    float denom = 1.0 + g2 - 2.0 * g * cosTheta;
    return (1.0 - g2) / (4.0 * PI * pow(denom, 1.5));
}

// ------------------------------------------------------
// Schlick Phase Function (Approximate HG)
// Description: Fast approximation of HG phase function.
// Use: Real-time engines or when performance is critical.
// Pros: Cheaper than HG, reasonable approximation for g ¡Ê [0, 0.8].
// Cons: Less accurate at extreme anisotropy values.
// ------------------------------------------------------
float computePhaseSchlick(float cosTheta, float g) {
    float k = 1.55 * g - 0.55 * pow(g, 3.0);
    float denom = 1.0 + k * cosTheta;
    return (1.0 - k * k) / (4.0 * PI * denom * denom);
}

// ------------------------------------------------------
// Rayleigh Phase Function
// Description: Models scattering of very small particles 
//   (e.g. air molecules) producing blue sky and atmospheric glow.
// Use: Sky, atmosphere, sunlight scattering.
// Pros: Accurate for atmospheric effects.
// Cons: Not suitable for large particles or dense media.
// ------------------------------------------------------
float computePhaseRayleigh(float cosTheta) {
    return (3.0 / (16.0 * PI)) * (1.0 + cosTheta * cosTheta);
}

// ------------------------------------------------------
// Mie Phase Function (HG Approximation)
// Description: Simulates scattering by larger particles like 
//   smoke, dust, or mist using HG as an approximation.
// Use: Thick media where forward scattering dominates.
// Pros: Tunable, integrates well with other HG-based media.
// Cons: Not a true Mie computation, but generally sufficient.
// ------------------------------------------------------
float computePhaseMie(float cosTheta, float g) {
    return computePhaseHG(cosTheta, g);
}

