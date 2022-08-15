#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>
#include <common.h>

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 uv : TEXCOORD0;
};

float4 ps_main(PixelShaderInput input) : COLOR
{
	return tex2D(colorMapSampler,  mirrorTexCoords(input.uv.xy));
}
