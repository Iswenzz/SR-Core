#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
};

// Quake puts an overbright ramp over the whole frame, which CoD4 does not, so
// the same texture lands far darker here: measured against a recording, Quake
// draws the haste bolt at 249,242,9 where the brightest part of its own sphere
// map is only 190,153,47. This is that ramp, folded into the one surface that
// needs it rather than the whole scene.
static const float OVERBRIGHT = 1.6f;

// The stage Quake draws is "rgbGen identity" over the sphere map and nothing
// else, so the texture is the surface. Whether it replaces what is under it or
// adds to it is the technique's state, not this.
float4 ps_main(PixelShaderInput input) : COLOR
{
	float4 colour = tex2D(colorMapSampler, input.uv);
	return float4(saturate(colour.rgb * OVERBRIGHT), colour.a);
}
