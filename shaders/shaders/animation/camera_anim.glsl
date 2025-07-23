// camera_anim.glsl
// Modular camera animation system (SDF-style)
// From Wanzhang He

// ==========================
// === Camera state struct ==
// ==========================
struct CameraState {
    vec3 eye;     // Camera position (origin)
    vec3 target;  // Look-at point
    vec3 up;      // Up direction
};

// ===============================
// === Camera animation config ===
// ===============================
struct CameraAnimParams {
    int mode;         // Animation mode: 0=static, 1=orbit, 2=ping-pong, 3=first-person
    float speed;      // Playback speed
    float offset;     // Time offset
    vec3 center;      // Center point to look at
    float radius;     // Radius for orbiting
};

// ======================================
// === Build camera direction matrix  ===
// ======================================
mat3 get_camera_matrix(CameraState cam) {
    vec3 f = normalize(cam.target - cam.eye);   // Forward direction
    vec3 r = normalize(cross(f, cam.up));       // Right direction
    vec3 u = cross(r, f);                       // Recomputed up
    return mat3(r, u, -f);  // Column-major: [right, up, -forward]
}

// ===================================
// === Main camera animation logic ===
// ===================================
CameraState animate_camera(float time, CameraAnimParams param) {
    CameraState cam;
    float t = time * param.speed + param.offset;

    if (param.mode == 0) {
        // Static camera
        cam.eye = vec3(0.0, 2.0, 5.0);
        cam.target = param.center;
    }
    else if (param.mode == 1) {
        // Orbit around center (Y-axis)
        float angle = t;
        cam.eye = vec3(sin(angle), 1.5, cos(angle)) * param.radius;
        cam.target = param.center;
    }
    else if (param.mode == 2) {
        // Back-and-forth (Z-axis)
        cam.eye = vec3(0.0, 1.5, sin(t) * param.radius + 5.0);
        cam.target = param.center;
    }
    else if (param.mode == 3) {
        // First-person forward movement
        cam.eye = vec3(t * param.radius, 1.0, 0.0);
        cam.target = cam.eye + vec3(0.0, 0.0, -1.0);
    }
    else {
        // Fallback
        cam.eye = vec3(0.0, 1.5, 5.0);
        cam.target = param.center;
    }

    cam.up = vec3(0.0, 1.0, 0.0);
    return cam;
}
