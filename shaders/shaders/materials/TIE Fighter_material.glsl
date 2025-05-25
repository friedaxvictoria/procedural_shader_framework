// Shader: TIE Fighter Material
// Category: Material
// Description:
//   Maps geometry Hit IDs to base colour and specular strength.
//   Uses the value-noise helper n31 (from TIE_Fighter_noise.glsl) to introduce
//   subtle brushed-metal variation on metallic parts.
//
//   External dependencies:
//     struct Hit { float d; int id; vec3 uv; };
//     float n31(vec3 p);                 // from noise module
//
//   Public function:
//     void getMaterial(in  Hit   h,
//                      out vec3  baseColor,
//                      out float specScale);
/* id mapping (as in the original shader):
 *   1 – wing ribs (metal)
 *   2 – solar-panel surface
 *   3 – cockpit glass
 *   5 – window frame
 *   6 – cockpit sphere (metal with glass cut-out)
 *   7 – gun barrels
 *   9 – laser blast (green emissive)
 */
// From Ruimin Ma

#ifndef TF_MATERIAL_GLSL
#define TF_MATERIAL_GLSL

// -------------------------------------------------  Material lookup
void getMaterial(in Hit h,
                 out vec3  baseColor,
                 out float specScale)
{
    specScale = 4.0;            // default: strong, sharp highlight

    if (h.id == 1 || h.id == 6) {
        // Metal: wing ribs (1) and cockpit sphere (6)
        baseColor = vec3(0.30 - n31(h.uv * 18.7) * 0.10);
        specScale = 0.5;

        if (h.id == 6) {
            // Darken the cockpit’s glass cut-outs
            baseColor *= 1.0 - 0.8 *
                         step(abs(atan(h.uv.y, h.uv.z) - 0.8), 0.01);
        }
    }
    else if (h.id == 2) {
        // Solar panels on the wings
        vec3 uv = h.uv;
        if (uv.x < uv.y * 0.7) uv.y = 0.0;          // frame exclusion
        baseColor = vec3(0.005 +
                         0.045 *
                         pow(abs(sin((uv.x - uv.y) * 12.0)), 20.0));
        specScale = 0.2;
    }
    else if (h.id == 7) {
        // Gun barrels – dark steel
        baseColor = vec3(0.02);
        specScale = 0.2;
    }
    else if (h.id == 3) {
        // Cockpit glass
        baseColor = vec3(0.05);
    }
    else if (h.id == 5) {
        // Window frame
        baseColor = vec3(0.10);
    }
    else { // h.id == 9 (laser) or fallback
        // Laser blast – bright emissive green
        baseColor = vec3(0.30, 1.00, 0.30);
        specScale = 0.0;
    }
}

#endif // TF_MATERIAL_GLSL
