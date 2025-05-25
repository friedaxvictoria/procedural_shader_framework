struct SDF {
    int type;
    vec3 position;
    vec3 size;
    float radius;
};

SDF sdfArray[10];

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}


float evalSDF(SDF s, vec3 p) {
    if (s.type == 0) {
        return length(p - s.position) - s.radius;
    } else if (s.type == 1) {
        return sdRoundBox(p - s.position, s.size, s.radius);
    }
    return 1e5;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}


float evaluateScene(vec3 p) {
    float d = 1e5;
    for (int i = 0; i < 10; ++i) {
        d = min(d, evalSDF(sdfArray[i], p));
    }
    return d;
}

// Signed distance to scene (only one object for now)
float map(vec3 p) {
    return evaluateScene(p); // Sphere radius = 1.0
}

// Estimate normal by central differences
vec3 getNormal(vec3 p) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    return normalize(
        k.xyy * map(p + k.xyy * h) +
        k.yyx * map(p + k.yyx * h) +
        k.yxy * map(p + k.yxy * h) +
        k.xxx * map(p + k.xxx * h)
    );
}

// Basic lighting
vec3 getLighting(vec3 p, vec3 eye) {
    vec3 lightDir = normalize(vec3(0.0, 0.0, 0.3));
    vec3 normal = getNormal(p);
    float diff = clamp(dot(normal, lightDir), 0.0, 1.0);
    vec3 color = vec3(0.4, 0.7, 1.0) * diff;
    return color;
}

// Raymarching function
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float d = map(p);
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }
    return -1.0; // No hit
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    SDF circle = SDF(0, vec3(0.0), vec3(0.0), 1.0);
    SDF roundBox = SDF(1, vec3(1.2,0.0,0.0), vec3(1.0,1.0,1.0), 0.2);
    SDF roundBox2 = SDF(1, vec3(-1.7,0.0,0.0), vec3(1.0,1.0,1.0), 0.2);
    sdfArray[0] = circle;
    sdfArray[1] = roundBox;
    sdfArray[2] = roundBox2;

    vec3 ro = vec3(0, 0, 3);         // Ray origin
    vec3 rd = normalize(vec3(uv, -1)); // Ray direction

    vec3 hitPos;
    float t = raymarch(ro, rd, hitPos);

    vec3 color;
    if (t > 0.0) {
        color = getLighting(hitPos, ro);
    } else {
        color = vec3(0.0); // Background
    }

    fragColor = vec4(color, 1.0);
}
