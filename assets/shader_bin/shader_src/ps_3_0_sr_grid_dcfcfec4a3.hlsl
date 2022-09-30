#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

struct PixelShaderInput
{
	float4 position : POSITION;
	float2 uv : TEXCOORD0;
};

float grid(float2 uv, float t)
{
    float2 size = float2(uv.y, uv.y * uv.y * 0.2) * 0.01;
    uv += float2(0.0, gameTime.w * 4.0 * (t + 0.05));
    uv = abs(fract(uv) - 0.5);
 	float2 lines = smoothstep(size, (float2)(0.0), uv);
 	lines += smoothstep(size * 5.0, (float2)(0.0), uv) * 0.4 * t;
    return clamp(lines.x + lines.y, 0.0, 3.0);
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	// (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    float2 uv = 1.0 - (2.0 * input.uv);

    float t = 0.5;
    float fog = smoothstep(0.1, -0.02, abs(uv.y + 0.2));
    float3 col = float3(0.0, 0.0, 0.1);

    if (uv.y < -0.2)
    {
        float2 uvA = uv;
        uvA.y = 2.0 / (abs(uvA.y + 0.2) + 0.05);
        uvA.x *= uvA.y * 0.9;
        float gridVal = grid(uvA, t);
        col = mix(col, float3(0.3, 0.1, 1.0), gridVal);
    }

    col += fog * fog * fog * 0.3;
    col = mix(float3(col.r, col.r, col.r) * 0.5, col, t * 1.5);

    return float4(col, 1.0);
}
