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