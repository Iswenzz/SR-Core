#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.hlsl>

struct VertexShaderInput
{
	float4 position : POSITION;
	float4 color : COLOR;
	float2 uv : TEXCOORD0;
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

	const float shakeSpeedX = input.color.x * 10;
	const float shakeSpeedY = input.color.y * 10;
	const float zoomAmount = input.color.z;
	const float shakeIntensity = input.color.w * 0.1;

	const float2 center = { 0.5, 0.5 };

	output.uv = lerp(output.uv, center, 2 - 2 / ((zoomAmount * gameTime.x) + 1));
	output.uv.x += sin(shakeSpeedX * (gameTime.x * 2)) * shakeIntensity;
	output.uv.y += sin(shakeSpeedY * (gameTime.x * 2)) * shakeIntensity;

	return output;
}
