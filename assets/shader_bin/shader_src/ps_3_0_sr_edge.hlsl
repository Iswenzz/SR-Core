#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.h>

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 color : COLOR;
	float4 uv : TEXCOORD0;
};

inline float edgeGlow(sampler2D t, float2 uv, float2 d, float p)
{
    float2 a = 0, b = 0;

    a += tex2D(t, uv + d * float2(0, 1)).xy;
    a += tex2D(t, uv + d * float2(-1, 0)).xy;
    a += tex2D(t, uv + d * float2(-1, 1)).xy;
    a += tex2D(t, uv + d * float2(-1, -1)).xy;
    a -= tex2D(t, uv + d * float2(1, 0)).xy;
    a -= tex2D(t, uv + d * float2(0, -1)).xy;
    a -= tex2D(t, uv + d * float2(1, -1)).xy;
    a -= tex2D(t, uv + d * float2(1, 1)).xy;

    b += tex2D(t, uv + d * float2(1, 1)).yz;
    b += tex2D(t, uv + d * float2(0, 1)).yz;
    b += tex2D(t, uv + d * float2(1, 0)).yz;
    b += tex2D(t, uv + d * float2(-1, 1)).yz;
    b -= tex2D(t, uv + d * float2(-1, -1)).yz;
    b -= tex2D(t, uv + d * float2(0, -1)).yz;
    b -= tex2D(t, uv + d * float2(-1, 0)).yz;
    b -= tex2D(t, uv + d * float2(1, -1)).yz;

    return (float)((a * a + b * b) * p);
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	float4 color = tex2D(colorMapSampler, input.uv);

	const float edgeGlowOffset = 3.0f;
	const float edgeGlowPower = input.color.w;
	const float4 edgeGlowColor = (input.color.x, input.color.y, input.color.z, 1.0f);

	color *= input.color;
	color += edgeGlow(colorMapSampler, input.uv.xy, edgeGlowOffset * 0.001, edgeGlowPower) * edgeGlowColor;

	return color;
}
