// ==========================================
// Module: Material Lookup by Geometry ID
// Category: Material
// Description:
//   Forwards geometry hit ID and UV information to the centralized
//   material library for retrieval of the appropriate preset.
//   Keeps scene-specific lookup logic separate from material construction.
//
// Dependencies:
//   - struct Hit { float d; int id; vec3 uv; }
//   - getMaterialByID(int, vec3) (from material_library.glsl)
// Output:
//   - MaterialParams: Fully initialized material struct for surface shading
// ==========================================

MaterialParams getMaterialFromHit(Hit h) {
    return getMaterialByID(h.id, h.uv);
}
