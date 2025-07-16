// ==========================================
// Shader: SDF Rock Raymarch Shader
// Category: Geometry
// Description: 
//   Implements a procedural rock shape using SDF (Signed Distance Field) and
//   raymarching rendering technique. Includes noise-based perturbation for realism,
//   rotation transformation, surface normal estimation, and basic diffuse shading.
//   Supports multiple SDF shapes stored in arrays for extensibility.
// Screenshots: shaders/screenshots/geometry/SDF_Rock.png
// ==========================================

/**
 * Section: Global Storage
 * Description: Arrays for storing SDF shape properties and material attributes.
 */
int _sdfTypeFloat[10];
vec3 _sdfPositionFloat[10];
vec3 _sdfSizeFloat[10];
float _sdfRadiusFloat[10];
mat3 _sdfRotation[10];
float _sdfNoise[10];

vec3 _baseColorFloat[10];
vec3 _specularColorFloat[10];
float _specularStrengthFloat[10];
float _shininessFloat[10];

/**
 * Function: sdBox
 * Description: Signed distance to an axis-aligned box centered at the origin.
 * Input:
 *   - p (vec3): Point in local space
 *   - b (vec3): Half-size along each axis
 * Output:
 *   - float: Signed distance
 */
// new function for rock sdf
// Signed distance to an axis-aligned box centered at origin
float sdBox(vec3 p, vec3 b) {
    // p: point in local space
    // b: half-size in x/y/z directions
    vec3 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}
//noise function from simplex_noise.glsl
vec4 mod289(vec4 x) { 
    return x - floor(x * (1.0 / 289.0)) * 289.0; 
}

vec3 mod289(vec3 x) { 
    return x - floor(x * (1.0 / 289.0)) * 289.0; 
}

vec4 permute(vec4 x) { 
    return mod289(((x * 34.0) + 1.0) * x); 
}
float snoise(vec3 v) {
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

    vec3 i = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);

    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    i = mod289(i);
    vec4 p = permute(permute(permute(
        i.z + vec4(0.0, i1.z, i2.z, 1.0))
        + i.y + vec4(0.0, i1.y, i2.y, 1.0))
        + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);

    vec4 x = x_ * ns.x + ns.yyyy;
    vec4 y = y_ * ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);

    vec4 norm = 1.79284291400159 - 0.85373472095314 *
        vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    vec4 m = max(0.6 - vec4(
        dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m * m, vec4(
        dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

/**
 * Function: addRock_float
 * Description: Adds a new rock SDF primitive at the specified index with rotation and noise.
 * Input:
 *   - position (vec3): Center of rock
 *   - size (vec3): Half-size of the box
 *   - index (float): Shape index to write to
 *   - axis (vec3): Rotation axis
 *   - angle (float): Rotation angle in degrees
 *   - baseColorIn (vec3): Diffuse base color
 *   - specularColorIn (vec3): Specular highlight color
 *   - specularStrengthIn (float): Specular coefficient
 *   - shininessIn (float): Shininess factor
 *   - noiseIn (float): Strength of noise-based deformation
 *   - indexOut (out float): Output index for next available slot
 */
void addRock_float(vec3 position, vec3 size, float index, vec3 axis, float angle,
                   vec3 baseColorIn, vec3 specularColorIn, float specularStrengthIn,
                   float shininessIn, float noiseIn, out float indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (float(i) == index)
        {
            _sdfTypeFloat[i] = 7;
            _sdfPositionFloat[i] = position;
            _sdfSizeFloat[i] = size;
            _sdfRadiusFloat[i] = 0.0;

            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;

            vec3 u = normalize(axis);
            float rad = radians(angle);
            float c = cos(rad);
            float s = sin(rad);

            _sdfRotation[i] = mat3(
                c + (1.0 - c) * u.x * u.x,
                (1.0 - c) * u.x * u.y - s * u.z,
                (1.0 - c) * u.x * u.z + s * u.y,

                (1.0 - c) * u.y * u.x + s * u.z,
                c + (1.0 - c) * u.y * u.y,
                (1.0 - c) * u.y * u.z - s * u.x,

                (1.0 - c) * u.z * u.x - s * u.y,
                (1.0 - c) * u.z * u.y + s * u.x,
                c + (1.0 - c) * u.z * u.z
            );

            _sdfNoise[i] = noiseIn;
            break;
        }
    }

    indexOut = index + 1.0;
}

/**
 * Function: evalSDF
 * Description: Evaluates the signed distance to the shape at index i.
 * Input:
 *   - i (int): Shape index
 *   - p (vec3): Point in world space
 * Output:
 *   - float: Signed distance
 */
// Evaluate the signed distance function for a given SDF shape
float evalSDF(int i, vec3 p)
{
    int sdfType = _sdfTypeFloat[i];

    // Transform world-space point into object local space
    vec3 probePt = transpose(_sdfRotation[i]) * (p - _sdfPositionFloat[i]);

    if (sdfType == 7){
        float base = sdBox(probePt, _sdfSizeFloat[i]);
        float noise = snoise(probePt * 5.0) * 0.1;
        return base - noise * _sdfNoise[i];
    }
        

    return 1e5; // Default: far away
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float index = 0.0;

    addRock_float(
        vec3(0.0, 0.0, -2.5),      // position
        vec3(0.4, 0.3, 0.5),       // size
        index,
        vec3(0.0, 1.0, 0.0),       // rotation axis
        30.0,                      // angle in degrees
        vec3(0.67, 0.52, 0.35),       // base color
        vec3(0.1),                 // specular color
        0.2,                       // specular strength
        16.0,                      // shininess
        0.3,                       // noise amount
        index                      // output new index
    );

    // Just visualize as distance field:
    vec3 rayOrigin = vec3(0.0, 0.0, 2.0);
    vec3 rayDir = normalize(vec3(uv, -1.0));

    float t = 0.0;
    float dist;
    int hitID = -1;

    for (int step = 0; step < 100; step++) {
        vec3 p = rayOrigin + t * rayDir;
        dist = 1e5;

        for (int i = 0; i < 10; i++) {
            if (_sdfTypeFloat[i] == 7) {
                float d = evalSDF(i, p);
                if (d < dist) {
                    dist = d;
                    hitID = i;
                }
            }
        }

        if (dist < 0.001) break;
        t += dist;
        if (t > 10.0) break;
    }

    if (t < 10.0) {
        vec3 hitPoint = rayOrigin + t * rayDir;

        // Normal estimation by central difference
        float eps = 0.001;
        vec3 n;
        vec2 e = vec2(1.0, -1.0) * 0.5773;
        n = normalize(
            e.xyy * evalSDF(hitID, hitPoint + e.xyy * eps) +
            e.yyx * evalSDF(hitID, hitPoint + e.yyx * eps) +
            e.yxy * evalSDF(hitID, hitPoint + e.yxy * eps) +
            e.xxx * evalSDF(hitID, hitPoint + e.xxx * eps)
        );

        // Lambert lighting from one direction
        vec3 lightDir = normalize(vec3(0.6, 1.0, 0.5));
        float diff = max(dot(n, lightDir), 0.0);

        // Apply diffuse light to base color
        vec3 color = _baseColorFloat[hitID] * diff;

        fragColor = vec4(color, 1.0);
    } else {
        fragColor = vec4(0.0); // background
    }
}
