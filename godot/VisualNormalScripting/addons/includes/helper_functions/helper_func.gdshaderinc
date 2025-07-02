

void lightingContext(vec3 hitPos, vec3 lightPosition, vec3 cameraPos, out vec3 viewDir, out vec3 lightDir, out vec3 lightColor, out vec3 ambientColor)
{
    viewDir = normalize(cameraPos - hitPos); // Use the actual camera position
    lightDir = normalize(lightPosition - hitPos);
    lightColor = vec3(1.0, 1.0, 1.0);
    ambientColor = vec3(0.1, 0.1, 0.1);
}


// Computes a camera basis matrix (right, up, -forward) given eye and target position
mat3 compute_camera_basis(vec3 look_at_pos, vec3 eye) {
    vec3 f = normalize(look_at_pos - eye);            // Forward
    vec3 r = normalize(cross(f, vec3(0.0, 1.0, 0.0))); // Right
    vec3 u = cross(r, f);                              // Up
    return mat3(r, u, -f); // Column-major matrix for camera orientation
}
