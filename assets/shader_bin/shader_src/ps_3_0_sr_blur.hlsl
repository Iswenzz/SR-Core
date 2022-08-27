#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 color : COLOR;
	float2 uv : TEXCOORD0;
};

float2 rotate(float2 uv, float offset)
{
    float2x2 rot = float2x2(cos(offset), -sin(offset), sin(offset), cos(offset));
    return mul(rot, uv);
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	float4 color = tex2D(colorMapSampler, input.uv);
	const float2 uv = input.uv;
	const float asp = 640.0 / 480.0;
	const float2 center = float2(0.5, 0.5);
	const float twoPi = 6.28318530718f;
	const float halfPi = 1.57079632679f;

	const float blurMode = input.color.x;
	const float blurSamples = 32.0;
	const float blurAmount = input.color.y * 10.0;
	const float blurSpeed = gameTime.x * input.color.z;

	// Radial Blur
	if (blurMode < 0.3)
	{
		float a = 1.0 / blurSamples * blurSpeed;
		for (int i = 0; i < blurSamples; i++)
			color.rgb += tex2D(colorMapSampler, lerp(uv, 0.5, blurAmount / 100 * float(i) * a)).rgb;
		color /= blurSamples + 1.0;
	}
	// Lens Blur
	else if (blurMode < 0.7)
	{
		float ls = 1.0 / blurSamples * blurSpeed;
		for (int j = 0; j < blurSamples; j++)
		{
			float s, c;
			sincos(j * ls * twoPi, s, c);
			c *= asp;
			color.rgb += tex2D(colorMapSampler, uv + 1.0 * float2(s, c) * (blurAmount / 100) * 0.1).rgb;
		}
		color.rgb /= (blurSamples + 1);
	}
	// Rotation Blur
	else if (blurMode < 1.0)
	{
		float is = 1.0 / blurSamples * (blurSpeed * 30);
		for (int j = -blurSamples + 1; j < blurSamples; j++)
		{
			float2 rotateBlurUV = input.uv - center;
			rotateBlurUV.y /= asp;
			rotateBlurUV = rotate(rotateBlurUV, radians(blurAmount / 100 * halfPi * float(j) * is) * 5);
			rotateBlurUV.y *= asp;
			rotateBlurUV += center;
			color += tex2D(colorMapSampler, rotateBlurUV);
		}
		color /= (blurSamples * 2.0 - 1.0) + 1;
	}
	return color;
}
