#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.hlsl>

struct VertexShaderInput
{
	float4 position : POSITION;
};

struct VertexShaderOutput
{
	float4 position : POSITION;
	float3 worldPos : TEXCOORD;
};

VertexShaderOutput vs_main(VertexShaderInput input)
{
	VertexShaderOutput output = (VertexShaderOutput)0;

	float3 dir = input.position.xyz - eyePos.xyz;
	output.position = mul(float4(dir, 0.0f), worldViewProjectionMatrix);
	output.worldPos = dir;

	return output;
}
