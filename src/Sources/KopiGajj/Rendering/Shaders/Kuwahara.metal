#include <metal_stdlib>
using namespace metal;

/// Kuwahara filter — oil-painting brush-stroke abstraction
/// Divides the sampling kernel into 4 quadrants, picks the one with lowest variance.
/// This produces flat color regions with sharp boundaries — the hallmark of oil paint.
///
/// Usage: .layerEffect(ShaderLibrary.kuwahara(.float(3.0)),
///                     maxSampleOffset: CGSize(width: 3, height: 3))
/// radius: 3 recommended (~1-2ms Apple Silicon). Must match maxSampleOffset.
[[ stitchable ]] half4 kuwahara(
    float2 position,
    SwiftUI::Layer layer,
    float radius
) {
    int r = int(radius);

    half3 mean[4] = {};
    half3 sigma[4] = {};
    half count[4] = {};

    for (int j = -r; j <= r; j++) {
        for (int i = -r; i <= r; i++) {
            half4 s = layer.sample(position + float2(i, j));
            half3 c = s.rgb;

            // Quadrant 0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right
            if (i <= 0 && j <= 0) { mean[0] += c; sigma[0] += c * c; count[0] += 1.0; }
            if (i >= 0 && j <= 0) { mean[1] += c; sigma[1] += c * c; count[1] += 1.0; }
            if (i <= 0 && j >= 0) { mean[2] += c; sigma[2] += c * c; count[2] += 1.0; }
            if (i >= 0 && j >= 0) { mean[3] += c; sigma[3] += c * c; count[3] += 1.0; }
        }
    }

    half minVar = 1e10;
    half3 result = half3(0);

    for (int q = 0; q < 4; q++) {
        mean[q] /= count[q];
        sigma[q] = sigma[q] / count[q] - mean[q] * mean[q];
        half v = sigma[q].r + sigma[q].g + sigma[q].b;
        if (v < minVar) { minVar = v; result = mean[q]; }
    }

    return half4(result, layer.sample(position).a);
}
