#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

float random2d(float2 n)
{
    return fract(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
}

float randomRange(in float2 seed, in float min, in float max)
{
	return min + random2d(seed) * (max - min);
}

float insideRange(float v, float bottom, float top)
{
   return step(bottom, v) - step(top, v);
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	float AMT = input.color.x;
	float SPEED = input.color.y;

	float time = floor(gameTime.w * SPEED * 60.0);
	float2 uv = input.uv;
    float3 color = tex2D(colorMapSampler, uv).rgb;

    // Randomly offset slices horizontally
    float maxOffset = AMT / 2.0;
	float i = (10.0 * AMT) - 1.0;

    float sliceY = random2d(float2(time, 2345.0 + float(i)));
	float sliceH = random2d(float2(time, 9035.0 + float(i))) * 0.25;
	float hOffset = randomRange(float2(time, 9625.0 + float(i)), -maxOffset, maxOffset);

	float2 uvOff = uv;
	uvOff.x += hOffset;

	if (insideRange(uv.y, sliceY, fract(sliceY + sliceH)) == 1.0)
		color = tex2D(colorMapSampler, uvOff).rgb;

    // Do slight offset on one entire channel
    float maxColOffset = AMT / 6.0;
    float rnd = random2d(float2(time , 9545.0));
    float2 colOffset = float2(randomRange(float2(time, 9545.0), -maxColOffset, maxColOffset),
		randomRange(float2(time, 7205.0), -maxColOffset, maxColOffset));

    if (rnd < 0.33)
        color.r = tex2D(colorMapSampler, uv + colOffset).r;
	else if (rnd < 0.66)
        color.g = tex2D(colorMapSampler, uv + colOffset).g;
    else
        color.b = tex2D(colorMapSampler, uv + colOffset).b;

	return float4(color, 1.0);
}
