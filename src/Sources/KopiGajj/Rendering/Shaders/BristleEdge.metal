#include <metal_stdlib>
using namespace metal;

/// Bristle edge distortion — creates irregular painterly edges on stroke cards
/// Displaces pixels near the view boundary with noise-based wobble, simulating
/// the ragged edge of a loaded brush dragged across canvas.
///
/// Usage: .distortionEffect(
///            ShaderLibrary.bristleEdge(.float2(width, height), .float(2.5),
///                                      .float(12.0), .float(seed)),
///            maxSampleOffset: CGSize(width: 4, height: 4))
[[ stitchable ]] float2 bristleEdge(
    float2 position,
    float2 size,
    float amplitude,
    float frequency,
    float seed
) {
    float2 center = size * 0.5;
    float2 d = (position - center) / center;

    // Only distort near edges
    float edgeness = max(abs(d.x), abs(d.y));
    float edgeFactor = smoothstep(0.7, 1.0, edgeness);

    // Noise-based displacement varying by angle around the card
    float angle = atan2(d.y, d.x);
    float noise = sin(angle * frequency + seed * 17.3)
                * cos(angle * frequency * 0.7 + seed * 31.1);

    float2 offset = normalize(d + float2(0.001)) * noise * amplitude * edgeFactor;

    return position + offset;
}
