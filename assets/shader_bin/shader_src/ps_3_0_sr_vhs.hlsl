#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.h>

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 uv : TEXCOORD0;
};

float hash(float2 p)
{
    return frac(sin(dot(p, float2(12.9898, 78.233))) * 47758.5453);
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	const float colorOffsetIntensity = 1.3;

    float2 offsetR = vec2(0.006 * sin(gameTime.x), 0.0) * colorOffsetIntensity;
    float2 offsetG = vec2(0.0073 * (cos(gameTime.x * 0.97)), 0.0) * colorOffsetIntensity;

    float r = tex2D(colorMapSampler, input.uv.xy + offsetR).r;
    float g = tex2D(colorMapSampler, input.uv.xy + offsetG).g;
    float b = tex2D(colorMapSampler, input.uv.xy).b;

    return vec4(r, g, b, 1.0);
}
