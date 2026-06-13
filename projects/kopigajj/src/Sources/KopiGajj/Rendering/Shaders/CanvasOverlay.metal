#include <metal_stdlib>
using namespace metal;

/// Canvas texture overlay — composites a tileable canvas-weave texture
/// over the entire view using a multiply-style blend.
///
/// Usage: .layerEffect(
///            ShaderLibrary.canvasOverlay(.image(Image("canvas-weave-tile")),
///                                        .float(0.3)),
///            maxSampleOffset: .zero)
[[ stitchable ]] half4 canvasOverlay(
    float2 position,
    SwiftUI::Layer layer,
    texture2d<half> canvasTex [[ texture(0) ]],
    float intensity
) {
    half4 color = layer.sample(position);

    constexpr sampler s(address::repeat, filter::linear);
    float2 uv = position / float2(canvasTex.get_width(), canvasTex.get_height());
    half4 canvas = canvasTex.sample(s, uv);

    // Multiply blend: darkens slightly where canvas weave is, giving depth
    color.rgb = mix(color.rgb, color.rgb * (canvas.rgb * 0.5 + 0.5), half(intensity));
    return color;
}
