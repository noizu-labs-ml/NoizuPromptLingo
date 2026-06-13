enum ShaderSource {
    static let header = """
#include <metal_stdlib>
using namespace metal;

struct VolumeLayer {
    half color_r;           // pigment concentration R (can exceed 1.0)
    half color_g;           // pigment concentration G
    half color_b;           // pigment concentration B
    half color_o;           // water height (0=dry, 1=fully wet)
    half depth;             // dried pigment deposited on paper
    half wetness;           // paper saturation state
    half viscosity;         // pressure (computed from water height)
    half hardness;          // paper absorption saturation
    half velocity_x;        // flow velocity X
    half velocity_y;        // flow velocity Y
    half surface_tension;   // surface tension coefficient
    half age;               // pigment settling rate (granulation)
    half gloss;             // dynamic: wet=glossy, dry=matte
    half substance_type;    // media type ID
    half flags;             // state flags (wet mask, boundary)
    half _padding;
};

struct SimParams {
    uint32_t canvas_width;
    uint32_t canvas_height;
    uint32_t layer_count;
    float dt;
};

struct RenderParams {
    uint32_t canvas_width;
    uint32_t canvas_height;
    uint32_t layer_count;
};

struct LightParams {
    float light_dir_x;
    float light_dir_y;
    float light_dir_z;
    float ambient;
};

struct ViewParams {
    float zoom_level;
    float pan_offset_x;
    float pan_offset_y;
    float pitch;
    float yaw;
    float roll;
    uint32_t canvas_width;
    uint32_t canvas_height;
    uint32_t drawable_width;
    uint32_t drawable_height;
};

struct LayerState {
    uint32_t active_layer;
    uint32_t visibility_mask;
    uint32_t _pad0;
    uint32_t _pad1;
};

float hash(float2 p) {
    float3 p3 = fract(float3(p.x, p.y, p.x) * 0.1031);
    p3 += dot(p3, float3(p3.y, p3.z, p3.x) + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise2d(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

"""

    static let brushHeader = """
struct BrushPoint {
    float position_x;
    float position_y;
    float pressure;
    float tilt_x;
    float tilt_y;
    float size;
    float timestamp;
    float _padding;
};

struct BrushParams {
    float size;
    float opacity;
    float flow;
    float hardness;
    uint32_t media_type;
    uint32_t shape_type;
    half color_r;
    half color_g;
    half color_b;
    half color_o;
    float angle;
    float spacing;
    float scatter;
    uint32_t active_layer;
    uint32_t is_eraser;
    uint32_t is_water_only;
    uint32_t _pad2;
    uint32_t _pad3;
};

struct DepositParams {
    uint32_t canvas_width;
    uint32_t canvas_height;
    uint32_t layer_count;
    uint32_t point_count;
};

"""

    static let sphHeader = """
struct SPHParticle {
    float position_x;
    float position_y;
    float velocity_x;
    float velocity_y;
    half color_r;
    half color_g;
    half color_b;
    half color_a;
    half radius;
    half mass;
    half local_density;
    half rest_density;
    half viscosity;
    half smoothing_length;
    half wetness;
    half life;
    uint8_t layer_index;
    uint8_t flags;
    uint16_t _pad0;
    uint32_t _pad1;
};

struct SpatialHashCell {
    uint32_t offset;
    uint32_t count;
};

struct SPHConstants {
    float smoothing_length;
    float rest_density;
    float stiffness;
    float gamma;
    float viscosity_coeff;
    float surface_tension_coeff;
    float dt;
    uint32_t particle_count;
    uint32_t grid_width;
    uint32_t grid_height;
    float cell_size;
    uint32_t canvas_width;
    uint32_t canvas_height;
    uint32_t _pad0;
    uint32_t _pad1;
    uint32_t _pad2;
};

struct DryingParams {
    uint32_t canvas_width;
    uint32_t canvas_height;
    uint32_t layer_count;
    float dt;
};

struct FluidParams {
    uint32_t canvas_width;
    uint32_t canvas_height;
    uint32_t layer_count;
    float dt;
    float viscosity;
    uint32_t iterations;
    uint32_t _pad0;
    uint32_t _pad1;
};

"""
}
