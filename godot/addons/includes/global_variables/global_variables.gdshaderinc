// res://addons/includes/global_variables.gdshaderinc

// Max object count constant
const int MAX_OBJECTS = 25;

// light position
uniform vec3 lightPosition;

// Specular + shading
uniform vec3 specularColorFloat[MAX_OBJECTS];
uniform float specularStrengthFloat[MAX_OBJECTS];
uniform float shininessFloat[MAX_OBJECTS];

// Misc
uniform vec2 screen_resolution;
uniform int inputCount;
uniform int obj_noise[MAX_OBJECTS];
// Optional extensions
// uniform float u_time;
// uniform vec2 u_mouse;
// uniform float u_GammaCorrect;
uniform int is_animated[MAX_OBJECTS]; // 1 = true, 0 = false

//CAMERA
// NEW: Camera control uniforms
uniform int camera_mode1; // 0=MOUSE_CONTROL, 1=AUTO_ORBIT, 2=STATIC_CAMERA
uniform int camera_mode2;
uniform int terrain_mode;
uniform int color_mode;
uniform int animation_mode;


// Maximum number of objects
const float F_NO_OF_SEGMENTS=11.0;
const int NO_OF_SEGMENTS=11;

// SDF Type Constants
const int TYPE_SPHERE = 0;
const int TYPE_ROUNDED_BOX = 1;
const int TYPE_TORUS = 2;
const int TYPE_DOLPHIN = 3;
const int TYPE_HEX_PRISM=4;
const int TYPE_OCTAHEDRON=5;
const int TYPE_ELLIPSOID=6;


// Flattened arrays for SDF object data
uniform int obj_type[MAX_OBJECTS];
uniform vec3 obj_position[MAX_OBJECTS];
uniform vec3 obj_size[MAX_OBJECTS];
uniform float obj_radius[MAX_OBJECTS];
uniform vec3 obj_color[MAX_OBJECTS];




// Dolphin-specific uniforms
uniform float obj_speed[MAX_OBJECTS];
uniform vec3 obj_direction[MAX_OBJECTS];
uniform float obj_time_offset[MAX_OBJECTS];
uniform float Tme;

// Camera uniforms
uniform vec3 camera_position;
uniform vec3 look_at_position;
uniform vec4 _mousePoint;
uniform vec4 _ScreenParams;

//=============================
// ORIGINAL SDF FUNCTIONS
//=============================
//===============WATER SHADER======================

// WATER SHADER - Godot GDScript Shader Include
// Compatible with existing uniform structure

// Read-only constants and uniforms
uniform sampler2D MainTex;
uniform vec2 _Resolution;
uniform vec2 iResolution;
uniform vec2 _Mouse;
//uniform vec3 camera_position;

// Camera mode constants
const int MOUSE_CONTROL = 0;
const int AUTO_ORBIT = 1;
const int STATIC_CAMERA = 2;
const int BACKANDFORTH=3;
const int SHAKE=4;

//SDF Animations
uniform float movement_speed;
uniform float shake_intensity;
uniform float shake_speed;
uniform vec3 orbit_axis;
uniform float orbit_speed;
uniform float cycle_speed;
uniform float wave_speed;

const int NONE = 0;
const int WATER = 1;
const int DESERT = 2;

const int STATIC=0;
const int CYCLE_COLOR=1;
const int WAVE_COLOR=2;

const int NO_ANIMATION=0;
const int PULSE_ANIMATION=1;
