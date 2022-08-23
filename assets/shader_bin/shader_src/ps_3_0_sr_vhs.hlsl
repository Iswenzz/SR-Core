#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#define GLOW_SETUP_CUTOFF 1
#include <common.hlsl>

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 color: COLOR;
	float2 uv : TEXCOORD0;
	float2 letterBoxUV : TEXCOORD1;
};

float hash(float2 p)
{
    return frac(sin(dot(p, float2(12.9898, 78.233))) * 47758.5453);
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	const float colorOffsetIntensity = 0.2;

    float2 offsetR = float2(0.006 * sin(gameTime.w), 0.0) * colorOffsetIntensity;
    float2 offsetG = float2(0.0073 * (cos(gameTime.w * 0.97)), 0.0) * colorOffsetIntensity;

	// Glitch
    float r = tex2D(colorMapSampler, input.uv + offsetR).r;
    float g = tex2D(colorMapSampler, input.uv + offsetG).g;
    float b = tex2D(colorMapSampler, input.uv).b;
	float4 color = float4(r, g, b, 1.0);

	// Grain
	float strength = 20.0;
    float x = (input.uv.x + 4.0) * (input.uv.y + 4.0) * (gameTime.w * 10.0);
	float grain = fmod((fmod(x, 13.0) + 1.0) * (fmod(x, 123.0) + 1.0), 0.01) - 0.005;
    float4 grainColor = (float4)grain * strength;
	color += grainColor;

	// LetterBox
	float letterBoxDistance = input.color.w;
    const float letterBoxAlpha = 1.0;
    const float4 letterBoxColor = (float4)0.0;
    const float2 center = { 0.5, 0.5 };

    if (letterBoxDistance <= 0.5)
	{
		float leftColor = cubicSmoothstep(letterBoxDistance, letterBoxDistance, center.x - input.letterBoxUV.x) * letterBoxAlpha;
		color = lerp(float4(color.rgb, 1.0), lerp(float4(color.rgb, 1.0), letterBoxColor, leftColor * letterBoxAlpha * 10.0), letterBoxDistance);
		float rightColor = cubicSmoothstep(letterBoxDistance, letterBoxDistance, -center.x + input.letterBoxUV.x) * letterBoxAlpha;
		color = lerp(float4(color.rgb, 1.0), lerp(float4(color.rgb, 1.0), letterBoxColor, rightColor * letterBoxAlpha * 10.0), letterBoxDistance);
	}
	else
	{
		letterBoxDistance -= 0.5;
		float topColor = cubicSmoothstep(letterBoxDistance, letterBoxDistance, center.y - input.letterBoxUV.y) * letterBoxAlpha;
		color = lerp(float4(color.rgb, 1.0), lerp(float4(color.rgb, 1.0), letterBoxColor, topColor * letterBoxAlpha * 10.0), letterBoxDistance);
		float bottomColor = cubicSmoothstep(letterBoxDistance, letterBoxDistance, -center.y + input.letterBoxUV.y) * letterBoxAlpha;
		color = lerp(float4(color.rgb, 1.0), lerp(float4(color.rgb, 1.0), letterBoxColor, bottomColor * letterBoxAlpha * 10.0), letterBoxDistance);
	}
    return color;
}
