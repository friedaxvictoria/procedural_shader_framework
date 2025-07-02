// File: addons/includes/camera/advanced_sdf_camera.gdshaderinc
// Advanced SDF shader adapted for camera integration
// Based on shader team's advanced implementation with lighting, rotation, and multiple primitives

#ifndef ADVANCED_SDF_CAMERA_INCLUDED
#define ADVANCED_SDF_CAMERA_INCLUDED

// Camera uniforms provided by camera_shader_controller.gd:
// uniform vec3 u_camera_position;
// uniform vec3 u_camera_direction;

#define PI 3.1415926535

// ===== UTILITY FUNCTIONS =====

// Rotation matrix
mat2 rot(float a) {
    float ca = cos(a);
    float sa = sin(a);
    return mat2(vec2(ca, sa), vec2(-sa, ca));
}

// ===== SDF PRIMITIVES =====

// Sphere SDF
float sphere(vec3 pos, vec3 center, float radius) {
    return length(pos - center) - radius;
}

// Box SDF
float box(vec3 p, vec3 center, vec3 size) {
    vec3 ap = abs(p - center) - size;
    return length(max(vec3(0.0), ap)) + min(0.0, max(ap.x, max(ap.y, ap.z)));
}

// ===== SCENE DEFINITION =====

float SDF(vec3 p, float time_factor, bool enable_rotation) {
    vec3 original_p = p;

    // Apply rotation if enabled
    if (enable_rotation) {
        p.xy *= rot(time_factor * 0.7);
        p.yz *= rot(time_factor);
    }

    // You can switch between primitives here
    // return box(p, vec3(0.0), vec3(1.0));
    return sphere(p, vec3(0.0), 0.5);
}

// ===== RAY MARCHING =====

float rayMarch(vec3 cam, vec3 dir, float time_factor, bool enable_rotation) {
    float md = 0.0;
    vec3 pos;

    // Raymarching loop
    for (int i = 0; i < 100; ++i) {
        pos = cam + dir * md;

        float dist = SDF(pos, time_factor, enable_rotation);
        if (dist < 0.001) {
            return md;
        }
        md += dist;
        if (md > 100.0) {
            return 100.0;
        }
    }
    return 100.0;
}

// ===== NORMAL CALCULATION =====

vec3 getNormal(vec3 p, float time_factor, bool enable_rotation) {
    vec2 e = vec2(0.001, 0.0);
    float dx, dy, dz;
    dx = SDF(p, time_factor, enable_rotation) - SDF(p - e.xyy, time_factor, enable_rotation);
    dy = SDF(p, time_factor, enable_rotation) - SDF(p - e.yxy, time_factor, enable_rotation);
    dz = SDF(p, time_factor, enable_rotation) - SDF(p - e.yyx, time_factor, enable_rotation);
    return normalize(vec3(dx, dy, dz));
}

// ===== ADVANCED LIGHTING =====

// Fresnel calculation
vec3 fresnel(in vec3 f0, in float product) {
    return mix(f0, vec3(1.0), pow(1.0 - product, 5.0));
}

// Light calculation with fresnel
vec3 lightCalculation(vec3 diffuse_color, vec3 specular_color, float alpha, vec3 surface_pos, vec3 cam_pos, vec3 light_pos, float time_factor, bool enable_rotation) {
    vec3 N = getNormal(surface_pos, time_factor, enable_rotation); // Normal
    vec3 L = normalize(light_pos - surface_pos); // Light direction
    vec3 R = normalize(reflect(-L, N)); // Reflect vector
    vec3 C = normalize(cam_pos - surface_pos); // View vector

    float NdL = clamp(dot(N, L), 0.0, 1.0);
    float RdC = clamp(dot(R, C), 0.0, 1.0);

    // Calculate fresnel
    vec3 H = normalize(L + C);
    float HdC = dot(H, C);
    vec3 fresnel_factor = fresnel(vec3(0.2), HdC);

    // Apply fresnel to lighting
    vec3 diffuse = NdL * diffuse_color * (1.0 - fresnel_factor);
    vec3 specular = pow(RdC, alpha) * specular_color * fresnel_factor;

    return diffuse + specular;
}

// Complete lighting system
vec3 calculateLighting(vec3 ambient_color, vec3 diffuse_color, vec3 specular_color, float shininess, vec3 surface_pos, vec3 cam_pos, float time_factor, bool enable_rotation) {
    vec3 color = ambient_color * 0.2;

    // Primary light
    vec3 light_position = vec3(10.0, 10.0, 10.0);
    color += lightCalculation(diffuse_color, specular_color, shininess, surface_pos, cam_pos, light_position, time_factor, enable_rotation);

    return color;
}

// ===== CAMERA INTEGRATION =====

// Create camera ray using camera controller data (passed as parameters)
vec3 createAdvancedCameraRay(vec2 uv, vec3 camera_position, vec3 camera_direction, bool enable_camera_rotation, float time_factor) {
    vec3 camera_forward = normalize(camera_direction);
    vec3 camera_right = normalize(cross(vec3(0.0, 1.0, 0.0), camera_forward));
    vec3 camera_up = cross(camera_forward, camera_right);

    // Create base ray direction
    vec3 ray_dir = normalize(camera_forward + uv.x * camera_right + uv.y * camera_up);

    // Apply camera rotation if enabled (like original shader)
    if (enable_camera_rotation) {
        ray_dir.xy *= rot(time_factor);
    }

    return ray_dir;
}

// Get camera position with optional rotation
vec3 getAdvancedCameraPosition(vec3 camera_position, bool enable_camera_rotation, float time_factor) {
    vec3 cam_pos = camera_position;

    // Apply camera rotation if enabled
    if (enable_camera_rotation) {
        cam_pos.xy *= rot(time_factor);
    }

    return cam_pos;
}

// ===== MAIN RENDERING FUNCTION =====

vec4 renderAdvancedSDF(vec2 fragCoord, vec2 resolution, vec3 camera_position, vec3 camera_direction, float time_factor, bool enable_rotation, bool enable_camera_rotation, vec3 background_color) {
    // Normalize coordinates
    vec2 coord = fragCoord / resolution;
    coord = coord * 2.0 - 1.0;
    coord.x *= resolution.x / resolution.y;

    // Setup camera
    vec3 cam_pos = getAdvancedCameraPosition(camera_position, enable_camera_rotation, time_factor);
    vec3 ray_dir = createAdvancedCameraRay(coord, camera_position, camera_direction, enable_camera_rotation, time_factor);

    // Perform raymarching
    float dist = rayMarch(cam_pos, ray_dir, time_factor, enable_rotation);

    vec3 color;

    // Check if ray hit something
    if (dist > 99.0) {  // Use literal instead of MAX_DIST - EPS
        // Background
        color = background_color;
    } else {
        // Hit surface - calculate lighting
        vec3 surface_pos = cam_pos + ray_dir * dist;

        // Lighting parameters
        vec3 ambient = background_color;
        vec3 diffuse = vec3(1.0);
        vec3 specular = vec3(1.0);
        float shininess = 100.0;

        color = calculateLighting(ambient, diffuse, specular, shininess, surface_pos, cam_pos, time_factor, enable_rotation);
    }

    return vec4(color, 1.0);
}

// ===== SIMPLIFIED RENDER FUNCTIONS =====

// Simple version with default settings
vec4 renderAdvancedSDFSimple(vec2 fragCoord, vec2 resolution, vec3 camera_position, vec3 camera_direction, float time_factor) {
    return renderAdvancedSDF(fragCoord, resolution, camera_position, camera_direction, time_factor, true, false, vec3(0.25, 0.25, 0.25));
}

// Version with camera rotation (like original shader)
vec4 renderAdvancedSDFWithCameraRotation(vec2 fragCoord, vec2 resolution, vec3 camera_position, vec3 camera_direction, float time_factor) {
    return renderAdvancedSDF(fragCoord, resolution, camera_position, camera_direction, time_factor, true, true, vec3(0.25, 0.25, 0.25));
}

#endif // ADVANCED_SDF_CAMERA_INCLUDED