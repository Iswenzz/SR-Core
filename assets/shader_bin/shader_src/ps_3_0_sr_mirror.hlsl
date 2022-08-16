#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.h>

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
};

float4 ps_main(PixelShaderInput input) : COLOR
{
	float newX = input.uv.x + gameTime.w;
	return tex2D(colorMapSampler, float2(newX, input.uv.y));
}
