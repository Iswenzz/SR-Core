#define PC
#define IS_VERTEX_SHADER 1
#define IS_PIXEL_SHADER 0
#include <common.hlsl>

struct VertexShaderInput
{
	float4 position : POSITION;
	float4 uv : TEXCOORD0;
};

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
};

float2 atlasSize;

PixelShaderInput vs_main(VertexShaderInput input)
{
	PixelShaderInput output;
	output.position = mul(float4(input.position.xyz, 1.0f), worldViewProjectionMatrix);

	const int SPRITE_COLUMNS = int(atlasSize.x);
	const int SPRITE_ROWS = int(atlasSize.y);
	const int NUM_OF_SPRITES = SPRITE_COLUMNS * SPRITE_ROWS;
	const int speed = 15;

	int index = int(gameTime.w * speed) % NUM_OF_SPRITES;
	int2 pos = int2(index % SPRITE_COLUMNS, index / SPRITE_COLUMNS);
	float2 uv = computeTextureUV(input.uv);

	output.uv = float2(
		(uv.x / SPRITE_COLUMNS) + pos.x * (1.0 / SPRITE_COLUMNS),
        (uv.y / SPRITE_ROWS) + pos.y * (1.0 / SPRITE_ROWS));

	return output;
}
