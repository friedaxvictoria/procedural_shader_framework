// ==========================================
// Shader: SDF Cactus Raymarch Shader
// Category: Geometry
// Description: 
//   Procedural cactus generation using signed distance fields (SDF) with 
//   branch modeling, decorative spines, and noise-based surface detail. 
//   Implements SDF evaluation, shape construction, raymarching, normal estimation,
//   and basic diffuse shading.
//   Uses capsule primitives and combines multiple SDF branches to form a cactus.
// Screenshots: shaders/screenshots/geometry/SDF_Cactus.png
// From Wanzhang He
// ==========================================

/**
 * Section: Global SDF Shape Storage
 * Description: Arrays holding up to 10 SDF primitives and their material attributes.
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
 * Function: sdCapsule
 * Description: Computes signed distance from point to vertical capsule.
 * Input:
 *   - p (vec3): Point in local space.
 *   - h (float): Height of capsule.
 *   - r (float): Radius of capsule.
 * Output:
 *   - float: Signed distance value.
 */
// Signed distance to a vertical capsule (used to model cactus body)
float sdCapsule(vec3 p, float h, float r) {
    p.y -= clamp(p.y, 0.0, h); // restrict to cylinder height
    return length(p) - r;      // subtract radius for thickness
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
 * Function: addCactus_float
 * Description: Registers a cactus SDF object into global array at specified index.
 * Input:
 *   - position (vec3): Base position.
 *   - height (float): Height of main stem.
 *   - radius (float): Radius of stem and branches.
 *   - index (float): Index for storing this cactus.
 *   - axis/angle: Orientation in axis-angle form.
 *   - baseColorIn: Diffuse base color.
 *   - specularColorIn: Specular color.
 *   - specularStrengthIn: Specular intensity.
 *   - shininessIn: Shininess for lighting.
 *   - noiseIn: Noise deformation strength.
 * Output:
 *   - indexOut (float): Next available index (index + 1).
 */
// Add a cactus SDF object at given index
void addCactus_float(vec3 position, float height, float radius, float index,
                     vec3 axis, float angle,
                     vec3 baseColorIn, vec3 specularColorIn,
                     float specularStrengthIn, float shininessIn,
                     float noiseIn, out float indexOut)
{
    for (int i = 0; i <= 10; i++)
    {
        if (float(i) == index)
        {
            _sdfTypeFloat[i] = 8; // cactus type ID
            _sdfPositionFloat[i] = position;
            _sdfSizeFloat[i] = vec3(radius, height, 0.0); // x = radius, y = height
            _sdfRadiusFloat[i] = 0.0;

            _baseColorFloat[i] = baseColorIn;
            _specularColorFloat[i] = specularColorIn;
            _specularStrengthFloat[i] = specularStrengthIn;
            _shininessFloat[i] = shininessIn;

            // Build rotation matrix from axis + angle (Rodrigues formula)
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

float sdSphere(vec3 position, float radius)
{
    return length(position) - radius;
}

/**
 * Function: addCactusDecorations
 * Description: Adds decorative spines (small spheres) to cactus body.
 * Input:
 *   - localPos (vec3): Point in local cactus space.
 *   - radius (float): Base radius of cactus.
 * Output:
 *   - colorOut (vec3): Spine color if hit.
 * Return:
 *   - float: Distance to nearest spine.
 */
// Adds spines on cactus body
float addCactusDecorations(vec3 localPos, float radius, out vec3 colorOut) {
    float minDecor = 1e5;
    colorOut = vec3(0.0);

    // Spine color (dark)
    vec3 spineColor = vec3(0.05);

    // Number of spines
    const int spineCount = 4;

    for (int i = 0; i < spineCount; i++) {
        float fy = float(i) / float(spineCount);
        vec3 p = localPos - vec3(0.0, fy, 0.0);
        float d = sdSphere(p, radius * 0.2);
        if (d < minDecor) {
            minDecor = d;
            colorOut = spineColor;
        }
    }

    return minDecor;
}

/**
 * Function: evalCactusSDF
 * Description: Evaluates cactus composed of one vertical stem and two branches.
 * Input:
 *   - i (int): Cactus index.
 *   - p (vec3): World-space point.
 * Output:
 *   - float: Signed distance (with decorations and noise).
 */
float evalCactusSDF(int i, vec3 p)
{
    float h = _sdfSizeFloat[i].y;
    float r = _sdfSizeFloat[i].x;

    // Transform world point to local
    vec3 probePt = transpose(_sdfRotation[i]) * (p - _sdfPositionFloat[i]);

    // Main vertical capsule
    float dMain = sdCapsule(probePt, h, r);

    // Right branch
    vec3 pBranch1 = probePt - vec3(0.2, 0.4, 0.0);
    pBranch1 = vec3(pBranch1.y, pBranch1.x, pBranch1.z);
    float dBranch1 = sdCapsule(pBranch1, 0.5, r * 0.6);

    // Left branch
    vec3 pBranch2 = probePt - vec3(-0.2, 0.4, 0.0);
    pBranch2 = vec3(pBranch2.y, pBranch2.x, pBranch2.z);
    float dBranch2 = sdCapsule(pBranch2, 0.5, r * 0.6);

    // Combine base structure
    float base = min(dMain, min(dBranch1, dBranch2));

    // Add cactus texture noise
    float noise = snoise(probePt * 5.0) * 0.1;
    float baseWithNoise = base - noise * _sdfNoise[i];

    // Add decorations (spines only)
    vec3 decoColor;
    float deco = addCactusDecorations(probePt, r, decoColor);

    return min(baseWithNoise, deco);
}

/**
 * Function: evalSDF
 * Description: Dispatch to shape-specific SDF evaluation function.
 * Input:
 *   - i (int): Shape index.
 *   - p (vec3): World-space point.
 * Output:
 *   - float: Signed distance.
 */
// Evaluate signed distance of all supported SDF types
float evalSDF(int i, vec3 p)
{
    int sdfType = _sdfTypeFloat[i];

    if (sdfType == 8) {
        return evalCactusSDF(i, p);
    }

    return 1e5;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalized screen coordinates
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    float index = 0.0;

    // Add a cactus to the scene
    addCactus_float(
        vec3(0.0, -0.2, -2.2),   // position
        0.8,                     // height
        0.1,                     // radius
        index,
        vec3(1.0, 0.0, 0.0),     // rotation axis
        0.0,                     // rotation angle
        vec3(0.2, 0.5, 0.2),     // base color (green)
        vec3(0.05),              // specular color
        0.2,                     // specular strength
        32.0,                    // shininess
        0.25,                    // noise intensity
        index
    );

    // Ray origin and direction
    vec3 rayOrigin = vec3(0.0, 0.0, 2.0);
    vec3 rayDir = normalize(vec3(uv, -1.0));

    float t = 0.0;
    float dist;
    int hitID = -1;

    // Sphere tracing loop
    for (int step = 0; step < 100; step++) {
        vec3 p = rayOrigin + t * rayDir;
        dist = 1e5;

        for (int i = 0; i < 10; i++) {
            if (_sdfTypeFloat[i] == 8) {
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

    // Shading
    if (t < 10.0) {
        vec3 hitPoint = rayOrigin + t * rayDir;

        // Estimate normal by central differences
        float eps = 0.001;
        vec3 n;
        vec2 e = vec2(1.0, -1.0) * 0.5773;
        n = normalize(
            e.xyy * evalSDF(hitID, hitPoint + e.xyy * eps) +
            e.yyx * evalSDF(hitID, hitPoint + e.yyx * eps) +
            e.yxy * evalSDF(hitID, hitPoint + e.yxy * eps) +
            e.xxx * evalSDF(hitID, hitPoint + e.xxx * eps)
        );

        // Light and shading
        vec3 lightDir = normalize(vec3(0.6, 1.0, 0.5));
        float diff = max(dot(n, lightDir), 0.0);

        vec3 color = _baseColorFloat[hitID] * diff;
        fragColor = vec4(color, 1.0);
    } else {
        fragColor = vec4(0.0); // Background black
    }
}

