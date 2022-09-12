#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

struct PixelInput
{
	float4 position : POSITION;
	float3 worldpos : TEXCOORD;
};

struct PixelOutput
{
	float4 color : COLOR;
};

#define R3 1.732051

float4 HexCoords(float2 uv)
{
    float2 s = float2(1, R3);
    float2 h = .5 * s;
    float2 gv = s * uv;

    float2 a = mod(gv, s) - h;
    float2 b = mod(gv + h, s) - h;

    float2 ab = dot(a, a) < dot(b, b) ? a : b;
    float2 st = ab;
    float2 id = gv - ab;

	st = ab;
    return float4(st, id);
}

float GetSize(float2 id, float seed)
{
    float d = length(id);
    float t = gameTime.w * .5;
    float a = sin(d * seed + t) + sin(d * seed * seed * 10. + t * 2.);
    return a / 2. + .5;
}

mat2 Rot(float a)
{
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

float Hexagon(float2 uv, float r, float2 offs)
{
    uv = mul(uv, Rot(mix(0., 3.1415, r)));

    r /= 1. / sqrt(2.);
    uv = float2(-uv.y, uv.x);
    uv.x *= R3;
    uv = abs(uv);

    float2 n = normalize(float2(1,1));
    float d = dot(uv, n) - r;
    d = max(d, uv.y - r * .707);
    d = smoothstep(.06, .02, abs(d));
    d += smoothstep(.1, .09, abs(r - .5)) * sin(gameTime.w);
    return d;
}

float Xor(float a, float b)
{
	return a + b;
}

float Layer(float2 uv, float s)
{
    float4 hu = HexCoords(uv * 2.);

    float d = Hexagon(hu.xy, GetSize(hu.zw, s), (float2)(0));
    float2 offs = float2(1, 0);

    d = Xor(d, Hexagon(hu.xy - offs, GetSize(hu.zw + offs, s), offs));
    d = Xor(d, Hexagon(hu.xy + offs, GetSize(hu.zw - offs, s), -offs));
    offs = float2(.5, .8725);

    d = Xor(d, Hexagon(hu.xy - offs, GetSize(hu.zw + offs, s), offs));
    d = Xor(d, Hexagon(hu.xy + offs, GetSize(hu.zw - offs, s), -offs));
    offs = float2(-.5, .8725);

    d = Xor(d, Hexagon(hu.xy - offs, GetSize(hu.zw + offs, s), offs));
    d = Xor(d, Hexagon(hu.xy + offs, GetSize(hu.zw - offs, s), -offs));

    return d;
}

float N(float p)
{
    return fract(sin(p * 123.34) * 345.456);
}

float3 Col(float p, float offs)
{
    float n = N(p) * 1234.34;
    return sin(n * float3(12.23, 45.23, 56.2) + offs * 3.) * .5 + .5;
}

float3 GetRayDir(float2 uv, float3 p, float3 lookat, float zoom)
{
    float3 f = normalize(lookat - p),
        r = normalize(cross(float3(0, 1, 0), f)),
        u = cross(f, r),
        c = p + f * zoom,
        i = c + uv.x * r + uv.y * u,
        d = normalize(i - p);
    return d;
}

PixelOutput ps_main(const PixelInput pixel)
{
	PixelOutput fragment;

	float2 uv = (pixel.worldpos.xz / pixel.worldpos.y) / 2.0;
    float duv= dot(uv, uv);

    float t = (gameTime.w * .2 * 10. + 5.) * 0.3;

    float y = sin(t * .5);
    float3 ro = float3(0, 20. * y, -5);
    float3 lookat = float3(0, 0, -10);
    float3 rd = GetRayDir(uv, ro, lookat, 1.);

    float3 col = (float3)(0);

    float3 p = ro + rd * (ro.y / rd.y);
    float dp = length(p.xz);

    if ((ro.y / rd.y) > 0.)
    	col *= 0.;
    else
	{
        uv = p.xz * .1;
        uv *= mix(1., 5., sin(t * .5) * .5 + .5);
        uv = mul(uv, Rot(t));
        uv.x *= R3;

        for (float i = 0.; i < 1.; i += 1. / 3.)
		{
            float id = floor(i + t);
            float tt = fract(i + t);
            float z = mix(5., .1, tt);
            float fade = smoothstep(0., .3, tt) * smoothstep(1., .7, tt);

            col += fade * tt * Layer(uv * z, N(i + id)) * Col(id, duv);
        }
    }
    col *= 2.;

    if (ro.y < 0.)
		col = 1. - col;

    col *= smoothstep(18., 5., dp);
    col *= 1. - duv * 2.;
    fragment.color = float4(col, 1.0);

	return fragment;
}
