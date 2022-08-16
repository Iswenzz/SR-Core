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

	const float shakeSpeedX = input.color.x;
	const float shakeSpeedY = input.color.y;
	const float shakeIntensity = input.color.z;

	output.uv.x += sin(shakeSpeedX * gameTime.x) * shakeIntensity;
	output.uv.y += sin(shakeSpeedY * gameTime.x) * shakeIntensity;

	return output;
}
