#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
};

float4 ps_main(PixelShaderInput input) : COLOR
{
	return tex2D(colorMapSampler, wrapUV(input.uv));
}
