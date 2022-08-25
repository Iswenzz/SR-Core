#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
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

float4 hash42(float2 p)
{
	float4 p4 = fract(float4(p.xyxy) * float4(443.8975, 397.2973, 491.1871, 470.7827));
    p4 += dot(p4.wzxy, p4 + 19.19);
    return fract(float4(p4.x * p4.y, p4.x * p4.z, p4.y * p4.w, p4.x * p4.w));
}


float tapeHash(float n)
{
    return fract(sin(n) * 43758.5453123);
}

float tapeNoise3D(in float3 x)
{
    float3 p = floor(x);
    float3 f = fract(x);

    f = f * f * (2.0 * f);

    float n = p.x + p.y * 57.0 + 113.0 * p.z;
    return mix(tapeHash(n), tapeHash(n),f.x);
}

float tapeNoise(float2 p)
{
    float y = p.y;
    float s = iTime * 0.01;

    float v = (tapeNoise3D(float3(y * 0.1 + s, 1.0, 1.0)))
          	 *(tapeNoise3D(float3(y * 0.1 + 1000.0 + s, 2.0, 1.0)))
          	 *(tapeNoise3D(float3(y * 0.5 + 420.0 + s, 2.0, 1.0)));

   	v *= hash42(float2(p.x + iTime * 0.01, p.y)).x + 0.3 ;

	if (v < 0.9999)
        v = 0.0;
    return v;
}

float3 rgb2yiq(float3 rgb)
{
	return mul(mat3(0.299, 0.596, 0.211, 0.587, -0.274, -0.523, 0.114, -0.322, 0.312), rgb);
}

float3 yiq2rgb(float3 yiq)
{
	return mul(mat3(1.000, 1.000, 1.000, 0.956, -0.272, -1.106, 0.621, -0.647, 1.703), yiq);
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	const float colorOffsetIntensity = 0.2;

	float2 uv = input.uv;
    float2 offsetR = float2(0.006 * sin(gameTime.w), 0.0) * colorOffsetIntensity;
    float2 offsetG = float2(0.0073 * (cos(gameTime.w * 0.97)), 0.0) * colorOffsetIntensity;

	// Glitch
    float r = tex2D(colorMapSampler, uv + offsetR).r;
    float g = tex2D(colorMapSampler, uv + offsetG).g;
    float b = tex2D(colorMapSampler, uv).b;
	float4 color = float4(r, g, b, 1.0);

	// Grain
	float strength = 20.0;
    float x = (uv.x + 4.0) * (uv.y + 4.0) * (gameTime.w * 10.0);
	float grain = fmod((fmod(x, 13.0) + 1.0) * (fmod(x, 123.0) + 1.0), 0.01) - 0.005;
    float4 grainColor = (float4)grain * strength;
	color += grainColor;

	// Tape
    color += tapeNoise(floor(uv * float2(640, 480)));

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

	// YIQ
	color.rgb = rgb2yiq(color.rgb);
    color.rgb = float3(0.1, -0.1, 0.0) + float3(0.9, 1.1, 1.5) * color.rgb;
    color.rgb = yiq2rgb(color.rgb);

    return color;
}
