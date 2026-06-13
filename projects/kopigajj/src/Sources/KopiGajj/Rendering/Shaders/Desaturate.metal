#include <metal_stdlib>
using namespace metal;

/// Desaturate based on "age" — older clipboard items look drier
/// Usage: .colorEffect(ShaderLibrary.desaturate(.float(amount)))
/// amount: 0.0 = full color, 1.0 = grayscale
[[ stitchable ]] half4 desaturate(
    float2 position,
    half4 color,
    float amount
) {
    half luminance = dot(color.rgb, half3(0.299, 0.587, 0.114));
    half3 gray = half3(luminance);
    half3 result = mix(color.rgb, gray, half(amount));
    return half4(result, color.a);
}
