#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.hlsl>

struct VertexShaderInput
{
	float4 position : POSITION;
};

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 clipPos  : TEXCOORD0; // screen-space lookup into the portal view
	float4 clipMid  : TEXCOORD1; // portal centre, for the rim refraction direction
	float3 local    : TEXCOORD2; // object space, drives the elliptical mask
	float3 viewDir  : TEXCOORD3; // world space, eye -> surface
	float3 normal   : TEXCOORD4; // world space surface normal
};

PixelShaderInput vs_main(VertexShaderInput input)
{
	PixelShaderInput output;

	float4 local = float4(input.position.xyz, 1.0f);
	float4 clip = mul(local, worldViewProjectionMatrix);
	float4 world = mul(local, worldMatrix);

	output.position = clip;
	output.clipPos = clip;
	output.clipMid = mul(float4(0.0f, 0.0f, 0.0f, 1.0f), worldViewProjectionMatrix);
	output.local = input.position.xyz;
	output.viewDir = world.xyz - eyePos.xyz;

	// The quad lies in the object-space YZ plane, so +X is its surface normal.
	output.normal = mul(float4(1.0f, 0.0f, 0.0f, 0.0f), worldMatrix).xyz;

	return output;
}
