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
	float2 uv = input.uv;

	const float halfPi = 1.57079632679;
	const float2 center = { 0.5, 0.5 };
	const float zoomMode = input.color.x;
	const float zoomAmount = input.color.y;
	const float zoomSpeed = gameTime.x * input.color.z;

	if (zoomMode < 0.5)
		uv = lerp(uv, center, 2 - 2 / ((zoomAmount * zoomSpeed) + 1));
	else if (zoomMode > 0.5)
	{
		float scale = (zoomAmount * (zoomSpeed * 8)) * halfPi;
		uv -= center;
		if (zoomAmount > 0.5)
			uv = normalize(uv) * tan(length(uv) * scale) / tan(scale);
		else if (zoomAmount < 0.5)
			uv = normalize(uv) * atan(length(uv) * tan(scale)) / scale;
		uv += center;
	}
	output.uv = uv;
	return output;
}
