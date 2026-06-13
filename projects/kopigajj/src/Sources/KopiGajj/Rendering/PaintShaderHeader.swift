/// All Metal compute kernel source for the paint simulation engine.
/// Compiled at runtime via MTLDevice.makeLibrary(source:).
///
/// Architecture: Canvas (height+material) → Solid layer (dried) → Wet layer (active)
/// Media types: 0=oil, 1=watercolor, 2=acrylic, 3=pastel
/// Brush tips: 0=round, 1=flat, 2=filbert, 3=fan, 4=knife, 5=mop, 6=rigger, 7=wash,
///   8=stick, 9=edge, 10=blender, 11=hard, 12=soft, 13=chisel, 14=fine, 15=bullet
enum PaintShaderSource {

    static let header = """
    #include <metal_stdlib>
    using namespace metal;

    // All flat floats — must match Swift struct layout exactly (56 bytes)
    // Stores absorption values: 0 = transparent, higher = more opaque pigment
    struct BrushPoint {
        float posX;
        float posY;
        float pressure;
        float radius;
        float absR;        // absorption red (0-8+)
        float absG;        // absorption green (0-8+)
        float absB;        // absorption blue (0-8+)
        float concentration; // pigment concentration (0-1)
        float viscosity;
        float tipType;
        float angle;       // tip rotation
        float dirX;        // stroke travel direction (normalized)
        float dirY;
        float wetness;     // brush wetness (0=dry brush, 1=saturated) — primarily for watercolor
    };

    struct CanvasParams {
        float threadSpacing;
        float threadWeight;
        float ridgeHeight;
        uint  seed;
        int   width;
        int   height;
        // Canvas material preset
        float absorbency;   // 0=sealed, 1=raw cotton
        float roughness;    // 0=smooth, 1=coarse
        float porosity;     // 0=sealed, 1=porous (water seeps fast)
        float _pad;
    };

    struct SimParams {
        float flowStrength;
        float diffusionRate;
        float dryRate;
        float edgeDarken;
        float dt;
    };

    struct RenderParams {
        float lightDirX;
        float lightDirY;
        float lightDirZ;
        float ambient;
        float specular;
        float canvasR;
        float canvasG;
        float canvasB;
        float canvasA;
        float heightScale;
        int   renderMode;
        float _pad;
    };

    // Media type constants
    constant int MEDIA_OIL        = 0;
    constant int MEDIA_WATERCOLOR = 1;
    constant int MEDIA_ACRYLIC    = 2;
    constant int MEDIA_PASTEL      = 3;
    constant int MEDIA_HIGHLIGHTER = 4;

    // Brush tip constants
    constant int TIP_ROUND   = 0;
    constant int TIP_FLAT    = 1;
    constant int TIP_FILBERT = 2;
    constant int TIP_FAN     = 3;
    constant int TIP_KNIFE   = 4;
    constant int TIP_MOP     = 5;
    constant int TIP_RIGGER  = 6;
    constant int TIP_WASH    = 7;
    constant int TIP_STICK   = 8;
    constant int TIP_EDGE    = 9;
    constant int TIP_BLENDER = 10;
    constant int TIP_HARD    = 11;
    constant int TIP_SOFT    = 12;
    constant int TIP_CHISEL  = 13;
    constant int TIP_FINE    = 14;
    constant int TIP_BULLET  = 15;

    // --- Noise ---
    float hash(float2 p) {
        float3 p3 = fract(float3(p.xyx) * 0.1031);
        p3 += dot(p3, p3.yzx + 33.33);
        return fract((p3.x + p3.y) * p3.z);
    }
    float noise2d(float2 p) {
        float2 i = floor(p);
        float2 f = fract(p);
        f = f * f * (3.0 - 2.0 * f);
        return mix(mix(hash(i), hash(i + float2(1, 0)), f.x),
                   mix(hash(i + float2(0, 1)), hash(i + float2(1, 1)), f.x), f.y);
    }

    // --- Brush tip profile ---
    // Returns deposit weight (0-1) for a point at (dx,dy) from brush center
    // given brush radius, tip type, and brush angle.
    float tipProfile(float2 delta, float radius, int tipType, float angle) {
        // Rotate delta by -angle to align with brush tip
        float ca = cos(-angle);
        float sa = sin(-angle);
        float2 rd = float2(delta.x * ca - delta.y * sa,
                           delta.x * sa + delta.y * ca);

        float dist = length(delta);
        if (dist > radius) return 0.0;
        float t = dist / radius;

        if (tipType == TIP_ROUND) {
            // Smooth dome
            float s = 1.0 - t;
            return s * s * (3.0 - 2.0 * s);
        }
        if (tipType == TIP_FLAT) {
            // Rectangular: wide along x, narrow along y
            float fx = abs(rd.x) / radius;
            float fy = abs(rd.y) / (radius * 0.25);
            if (fx > 1.0 || fy > 1.0) return 0.0;
            return (1.0 - fx) * (1.0 - fy * fy);
        }
        if (tipType == TIP_FILBERT) {
            // Oval with tapered end
            float fx = rd.x / radius;
            float fy = rd.y / (radius * 0.5);
            float d = fx * fx + fy * fy;
            if (d > 1.0) return 0.0;
            float taper = 1.0 - clamp(fx * 0.5 + 0.5, 0.0, 1.0) * 0.4;
            return (1.0 - d) * taper;
        }
        if (tipType == TIP_FAN) {
            // Multiple thin strands spreading out
            float fx = rd.x / radius;
            float fy = rd.y / (radius * 0.6);
            if (abs(fx) > 1.0 || abs(fy) > 1.0) return 0.0;
            float strand = abs(sin(fy * 8.0));
            return (1.0 - abs(fx)) * strand * 0.8;
        }
        if (tipType == TIP_KNIFE) {
            // Very flat scraper — wide, almost no height
            float fx = abs(rd.x) / radius;
            float fy = abs(rd.y) / (radius * 0.08);
            if (fx > 1.0 || fy > 1.0) return 0.0;
            return (1.0 - fx * fx) * 0.3; // thin deposit
        }
        // Mop: Large soft round, very gradual falloff (watercolor wash brush)
        if (tipType == TIP_MOP) {
            float s = 1.0 - t;
            return s * s * s; // cubic falloff — softer than round
        }
        // Rigger: Very thin and long, like a liner brush
        if (tipType == TIP_RIGGER) {
            float fx = abs(rd.x) / radius;
            float fy = abs(rd.y) / (radius * 0.06); // extremely narrow
            if (fx > 1.0 || fy > 1.0) return 0.0;
            return (1.0 - fx * fx) * (1.0 - fy * fy) * 0.9;
        }
        // Wash: Very wide, flat, uniform deposit
        if (tipType == TIP_WASH) {
            float fx = abs(rd.x) / radius;
            float fy = abs(rd.y) / (radius * 0.15);
            if (fx > 1.0 || fy > 1.0) return 0.0;
            return (1.0 - fx * fx * fx) * (1.0 - fy * fy); // flatter falloff
        }
        // Stick: Rectangular pastel stick (used on side)
        if (tipType == TIP_STICK) {
            float fx = abs(rd.x) / (radius * 0.7);
            float fy = abs(rd.y) / (radius * 0.3);
            if (fx > 1.0 || fy > 1.0) return 0.0;
            float grain = noise2d(float2(rd.x, rd.y) * 0.5) * 0.3 + 0.7;
            return (1.0 - fx * fx) * (1.0 - fy * fy) * grain;
        }
        // Edge: Thin line from pastel stick edge
        if (tipType == TIP_EDGE) {
            float fx = abs(rd.x) / radius;
            float fy = abs(rd.y) / (radius * 0.04);
            if (fx > 1.0 || fy > 1.0) return 0.0;
            return (1.0 - fx) * 0.7;
        }
        // Blender: Soft circular with very low deposit (blending stump/tortillon)
        if (tipType == TIP_BLENDER) {
            float s = 1.0 - t;
            return s * s * 0.25; // very light deposit
        }
        // Hard: Small firm pastel, sharp edges
        if (tipType == TIP_HARD) {
            if (t > 0.8) return 0.0;
            return smoothstep(0.8, 0.5, t); // sharper falloff
        }
        // Soft: Large soft pastel, very gradual
        if (tipType == TIP_SOFT) {
            float s = 1.0 - t;
            return s * s * s * s; // quartic — very soft edges
        }
        // Chisel: Wedge-shaped marker tip
        if (tipType == TIP_CHISEL) {
            float fx = abs(rd.x) / radius;
            float fy = abs(rd.y) / (radius * 0.2);
            if (fx > 1.0 || fy > 1.0) return 0.0;
            return (1.0 - fx) * (1.0 - fy * fy) * 0.95;
        }
        // Fine: Very thin round marker tip
        if (tipType == TIP_FINE) {
            if (t > 0.3) return 0.0; // small footprint
            float s = 1.0 - t / 0.3;
            return s * s * 0.9;
        }
        // Bullet: Medium round marker, hard edges
        if (tipType == TIP_BULLET) {
            if (t > 0.6) return 0.0;
            return smoothstep(0.6, 0.2, t) * 0.85;
        }
        return 1.0 - t; // fallback linear
    }
    """
}
