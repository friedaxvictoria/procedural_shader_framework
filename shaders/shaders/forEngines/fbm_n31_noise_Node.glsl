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