extension ShaderSource {
    static let volumeInit = header + """
kernel void volumeInit(
    device VolumeLayer* layers [[buffer(0)]],
    constant SimParams& params [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    int w = int(params.canvas_width);
    int h = int(params.canvas_height);
    if (int(gid.x) >= w || int(gid.y) >= h) return;

    uint pixelIndex = gid.y * uint(w) + gid.x;
    uint layerStride = uint(w) * uint(h);

    for (uint layer = 0; layer < params.layer_count; layer++) {
        uint idx = pixelIndex + layer * layerStride;
        layers[idx] = VolumeLayer{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    }
}
"""
}
