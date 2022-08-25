#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.hlsl>

struct VertexShaderInput
{
	float4 position : POSITION;
	float4 color : COLOR;
	float4 uv : TEXCOORD0;
};

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 color : COLOR;
	float2 uv : TEXCOORD0;
	float2 letterBoxUV : TEXCOORD1;
};

float rand(float2 co)
{
    return frac(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset, float range)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = cubicSmoothstep(edge0, pos, uvY) * offset;
    x -= cubicSmoothstep(pos, edge1, uvY) * offset;
    return x;
}

PixelShaderInput vs_main(VertexShaderInput input)
{
	PixelShaderInput output;

	output.position = mul(float4(input.position.xyz, 1.0f), worldViewProjectionMatrix);
	output.uv = input.uv;
	output.letterBoxUV = input.uv;
	output.color = input.color;

	const float range = input.color.x;
	const float noiseQuality = 10.0;
	const float noiseIntensity = input.color.y;
	const float offsetIntensity = input.color.z;

	float2 uv = output.uv;

    for (float i = 0.0; i < 0.71; i += 0.1313)
    {
        float d = fmod(gameTime.w * i, 1.7);
        float o = sin(1.0 - tan(gameTime.w * 0.24 * i));
    	o *= offsetIntensity;
        uv.x += verticalBar(d, uv.y, o, range);
    }

    float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);

    float noise = rand(vec2(gameTime.w * 0.00001, uvY));
    uv.x += noise * noiseIntensity;
	uv.y = uvY;
	output.uv = uv;

	return output;
}
