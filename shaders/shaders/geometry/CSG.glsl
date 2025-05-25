// Shader: CSG Shader
// Category: Geometry
// Description:
//    This module provides common Constructive Solid Geometry (CSG)
//    operations for use in ray marching and signed distance field (SDF)
//    rendering.
//
//    Supported operations:
//      - CSGUnion: standard union (min)
//      - CSGIntersection: standard intersection (max)
//      - CSGDifference: subtraction (object A minus B)
//      - CSGSmoothUnion: smooth blend between two shapes (soft merge)
//
//    These functions take float distance values (from SDF functions)
//    and return a combined distance field according to the CSG logic.
// Usage example:
//    float d1 = SphereSDF(p, center1, radius1);
//    float d2 = BoxSDF(p, center2, size);
//    float d = CSGUnion(d1, d2);
// Screenshot: screenshots/geometry/CSG.pdf
// From Ruimin Ma


// Union: return the closest surface (minimum distance)
float CSGUnion(float d1, float d2) {
    return min(d1, d2);
}

// Intersection: return the overlapping region (maximum distance)
float CSGIntersection(float d1, float d2) {
    return max(d1, d2);
}

// Difference: subtract d2 from d1
float CSGDifference(float d1, float d2) {
    return max(d1, -d2);
}

// Optional: Smooth Union (blended union)
float CSGSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}