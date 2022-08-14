#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <shader_vars.h>

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 uv : TEXCOORD0;
	float3 world : TEXCOORD1;
	float4 center : TEXCOORD4;
};

float4 ps_main(PixelShaderInput input) : COLOR
{
	float2 t = frac(input.uv.xy * 0.5) * 2.0;
    float2 length = {1.0, 1.0};
    float2 mirrorTexCoords = length - abs(t - length);

	return tex2D(colorMapSampler,  mirrorTexCoords);
}
