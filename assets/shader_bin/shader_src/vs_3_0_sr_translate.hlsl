#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.h>

struct VertexShaderInput
{
	float4 position : POSITION;
	float4 color : COLOR;
	float4 uv : TEXCOORD0;
};

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
};

PixelShaderInput vs_main(VertexShaderInput input)
{
	PixelShaderInput output;

	output.position = mul(float4(input.position.xyz, 1.0f), worldViewProjectionMatrix);
	output.uv = input.uv;

	const float translateSpeedX = input.color.x;
	const float translateSpeedY = input.color.y;
	const float intensity = input.color.z;

	output.uv.x += (translateSpeedX * gameTime.w) * (intensity * 5);
	output.uv.y += (translateSpeedY * gameTime.w) * (intensity * 5);

	return output;
}
