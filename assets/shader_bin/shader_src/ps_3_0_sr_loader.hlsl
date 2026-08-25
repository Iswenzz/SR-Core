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

float4 ps_main(PixelShaderInput input) : COLOR
{
	const float PI = 3.1415;

	float radius = 0.4;
	float lineWidth = 50.0;
	float glowSize = 20.0;

    float pixelSize = 1.0 / min(640, 480);
	lineWidth *= pixelSize;
	glowSize *= pixelSize;
    glowSize *= 2.0;

    float2 uv = (input.uv / 1) - 0.5;

    float len = length(uv);
	float angle = atan2(uv.y, uv.x);
	float fallOff = frac(-0.5 * (angle / PI) - gameTime.w * 0.8);

    lineWidth = (lineWidth - pixelSize) * 0.5 * fallOff;
	float circle = smoothstep(pixelSize, 0.0, abs(radius - len) - lineWidth) * fallOff;
	circle += smoothstep(glowSize * fallOff, 0.0, abs(radius - len) - lineWidth) * fallOff * 0.5;

	return circle * input.color;
}
