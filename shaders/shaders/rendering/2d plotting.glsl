// 2D Plotting
// Contains three rendering methods for drawing y = f(x) in screen space.
// Each function returns a weight ∈ [0,1] indicating how strongly a pixel
// should be colored as part of the curve.
// Functions:
//   1. plotNaive       – uses vertical distance only
//   2. plotDerivative  – adjusts vertical distance by curve slope
//   3. plotSampling    – uses subpixel sampling for antialiasing

// ============================================================================
// plotNaive
// ---------------------------
// Method 1: Naive absolute‐difference to curve y = f(x).
// Computes vertical distance only.
//
// Inputs:
//   p       – vec2: graph coordinate (x, y) for the current pixel.
//   epsilon – float: half‐width of the “soft‐edge” around the curve.
//
// Output:
//   returns float w ∈ [0, 1]:
//     - w ≈ 0 when |p.y - f(p.x)| ≤ 0   (pixel center lies exactly on curve).
//     - w ≈ 1 when |p.y - f(p.x)| ≥ 2ε  (pixel is far from the curve).
//     - in between 0 and 1 for 0 < |p.y - f(p.x)| < 2ε (smooth transition).
//   This weight can be used to blend curve color (ratio→0) with background (ratio→1).
// ============================================================================
float plotNaive(in vec2 p, in float epsilon) {
    float d = abs(p.y - f(p.x));               // vertical distance to curve
    return smoothstep(0.0, 2.0 * epsilon, d);   // soft edge over [0, 2ε]
}

// ============================================================================
// plotDerivative
// ---------------------------
// Method 2: Derivative‐corrected distance to curve y = f(x).
// Adjusts the vertical threshold by the local slope to approximate actual distance.
//
// Inputs:
//   p       – vec2: graph coordinate (x, y) for the current pixel.
//   epsilon – float: base half‐width of the curve (in geometric distance).
//
// Output:
//   returns float w ∈ [0, 1]:
//     - Uses central difference to approximate f’(x):
//         dy ≈ [f(p.x + ε/2) - f(p.x - ε/2)] / ε.
//     - Computes correctedThreshold = ε * sqrt(1 + (dy)^2).
//     - Computes vertical distance d = |p.y - f(p.x)|.
//     - Returns smoothstep(0, 2 * correctedThreshold, d):
//         w ≈ 0 if d ≤ 0,
//         w ≈ 1 if d ≥ 2 * correctedThreshold,
//         smooth in between.
//   Guarantees that, for steep slopes, the pixel’s geometric distance to the curve
//   is approximately ε when w transitions from 0→1.
// ============================================================================
float plotDerivative(in vec2 p, in float epsilon) {
    float dx = epsilon * 0.5;
    float dy = (f(p.x + dx) - f(p.x - dx)) / epsilon;  // approximate f’(x)
    float correctedThreshold = epsilon * sqrt(1.0 + dy * dy);
    float d = abs(p.y - f(p.x));                       // vertical distance
    return smoothstep(0.0, 2.0 * correctedThreshold, d);
}

// ============================================================================
// plotSampling
// ---------------------------
// Method 3: Subpixel sampling antialiasing.
// Samples a pixel’s neighborhood at subpixel positions to determine coverage.
//
// Inputs:
//   fragCoord  – vec2: pixel coordinate (in range [0, iResolution.x]×[0, iResolution.y]).
//   iResolution – vec2: screen resolution (width, height).
//   pixWidth   – float: half‐size of the sampling window in pixels (e.g., 1.0 for ±1 px).
//   pixSample  – float: subpixel step size (e.g., 0.5 for half‐pixel steps).
//
// Procedure:
//   1. Loop sx = fragCoord.x - pixWidth → fragCoord.x + pixWidth, step = pixSample.
//   2. Loop sy = fragCoord.y - pixWidth → fragCoord.y + pixWidth, step = pixSample.
//   3. totalSamples++ each iteration.
//   4. Map (sx, sy) to graph coordinate s = frag2point((sx, sy), iResolution).
//   5. If f(s.x) > s.y, then countOnCurve++ (sample is “under” the curve).
//   6. After loops, ratio = countOnCurve / totalSamples.
//
// Output:
//   returns float w ∈ [0, 1] = samples2stroke(ratio):
//     - w ≈ 1 when ratio ≈ 0.5 (pixel straddles curve).
//     - w ≈ 0 when ratio ≈ 0 or 1 (pixel entirely on one side).
//   The smooth mapping via samples2stroke yields a soft, antialiased edge.
// ============================================================================
float plotSampling(
    in vec2 fragCoord,
    in vec2 iResolution,
    in float pixWidth,
    in float pixSample
) {
    float countOnCurve = 0.0;
    float totalSamples = 0.0;
    for (float sx = fragCoord.x - pixWidth; sx <= fragCoord.x + pixWidth; sx += pixSample) {
        for (float sy = fragCoord.y - pixWidth; sy <= fragCoord.y + pixWidth; sy += pixSample) {
            totalSamples += 1.0;
            vec2 s = frag2point(vec2(sx, sy), iResolution);
            if (f(s.x) > s.y) {
                countOnCurve += 1.0;
            }
        }
    }
    float ratio = countOnCurve / totalSamples;
    return samples2stroke(ratio);
}





// frag2point
// ---------------------------
// Converts a fragment (pixel) coordinate to a 2D graph coordinate (x, y).
//
// Inputs:
//   fragCoord  – vec2: pixel coordinate on the screen (in the range [0, iResolution.x] × [0, iResolution.y]).
//   iResolution – vec2: screen resolution, (width, height).
//
// Output:
//   returns vec2 p = (x, y), where
//     x = 4.0 * (fragCoord.x - 0.5 * iResolution.x) / iResolution.y
//     y = 4.0 * (fragCoord.y - 0.5 * iResolution.y) / iResolution.y
//   This maps the screen so that the vertical axis spans approximately [-2, +2],
//   and the horizontal axis is stretched by aspect ratio.
vec2 frag2point(in vec2 fragCoord, in vec2 iResolution) {
    return 4.0 * (fragCoord - 0.5 * iResolution) / iResolution.y;
}



// ============================================================================
// samples2stroke
// ---------------------------
// Converts a ratio of subpixel samples ∈ [0, 1] into a stroke weight ∈ [0, 1].
//
// Inputs:
//   ratio – float: fraction of subpixel samples that lie “below” the curve
//            (0.5 means half of the samples are below, indicating the pixel
//            straddles the curve).
//
// Output:
//   returns float weight ∈ [0, 1]:
//     weight ≈ 1.0 when ratio ≈ 0.5 (pixel straddles curve center),
//     weight ≈ 0.0 when ratio ≈ 0 or ratio ≈ 1 (pixel is entirely on one side).
// ============================================================================
float samples2stroke(in float ratio) {
    return 1.0 - smoothstep(0.0, 0.5, ratio) * smoothstep(1.0, 0.5, ratio);
}