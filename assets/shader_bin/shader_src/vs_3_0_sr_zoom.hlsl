#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <shader_vars.h>

struct VertexShaderInput
{
	float4 position : POSITION;
	float4 uv : TEXCOORD0;
};

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 uv : TEXCOORD0;
};

PixelShaderInput vs_main(VertexShaderInput input)
{
	PixelShaderInput output;

	output.position = mul(float4(input.position.xyz, 1.0f), worldViewProjectionMatrix);
	output.uv = input.uv;

	const float shakeSpeedX = 6.0f;
	const float shakeSpeedY = 3.0f;
	const float shakeIntensity = 0.05;

	float2 uv = output.uv.xy / output.uv.w;
	uv.x += sin(shakeSpeedX * gameTime.x) * shakeIntensity;
	uv.y += sin(shakeSpeedY * gameTime.x) * shakeIntensity;
	output.uv.xy = uv;

	return output;
}
