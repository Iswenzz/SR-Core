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

vec3 rainbow(float h)
{
	h = mod(mod(h, 1.0) + 1.0, 1.0);
	float h6 = h * 6.0;
	float r = clamp(h6 - 4.0, 0.0, 1.0) +
		clamp(2.0 - h6, 0.0, 1.0);
	float g = h6 < 2.0
		? clamp(h6, 0.0, 1.0)
		: clamp(4.0 - h6, 0.0, 1.0);
	float b = h6 < 4.0
		? clamp(h6 - 2.0, 0.0, 1.0)
		: clamp(6.0 - h6, 0.0, 1.0);
	return vec3(r, g, b);
}

vec3 plasma(PixelShaderInput input)
{
	const float speed = 12.0;
	const float scale = 2.5;

	const float startA = 563.0 / 512.0;
	const float startB = 233.0 / 512.0;
	const float startC = 4325.0 / 512.0;
	const float startD = 312556.0 / 512.0;

	const float advanceA = 6.34 / 512.0 * 18.2 * speed;
	const float advanceB = 4.98 / 512.0 * 18.2 * speed;
	const float advanceC = 4.46 / 512.0 * 18.2 * speed;
	const float advanceD = 5.72 / 512.0 * 18.2 * speed;

	vec2 uv = input.uv * scale / float2(640.0, 480.0);

	float a = startA + gameTime.w * advanceA;
	float b = startB + gameTime.w * advanceB;
	float c = startC + gameTime.w * advanceC;
	float d = startD + gameTime.w * advanceD;

	float n = sin(a + 3.0 * uv.x) +
		sin(b - 4.0 * uv.x) +
		sin(c + 2.0 * uv.y) +
		sin(d + 5.0 * uv.y);

	n = mod(((4.0 + n) / 4.0), 1.0);
	n += tex2D(colorMapSampler, input.uv).r;

	return rainbow(n);
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	vec3 colorMask = input.color.rgb;
	vec3 color = tex2D(colorMapSampler, input.uv).rgb;

	float colorMaskThreshold = 1.0 - (length(color - colorMask) / length(vec3(1, 1, 1)));
	float colorAlpha = clamp((colorMaskThreshold - 0.7) / 0.2, 0.0, 1.0);

	return vec4(color * (1.0 - colorAlpha), 1.0) + vec4(plasma(input) * colorAlpha, 1.0);
}
