<div class="container">
    <h1 class="main-heading">Sunrise Shader</h1>
    <blockquote class="author">by Saeed Shamseldin</blockquote>
</div>

<img src="../../../static/images/images4Shaders/sunrise.gif" alt="general scene" width="500" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

## Overview

This GLSL shader implements physically-based atmospheric scattering to simulate realistic sunrise lighting effects. It models Rayleigh and Mie scattering phenomena to create the characteristic colors and glow of sunrise/sunset conditions.

## Key Features
- Physically-based atmospheric scattering simulation

- Configurable earth and atmosphere parameters

- Rayleigh scattering (blue sky effect)

- Mie scattering (sun glare and halo effects)

- Time-based sun direction animation

## Constants
- bR: Rayleigh scattering coefficients (per color channel)

- bMs: Mie scattering coefficients

- bMe: Extended Mie coefficients (1.1 × bMs)

## `SunriseLight` Struct
```glsl
struct SunriseLight {
    vec3 sundir;            // Normalized sun direction vector
    vec3 earthCenter;       // Earth center position in meters
    float earthRadius;      // Earth radius in meters (6360km)
    float atmosphereRadius; // Atmosphere radius in meters (6380km)
    float sunIntensity;     // Sun light intensity multiplier
};
```

## Core Functions

**`initSunriseLight(out SunriseLight light, float time)`**

Initializes sunrise lighting parameters with time-based animation.

**Parameters**:

- **`light`**: Output SunriseLight structure

- **`time`**: Animation time value

**`densitiesRM(vec3 p, SunriseLight light)`**

Calculates Rayleigh and Mie density at a point in atmosphere.

**Returns**:
  
  - **`vec2`**: x = Rayleigh density, y = Mie density

**`escape(vec3 p, vec3 d, float R, vec3 earthCenter)`**

Calculates distance to atmosphere boundary along a ray.

**Returns**:

- Distance to boundary or -1 if no intersection

**`scatterDepthInt(vec3 o, vec3 d, float L, float steps, SunriseLight light)`**

Computes integrated scattering depths along a ray segment.

**Returns**:

- **`vec2`**: Integrated Rayleigh and Mie depths

**`scatterIn(vec3 o, vec3 d, float L, float steps, SunriseLight light)`**

Accumulates in-scattering contributions along a view ray.

**`applySunriseLighting(vec3 o, vec3 d, float L, vec3 Lo, SunriseLight light)`**

Main function to apply sunrise lighting to a scene.

Parameters:

- **`o`**: Ray origin (camera position)

- **`d`**: Ray direction (normalized)

- **`L`**: Ray length

- **`Lo`**: Original scene color

- **`light`**: SunriseLight parameters

**Returns**:

- Final lit color with atmospheric effects

## Technical Details

### Scattering Models

- **Rayleigh scattering**: Simulates shorter wavelength (blue) light scattering

- **Mie scattering**: Simulates longer wavelength (red/orange) light scattering and glare

### Atmospheric Model

- Exponential density falloff with altitude

- 8km scale height for Rayleigh scattering

- 1.2km scale height for Mie scattering


<details>
<summary>Show Code</summary>
```glsl
// Global variables for sunrise lighting
vec2 totalDepthRM;
vec3 I_R, I_M;
const vec3 bR = vec3(58e-7, 135e-7, 331e-7); // Rayleigh scattering coefficient
const vec3 bMs = vec3(2e-5); // Mie scattering coefficients
const vec3 bMe = bMs * 1.1;

struct SunriseLight {
    vec3 sundir;
    vec3 earthCenter;
    float earthRadius;
    float atmosphereRadius;
    float sunIntensity;
};

void initSunriseLight(out SunriseLight light, float time) {
    light.sundir = normalize(vec3(.5, .4 * (1. + sin(.5 * time)), -1.));
    light.earthCenter = vec3(0., -6360e3, 0.);
    light.earthRadius = 6360e3;
    light.atmosphereRadius = 6380e3;
    light.sunIntensity = 10.0;
}

vec2 densitiesRM(vec3 p, SunriseLight light) {
    float h = max(0., length(p - light.earthCenter) - light.earthRadius);
    return vec2(exp(-h/8e3), exp(-h/12e2));
}

float escape(vec3 p, vec3 d, float R, vec3 earthCenter) {
    vec3 v = p - earthCenter;
    float b = dot(v, d);
    float det = b * b - dot(v, v) + R*R;
    if (det < 0.) return -1.;
    det = sqrt(det);
    float t1 = -b - det, t2 = -b + det;
    return (t1 >= 0.) ? t1 : t2;
}

vec2 scatterDepthInt(vec3 o, vec3 d, float L, float steps, SunriseLight light) {
    vec2 depthRMs = vec2(0.);
    L /= steps; d *= L;
    
    for (float i = 0.; i < steps; ++i)
        depthRMs += densitiesRM(o + d * i, light);

    return depthRMs * L;
}

void scatterIn(vec3 o, vec3 d, float L, float steps, SunriseLight light) {
    L /= steps; d *= L;

    for (float i = 0.; i < steps; ++i) {
        vec3 p = o + d * i;
        vec2 dRM = densitiesRM(p, light) * L;
        totalDepthRM += dRM;
        vec2 depthRMsum = totalDepthRM + scatterDepthInt(p, light.sundir, escape(p, light.sundir, light.atmosphereRadius, light.earthCenter), 4., light);
        vec3 A = exp(-bR * depthRMsum.x - bMe * depthRMsum.y);
        I_R += A * dRM.x;
        I_M += A * dRM.y;
    }
}

vec3 applySunriseLighting(vec3 o, vec3 d, float L, vec3 Lo, SunriseLight light) {
    totalDepthRM = vec2(0.);
    I_R = I_M = vec3(0.);
    scatterIn(o, d, L, 16., light);

    float mu = dot(d, light.sundir);
    return Lo + Lo * exp(-bR * totalDepthRM.x - bMe * totalDepthRM.y)
        + light.sunIntensity * (1. + mu * mu) * (
            I_R * bR * .0597 +
            I_M * bMs * .0196 / pow(1.58 - 1.52 * mu, 1.5));
}


```
</details>


## Engine Integrations

<div class="button-row">
  <a class="custom-button md-button" href="../../../../engines/unity/lighting/sunriseLight">Unity</a>
    <a class="custom-button md-button" href="../../../../engines/unreal/lighting/sunriseLight">Unreal</a>
</div>