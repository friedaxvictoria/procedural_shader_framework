// structure for SDF functions
struct SDF {
    int   type;       // 0 for sphere, 1 for round box, 2 for torus
    vec3  position;  // position of the shape in world space
    vec3  size;      // for round box this is the size of the box, for torus this is the major radius and minor radius
    float radius;   // For sphere this is the radius, for round box, this is the corner radius
    vec3 color;
};

// Evaluate the signed distance function for a given SDF shape
float evalSDF(SDF s, vec3 p) {
    if (s.type == 0) {
        return sdSphere((p - s.position), s.radius);
    } else if (s.type == 1) {
        return sdRoundBox(p - s.position, s.size, s.radius);
    }
    else if(s.type == 2)
    return sdTorus(p - s.position, s.size.yz);

    return 1e5;
}
// Evaluate the scene by checking all SDF shapes
float evaluateScene(vec3 p) {
    float d = 1e5;
    int bestID = -1;
    for (int i = 0; i < 10; ++i) {
        float di = evalSDF(sdfArray[i], p);
        if(di < d)
        {
            d = di; // Update the closest distance
            bestID = i; // Update the closest hit ID
        }
    }
    
           // Check all dolphins
    for (int i = 0; i < DOLPHIN_COUNT; ++i) {
        float di = dolphinDistance(p, dolphins[i], time).x;
        if(di < d) {
            d = di;
            bestID = 10 + i; // Use IDs >= 10 for dolphins
        }
    }
    
    gHitID = bestID;  // Store the ID of the closest hit shape
    return d;
}
// Estimate normal by central differences
vec3 SDFsNormal(vec3 p) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    return normalize(
        k.xyy * evaluateScene(p + k.xyy * h) +
        k.yyx * evaluateScene(p + k.yyx * h) +
        k.yxy * evaluateScene(p + k.yxy * h) +
        k.xxx * evaluateScene(p + k.xxx * h)
    );
}

// Raymarching function
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;     // Current point in the ray
        float noise;
        fbmPseudo3D(p, 1, noise);    // here you can replace fbmPseudo3D with fbm_n31 for different noise
        float d = evaluateScene(p) + noise*0.3; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }
    return -1.0; // No hit
}
// Evaluate the signed distance function for a given SDF shape
float evalSDF(SDF s, vec3 p) {
    if (s.type == 0) {
        return sdSphere((p - s.position), s.radius);
    } else if (s.type == 1) {
        return sdRoundBox(p - s.position, s.size, s.radius);
    }
    else if(s.type == 2)
    return sdTorus(p - s.position, s.size.yz);

    return 1e5;
}
// Evaluate the scene by checking all SDF shapes
float evaluateScene(vec3 p) {
    float d = 1e5;
    int bestID = -1;
    for (int i = 0; i < 10; ++i) {
        float di = evalSDF(sdfArray[i], p);
        if(di < d)
        {
            d = di; // Update the closest distance
            bestID = i; // Update the closest hit ID
        }
    }
    
           // Check all dolphins
    for (int i = 0; i < DOLPHIN_COUNT; ++i) {
        float di = dolphinDistance(p, dolphins[i], time).x;
        if(di < d) {
            d = di;
            bestID = 10 + i; // Use IDs >= 10 for dolphins
        }
    }
    
    gHitID = bestID;  // Store the ID of the closest hit shape
    return d;
}
// Estimate normal by central differences
vec3 SDFsNormal(vec3 p) {
    float h = 0.0001;
    vec2 k = vec2(1, -1);
    return normalize(
        k.xyy * evaluateScene(p + k.xyy * h) +
        k.yyx * evaluateScene(p + k.yyx * h) +
        k.yxy * evaluateScene(p + k.yxy * h) +
        k.xxx * evaluateScene(p + k.xxx * h)
    );
}

// Raymarching function
float raymarch(vec3 ro, vec3 rd, out vec3 hitPos) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;     // Current point in the ray
        float noise;
        fbmPseudo3D(p, 1, noise);    // here you can replace fbmPseudo3D with fbm_n31 for different noise
        float d = evaluateScene(p) + noise*0.3; // Evaluate the scene SDF at the current point, add noise
        if (d < 0.001) {
            hitPos = p;
            return t;
        }
        if (t > 50.0) break;
        t += d;
    }
    return -1.0; // No hit
}
