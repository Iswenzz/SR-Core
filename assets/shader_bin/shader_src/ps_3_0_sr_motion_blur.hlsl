#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.h>

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
	float2 motionBlurUV : TEXCOORD1;
};

float4 ps_main(PixelShaderInput input) : COLOR
{
	const float motionBlurAlpha = 0;

	float4 motionBlur = tex2D(colorMapSampler, input.motionBlurUV);
	float4 color = tex2D(colorMapSampler, input.uv);
	return lerp(color, motionBlur, motionBlurAlpha);
}
