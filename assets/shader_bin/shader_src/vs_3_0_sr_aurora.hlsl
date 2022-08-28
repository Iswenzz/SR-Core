#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.hlsl>

struct V_IN
{
	float4 position : POSITION;
	//float3 worldPos : TEXCOORD;
};

struct V_OUT
{
	float4 position : POSITION;
	float3 worldPos : TEXCOORD;
};

V_OUT vs_main( V_IN input )
{
	V_OUT output = (V_OUT)0;

	float4 dir;
	dir.xyz = input.position - eyePos;
	dir.w = 0;


		//output.position = mul(float4( dir.xyz, 1.0f), worldViewProjectionMatrix); // 1:1 scale
		output.position = mul(float4( dir.xyz, 0.0f), worldViewProjectionMatrix); // infinite scale

	output.worldPos = dir;

	return output; // send projected vertex to the rasterizer stage
}
