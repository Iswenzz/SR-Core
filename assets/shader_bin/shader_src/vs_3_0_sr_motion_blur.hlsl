#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.h>

struct VertexShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
	float4 color : COLOR;
};

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
	float4 color : COLOR;
	float2 motionBlurUV : TEXCOORD1;
};

PixelShaderInput vs_main(VertexShaderInput input)
{
	PixelShaderInput output;

	output.position = mul(float4(input.position.xyz, 1.0f), worldViewProjectionMatrix);
	output.uv = input.uv;
	output.color = input.color;

	const float motionBlurZoom = 0;

	float2 center = { 0.5, 0.5 };
	output.motionBlurUV = lerp(input.uv, center, 2 - 2 / (motionBlurZoom + 1));

	return output;
}
