// === Global Uniforms for SDF Visual Shader System ===

const int MAX_OBJECTS = 10;

// === Geometry Parameters (used in AddSphereNode.gd) ===
uniform int obj_type[MAX_OBJECTS];
uniform vec3 obj_position[MAX_OBJECTS];
uniform vec3 obj_size[MAX_OBJECTS];
uniform float obj_radius[MAX_OBJECTS];

// === Material Parameters (used in SetMaterialParamsNode.gd / AddSphereNode.gd) ===
uniform vec3 u_baseColorFloat[MAX_OBJECTS];
uniform vec3 u_specularColorFloat[MAX_OBJECTS];
uniform float u_specularStrengthFloat[MAX_OBJECTS];
uniform float u_shininessFloat[MAX_OBJECTS];

// === Raymarching Context (used in SDFRaymarchNode.gd) ===
uniform vec3 _rayOrigin; // Typically camera position
uniform vec2 screen_resolution;

// === Scene Control ===
uniform int inputCount = 0; // Actual number of active SDFs

// === Runtime State Variables ===
// === Lighting Parameters ===
uniform vec3 u_lightPosition; // Position of the main light
//=== Animation ===
uniform bool is_animated[MAX_OBJECTS];
