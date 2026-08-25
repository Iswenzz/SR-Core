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

void rotate(inout float2 p, float a)
{
	p = cos(a) * p + sin(a) * float2(p.y, -p.x);
}

float circle(float2 p, float r)
{
    return (length(p / r) - 1.0) * r;
}

float rand(float2 c)
{
	return frac(sin(dot(c.xy, float2(12.9898, 78.233))) * 43758.5453);
}

void bokehLayer(inout float3 color, float2 p, float3 c)
{
    float w = 400.0;

    if (fmod(floor(p.y / w + 0.5), 2.0) == 0.0)
        p.x += w * 0.5;

    float2 p2 = fmod(p + 0.5 * w, w) - 0.5 * w;
    float2 cell = floor(p / w + 0.5);
    float cellR = rand(cell);

    c *= frac(cellR * 3.33 + 3.33);
    float radius = lerp(30.0, 70.0, frac(cellR * 7.77 + 7.77));
    p2.x *= lerp(0.9, 1.1, frac(cellR * 11.13 + 11.13));
    p2.y *= lerp(0.9, 1.1, frac(cellR * 17.17 + 17.17));

    float sdf = circle(p2, radius);
    float circle = 1.0 - smoothstep(0.0, 1.0, sdf * 0.04);
    float glow = exp(-sdf * 0.025) * 0.3 * (1.0 - circle);
    color += c * (circle + glow);
}

float3 frame(float b, float2 tc, float3 col)
{
    tc = -1.0 + 2.0 * tc;
    float m = max(abs(tc.x), abs(tc.y));
    m = smoothstep(1.0 - b, 1.0 - b + 0.01, m);

    return m * col;
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	float2 aspect = float2(640.0 / 480.0, 0.6);
    float2 uv = input.uv;
	float2 p = (uv * aspect) * 200.0;

	float3 color = input.color.xyz;
    float time = sin(gameTime.w / 10.0) * 15.0;

    rotate(p, 0.2 + time * 0.03);
    bokehLayer(color, p + float2(-50.0 * time + 0.0, 0.0), 3.0 * float3(0.3, 0.2, 1.0));
	rotate(p, 0.3 - time * 0.05);
    bokehLayer(color, p + float2(-70.0 * time + 33.0, -33.0), 3.0 * float3(0.5, 0.2, 1.0));
	rotate(p, 0.5 + time * 0.07);
    bokehLayer(color, p + float2(-60.0 * time + 55.0, 55.0), 3.0 * float3(0.2, 0.1, 0.8));
    rotate(p, 0.9 - time * 0.03);
    bokehLayer(color, p + float2(-25.0 * time + 77.0, 77.0), 2.0 * float3(0.1, 0.1, 0.1));
    rotate(p, 0.0 + time * 0.05);
    bokehLayer(color, p + float2(-15.0 * time + 99.0, 99.0), 2.0 * float3(0.1, 0.1, 0.1));

    color += frame(0.01, uv, input.color.xyz);
	return float4(color, input.color.w);
}
