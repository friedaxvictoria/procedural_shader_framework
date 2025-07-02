// res://addons/includes/global_variables.gdshaderinc

// Max object count constant
const int MAX_OBJECTS = 10;

// Main SDF input arrays
uniform int obj_type[MAX_OBJECTS];
uniform vec3 obj_position[MAX_OBJECTS];
uniform vec3 obj_size[MAX_OBJECTS];
uniform float obj_radius[MAX_OBJECTS];
uniform vec3 obj_color[MAX_OBJECTS];

// Specular + shading
uniform vec3 specularColorFloat[MAX_OBJECTS];
uniform float specularStrengthFloat[MAX_OBJECTS];
uniform float shininessFloat[MAX_OBJECTS];

// Misc
uniform vec2 screen_resolution;
uniform int inputCount;

// Optional extensions
// uniform float u_time;
// uniform vec2 u_mouse;
// uniform float u_GammaCorrect;
uniform int is_animated[MAX_OBJECTS]; // 1 = true, 0 = false
