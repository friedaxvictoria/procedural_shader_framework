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