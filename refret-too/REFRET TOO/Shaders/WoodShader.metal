#include <metal_stdlib>
using namespace metal;

struct WoodUniforms {
    float2 resolution;
    float  ringDensity;
    float  grainRoughness;
    float  colorVariation;
    float  stretch;
    float  orientation;
    float  sheenStrength;
    float  time;
    float4 lightColor;
    float4 darkColor;
};

float hash(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(float2 p, float persistence) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 5; ++i) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= persistence;
    }
    return value;
}

half4 woodColor(float2 position, constant WoodUniforms &uniforms) {
    float2 uv = position / uniforms.resolution;
    float2 centered = uv - 0.5;

    float c = cos(uniforms.orientation);
    float s = sin(uniforms.orientation);
    float2 rotated = float2(centered.x * c - centered.y * s,
                             centered.x * s + centered.y * c);

    rotated.y *= uniforms.stretch;

    float ringBase = length(float2(rotated.x, rotated.y * uniforms.ringDensity));
    float ringNoise = fbm(rotated * uniforms.ringDensity + uniforms.time * 0.02, 0.55);
    float grain = fbm(rotated * 6.0 + uniforms.time * 0.05, uniforms.grainRoughness);

    float rings = ringBase + ringNoise * 0.35;
    float ringMask = smoothstep(0.0, 1.0, fract(rings));

    float4 baseColor = mix(uniforms.darkColor, uniforms.lightColor, ringMask);
    baseColor.rgb += (grain - 0.5) * uniforms.colorVariation;

    float sheen = pow(max(0.0, grain), 6.0) * uniforms.sheenStrength;
    baseColor.rgb += sheen;

    return half4(half3(clamp(baseColor.rgb, 0.0, 1.0)), 1.0);
}

[[visible]]
half4 woodColorEffect(float2 position, half4 inColor, constant WoodUniforms &uniforms) {
    return woodColor(position, uniforms);
}
