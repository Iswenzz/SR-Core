#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.hlsl>

struct VertexInput
{
	float4 position : POSITION;
};

struct PixelInput
{
	float4 position : POSITION;
	float3 worldpos : TEXCOORD;
	float3 camerapos : TEXCOORD1;
};

PixelInput vs_main(const VertexInput vertex)
{
	PixelInput pixel;

	pixel.position = mul(float4(vertex.position.xyz, 1.0f), worldViewProjectionMatrix);
	pixel.worldpos = vertex.position.xyz;
	pixel.camerapos = inverseWorldMatrix[3].xyz;

	return pixel;
}
