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

// https://iquilezles.org/articles/spherefunctions/
float shpIntersect(in float3 ro, in float3 rd, in float4 sph)
{
	float3 oc = ro - sph.xyz;
	float b = dot(rd, oc);
	float c = dot(oc, oc) - sph.w * sph.w;
	float h = b * b - c;
	if(h > 0.0) h = -b - sqrt(h);
	return h;
}

// https://iquilezles.org/articles/spherefunctions/
float sphDistance(in float3 ro, in float3 rd, in float4 sph)
{
	float3 oc = ro - sph.xyz;
	float b = dot(oc, rd);
	float h = dot(oc, oc) - b * b;
	return sqrt(max(0.0, h)) - sph.w;
}

// https://iquilezles.org/articles/spherefunctions/
float sphSoftShadow(in float3 ro, in float3 rd, in float4 sph, in float k)
{
	float3 oc = sph.xyz - ro;
	float b = dot(oc, rd);
	float c = dot(oc, oc) - sph.w * sph.w;
	float h = b * b - c;
	return (b < 0.0) ? 1.0 : 1.0 - smoothstep(0.0, 1.0, k * h / b);
}

// https://iquilezles.org/articles/spherefunctions/
float3 sphNormal(in float3 pos, in float4 sph)
{
	return (pos - sph.xyz) / sph.w;
}

float3 fancyCube(sampler tex, in float3 d, in float s, in float b)
{
	float3 colx = tex2D(tex, 0.5 + s * d.yz / d.x).xyz;
	float3 coly = tex2D(tex, 0.5 + s * d.zx / d.y).xyz;
	float3 colz = tex2D(tex, 0.5 + s * d.xy / d.z).xyz;
	float3 n = d * d;
	return (colx * n.x + coly * n.y + colz * n.z) / (n.x + n.y + n.z);
}

float2 hash(float2 p)
{
	p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
	return frac(sin(p) * 43758.5453);
}

float2 voronoi(in float2 x)
{
	float2 n = floor(x);
	float2 f = frac(x);

	float3 m = (float3)(8.0);
	for(int j = -1; j <= 1; j++)
	{
		for(int i =- 1; i <= 1; i++)
		{
			float2 g = float2(float(i), float(j));
			float2 o = hash(n + g);
			float2 r = g - f + o;
			float d = dot(r, r);
			if(d < m.x) m = float3(d, o);
		}
	}
	return float2(sqrt(m.x), m.y + m.z);
}

float3 background(in float3 d, in float3 l)
{
	float3 col = (float3)(0.0);
		 col += 0.5 * pow(fancyCube(detailMapSampler, d, 0.05, 5.0).zyx, (float3)(2.0));
		 col += 0.2 * pow(abs(fancyCube(detailMapSampler, d, 0.10, 3.0).zyx), (float3)(1.5));
		 col += 0.8 * float3(0.80, 0.5, 0.6) * pow(fancyCube(detailMapSampler, d, 0.1, 0.0).xxx, (float3)(6.0));
	float stars = smoothstep(0.3, 0.7, fancyCube(detailMapSampler, d, 0.91, 0.0).x);

	float3 n = abs(d);
	n = n * n * n;

	float2 vxy = voronoi(50.0 * d.xy);
	float2 vyz = voronoi(50.0 * d.yz);
	float2 vzx = voronoi(50.0 * d.zx);
	float2 r = (vyz * n.x + vzx * n.y + vxy * n.z) / (n.x + n.y + n.z);
	col += 0.5 * stars * clamp(1.0 - (3.0 + r.y * 5.0) * r.x, 0.0, 1.0);

	col = 1.5 * col - 0.2;
	col += float3(-0.05, 0.1, 0.0);

	float s = clamp(dot(d,l), 0.0, 1.0);
	col += 0.4 * pow(s, 5.0) * float3(1.0, 0.7, 0.6) * 2.0;
	col += 0.4 * pow(s, 64.0) * float3(1.0, 0.9, 0.8) * 2.0;

	return col;
}

static const float4 sph1 = float4(0.0, 0.0, 0.0, 1.0);

float rayTrace(in float3 ro, in float3 rd)
{
	return shpIntersect(ro, rd, sph1);
}

float map(in float3 pos)
{
	float2 r = pos.xz - sph1.xz;
	float h = 1.0 - 2.0 / (1.0 + 0.3 * dot(r, r));
	return pos.y - h;
}

float rayMarch(in float3 ro, in float3 rd, float tmax)
{
	float t = 0.0;

	// Bounding plane
	float h = (1.0 - ro.y) / rd.y;
	if(h > 0.0) t = h;

	// Raymarch
	for(int i=0; i<20; i++)
	{
		float3 pos = ro + t * rd;
		float h = map(pos);
		if(h < 0.001 || t > tmax) break;
		t += h;
	}
	return t;
}

float3 render(in float3 ro, in float3 rd)
{
	float3 lig = normalize(float3(1.0, 0.2, 1.0));
	float3 col = background(rd, lig);

	// raytrace stuff
	float t = rayTrace(ro, rd);

	if(t>0.0)
	{
		float3 mat = (float3)(0);
		float3 pos = ro + t * rd;
		float3 nor = sphNormal(pos, sph1);

		float am = 0.1 * gameTime.w;
		float2 pr = float2(cos(am), sin(am));
		float3 tnor = nor;
		tnor.xz = mul(float2x2(pr.x, -pr.y, pr.y, pr.x), tnor.xz);

		float am2 = 0.08 * gameTime.w - 1.0 * (1.0 - nor.y * nor.y);
		pr = float2(cos(am2), sin(am2));
		float3 tnor2 = nor;
		tnor2.xz = mul(float2x2(pr.x, -pr.y, pr.y, pr.x), tnor2.xz);

		float3 ref = reflect(rd, nor);
		float fre = clamp(1.0 + dot(nor, rd), 0.0, 1.0);

		float l = fancyCube(detailMapSampler, tnor, 0.03, 0.0).x;
		l += -0.1 + 0.3 * fancyCube(detailMapSampler, tnor, 8.0, 0.0).x;

		float los = smoothstep(0.45, 0.46, l);

		float3 wrap = -1.0 + 2.0 * fancyCube(detailMapSampler, tnor2.xzy, 0.025, 0.0).xyz;
		float cc1 = fancyCube(detailMapSampler, tnor2 + 0.2 * wrap, 0.05, 0.0).y;

		float dif = clamp(dot(nor, lig), 0.0, 1.0);
		float3 lin  = float3(3.0, 2.5, 2.0) * dif;
		lin += 0.01;
		col = mat * lin;
		col = pow(col, (float3)(0.4545));
		col += 0.6 * fre * fre * float3(0.9, 0.9, 1.0)*(0.3 + 0.7 * dif);

		float spe = clamp(dot(ref, lig), 0.0, 1.0);
		float tspe = pow(spe, 3.0) + 0.5 * pow(spe, 16.0);
		col += (1.0 - 0.5 * los) * clamp(1.0 - 2.0, 0.0, 1.0) * 0.3 * float3(0.5, 0.4, 0.3) * tspe * dif;
	}

	// Raymarch
	float tmax = 20.0;
	if(t > 0.0) tmax = t;
	t = rayMarch(ro, rd, tmax);

	if(t < tmax)
	{
		float3 pos = ro + t * rd;
		float2 scp = sin(2.0*6.2831*pos.xz);

		float3 wir = (float3)(0.0);
		wir += 1.0 * exp(-12.0 * abs(scp.x));
		wir += 1.0 * exp(-12.0 * abs(scp.y));
		wir += 0.5 * exp(-4.0 * abs(scp.x));
		wir += 0.5 * exp(-4.0 * abs(scp.y));
		wir *= 0.2 + 1.0 * sphSoftShadow(pos, lig, sph1, 4.0);

		col += wir * 0.5 * exp(-0.05 * t * t);
	}

	// Outter glow
	if(dot(rd, sph1.xyz - ro) > 0.0)
	{
		float d = sphDistance(ro, rd, sph1);
		float3 glo = (float3)(0.0);
		glo += float3(0.6, 0.7, 1.0) * 0.3 * exp(-2.0 * abs(d)) * step(0.0, d);
		glo += 0.6 * float3(0.6, 0.7, 1.0) * 0.3 * exp(-8.0 * abs(d));
		glo += 0.6 * float3(0.8, 0.9, 1.0) * 0.4 * exp(-100.0 * abs(d));
		col += glo * 1.5;
	}

	col *= smoothstep(0.0, 6.0, gameTime.w);
	return col;
}

float3x3 setCamera(in float3 ro, in float3 rt, in float cr)
{
	float3 cw = normalize(rt - ro);
	float3 cp = float3(sin(cr), cos(cr), 0.0);
	float3 cu = normalize(cross(cw, cp));
	float3 cv = normalize(cross(cu, cw));
	return float3x3(cu, cv, -cw);
}

PixelOutput ps_main(const PixelInput pixel)
{
	PixelOutput fragment;

    float3 col = (float3)(0.0);
	float3 nuv = pixel.worldpos.xzy;
	float3 p = 2 * nuv - 1;

    float zo = 1.0 + smoothstep(5.0, 15.0, abs(gameTime.w - 48.0));
    float an = 3.0 + 0.05 * gameTime.w + 6.0;
    float3 ro = zo * float3(2.0 * cos(an), 1.0, 2.0 * sin(an));
    float3 rt = float3(0.0, 0.0, 0.0);
    float3x3 cam = setCamera(ro, rt, 0);
    float3 rd = normalize(mul(cam, p));

	col += render(ro, rd);

	fragment.color = float4(col, 1.0);
	return fragment;
}
