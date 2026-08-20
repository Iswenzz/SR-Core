#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.hlsl>

struct VertexShaderInput
{
	float4 position : POSITION;
	float4 normal : NORMAL;
};

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
};

// Quake's "tcGen environment": reflect the eye about the vertex normal and read
// the result as a sphere map. RB_CalcEnvironmentTexCoords does this in the
// entity's own space and takes y and z of the reflected vector, so nothing here
// is carried to world space first - for a model inverseWorldMatrix[3] is
// already the eye in object space, which is the one value that makes it work.
PixelShaderInput vs_main(VertexShaderInput input)
{
	PixelShaderInput output;

	output.position = mul(float4(input.position.xyz, 1.0f), worldViewProjectionMatrix);

	// Vertex normals arrive packed into 0..1.
	float3 normal = normalize(input.normal.xyz * 2.0f - 1.0f);
	float3 viewer = normalize(inverseWorldMatrix[3].xyz - input.position.xyz);
	float3 reflected = normal * 2.0f * dot(normal, viewer) - viewer;

	output.uv = float2(0.5f + reflected.y * 0.5f, 0.5f - reflected.z * 0.5f);

	return output;
}
