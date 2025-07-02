// File: res://addons/includes/dynamic_sdf_system.gdshaderinc
// Truly Dynamic SDF System - Uses function-based parameter passing

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           SDF MODULE                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////

float sdSphere(vec3 position, float radius) {
    return length(position) - radius;
}

float sdRoundBox(vec3 p, vec3 b, float r) {
    vec3 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdTorus(vec3 p, vec2 radius) {
    vec2 q = vec2(length(p.xy) - radius.x, p.z);
    return length(q) - radius.y;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          NOISE MODULE                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////

vec2 GetGradient(vec2 intPos, float t) {
    float rand = fract(sin(dot(intPos, vec2(12.9898, 78.233))) * 43758.5453);
    float angle = 6.283185 * rand + 4.0 * t * rand;
    return vec2(cos(angle), sin(angle));
}

float Pseudo3dNoise(vec3 pos) {
    vec2 i = floor(pos.xy);
    vec2 f = fract(pos.xy);
    vec2 blend = f * f * (3.0 - 2.0 * f);

    float a = dot(GetGradient(i + vec2(0, 0), pos.z), f - vec2(0.0, 0.0));
    float b = dot(GetGradient(i + vec2(1, 0), pos.z), f - vec2(1.0, 0.0));
    float c = dot(GetGradient(i + vec2(0, 1), pos.z), f - vec2(0.0, 1.0));
    float d = dot(GetGradient(i + vec2(1, 1), pos.z), f - vec2(1.0, 1.0));

    float xMix = mix(a, b, blend.x);
    float yMix = mix(c, d, blend.x);
    return mix(xMix, yMix, blend.y) / 0.7;
}

float fbmPseudo3D(vec3 p, int octaves) {
    float result = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; ++i) {
        result += amplitude * Pseudo3dNoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    DYNAMIC PARAMETER SYSTEM                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Global variables to store the current parameters being used
// These will be set by the SDF nodes when they're called
vec3 g_positions[10];
vec3 g_sizes[10];
float g_radii[10];
int g_types[10];
bool g_enabled[10];
int g_param_count;

// Initialize the parameter system
void initDynamicSystem() {
    g_param_count = 0;
    for (int i = 0; i < 10; i++) {
        g_positions[i] = vec3(0.0);
        g_sizes[i] = vec3(0.0);
        g_radii[i] = 0.0;
        g_types[i] = -1;
        g_enabled[i] = false;
    }
}

// Add parameters for a sphere
int addDynamicSphere(vec3 position, float radius, int inputIndex, bool enabled) {
    if (inputIndex >= 0 && inputIndex < 10) {
        g_positions[inputIndex] = position;
        g_radii[inputIndex] = radius;
        g_types[inputIndex] = 0; // sphere
        g_enabled[inputIndex] = enabled;
        g_param_count = max(g_param_count, inputIndex + 1);
    }
    return inputIndex + 1;
}

// Add parameters for a round box
int addDynamicRoundBox(vec3 position, vec3 size, float cornerRadius, int inputIndex, bool enabled) {
    if (inputIndex >= 0 && inputIndex < 10) {
        g_positions[inputIndex] = position;
        g_sizes[inputIndex] = size;
        g_radii[inputIndex] = cornerRadius;
        g_types[inputIndex] = 1; // round box
        g_enabled[inputIndex] = enabled;
        g_param_count = max(g_param_count, inputIndex + 1);
    }
    return inputIndex + 1;
}

// Add parameters for a torus
int addDynamicTorus(vec3 position, float majorRadius, float minorRadius, int inputIndex, bool enabled) {
    if (inputIndex >= 0 && inputIndex < 10) {
        g_positions[inputIndex] = position;
        g_sizes[inputIndex] = vec3(0.0, majorRadius, minorRadius);
        g_radii[inputIndex] = 0.0;
        g_types[inputIndex] = 2; // torus
        g_enabled[inputIndex] = enabled;
        g_param_count = max(g_param_count, inputIndex + 1);
    }
    return inputIndex + 1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        SCENE EVALUATION                                           //
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Evaluate a single SDF object using stored parameters
float evaluateDynamicSDF(int index, vec3 p) {
    if (index < 0 || index >= 10 || !g_enabled[index]) {
        return 1e5;
    }

    vec3 localPos = p - g_positions[index];

    if (g_types[index] == 0) {        // Sphere
        return sdSphere(localPos, g_radii[index]);
    } else if (g_types[index] == 1) { // Round box
        return sdRoundBox(localPos, g_sizes[index], g_radii[index]);
    } else if (g_types[index] == 2) { // Torus
        return sdTorus(localPos, g_sizes[index].yz);
    }

    return 1e5;
}

// Evaluate the full dynamic scene
float evaluateDynamicScene(vec3 p, int objectCount, out int hitID) {
    float d = 1e5;
    int bestID = -1;

    // Check all active objects up to objectCount
    for (int i = 0; i < min(objectCount, g_param_count); i++) {
        if (g_enabled[i]) {
            float di = evaluateDynamicSDF(i, p);
            if (di < d) {
                d = di;
                bestID = i;
            }
        }
    }

    hitID = bestID;
    return d;
}

// Calculate normal using dynamic scene
vec3 getDynamicNormal(vec3 p, int objectCount) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    int dummy;
    return normalize(
        k.xyy * evaluateDynamicScene(p + k.xyy * h, objectCount, dummy) +
        k.yyx * evaluateDynamicScene(p + k.yyx * h, objectCount, dummy) +
        k.yxy * evaluateDynamicScene(p + k.yxy * h, objectCount, dummy) +
        k.xxx * evaluateDynamicScene(p + k.xxx * h, objectCount, dummy)
    );
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           RAYMARCHING                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Dynamic raymarching function
float dynamicRaymarch(vec3 ro, vec3 rd, int objectCount, out vec3 hitPos, out int hitID) {
    float t = 0.0;
    hitID = -1;

    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float noise = fbmPseudo3D(p, 1);
        float d = evaluateDynamicScene(p, objectCount, hitID) + noise * 0.3;

        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }

    hitID = -1;
    return -1.0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    NODE INTERFACE FUNCTIONS                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////

// These functions will be called by the visual shader nodes
// They store parameters in the global arrays for later use

int addSphereNode(vec3 position, float radius, int inputIndex, bool enabled) {
    if (inputIndex == 0) {
        initDynamicSystem();
    }
    return addDynamicSphere(position, radius, inputIndex, enabled);
}

int addRoundBoxNode(vec3 position, vec3 size, float cornerRadius, int inputIndex, bool enabled) {
    if (inputIndex == 0) {
        initDynamicSystem();
    }
    return addDynamicRoundBox(position, size, cornerRadius, inputIndex, enabled);
}

int addTorusNode(vec3 position, float majorRadius, float minorRadius, int inputIndex, bool enabled) {
    if (inputIndex == 0) {
        initDynamicSystem();
    }
    return addDynamicTorus(position, majorRadius, minorRadius, inputIndex, enabled);
}
