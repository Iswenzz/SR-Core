#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

// Half extents of the portal quad in object space, from portal_dummy_*.XMODEL_EXPORT.
#define PORTAL_HALF_WIDTH   35.0
#define PORTAL_HALF_HEIGHT  55.0

// Where the opening stops and the energy lip begins, in normalised ellipse radius. The lip stays
// tight against the boundary so it reads as the edge of the hole; the ring model draws the wider
// glow that sits around it, and a fat lip here just fights with it.
#define APERTURE            0.78
#define LIP                 0.93

// colorTint carries the portal colour; the material sets it per colour variant.
#define PORTAL_COLOR        colorTint.rgb

struct PixelShaderInput
{
	float4 position : POSITION;
	float4 clipPos  : TEXCOORD0;
	float4 clipMid  : TEXCOORD1;
	float3 local    : TEXCOORD2;
	float3 viewDir  : TEXCOORD3;
	float3 normal   : TEXCOORD4;
};

float hash21(float2 p)
{
	return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float valueNoise(float2 p)
{
	float2 i = floor(p);
	float2 f = frac(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = hash21(i);
	float b = hash21(i + float2(1.0, 0.0));
	float c = hash21(i + float2(0.0, 1.0));
	float d = hash21(i + float2(1.0, 1.0));

	return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

// Two octaves is all the rim detail needs, and each one costs four sin-based hashes.
float fbm(float2 p)
{
	return 0.65 * valueNoise(p) + 0.35 * valueNoise(p * 2.17 + 4.12);
}

float2 clipToScreen(float4 clip)
{
	return (clip.xy / clip.w) * float2(0.5, -0.5) + 0.5;
}

float4 ps_main(PixelShaderInput input) : COLOR
{
	// Ellipse inscribed in the quad: r == 1 on the ellipse, up to sqrt(2) in the corners.
	float2 ellipse = input.local.yz / float2(PORTAL_HALF_WIDTH, PORTAL_HALF_HEIGHT);
	float radius = length(ellipse);
	clip(1.0 - radius);

	float time = gameTime.w;

	// Unit direction around the ring, slowly spun. Cheaper than atan2 and it wraps for free.
	float2 dir = ellipse / max(radius, 0.0001);
	float spin = time * 0.45;
	float cs = cos(spin);
	float sn = sin(spin);
	float2 spun = float2(dir.x * cs - dir.y * sn, dir.x * sn + dir.y * cs);

	float swirl = fbm(spun * 3.1 + radius * 2.0);
	float filament = fbm(spun * 9.0 - float2(0.0, time * 0.8));

	float2 uv = clipToScreen(input.clipPos) + 0.5 * float2(texelSizeX, texelSizeY);
	float2 mid = clipToScreen(input.clipMid);
	float2 outward = normalize(uv - mid + float2(0.00001, 0.0));

	// The opening bends light as it approaches the lip and splits it into channels right at
	// the boundary -- the two cues that sell a flat quad as a hole in the wall.
	float bend = smoothstep(0.30, 1.0, radius);
	float shimmer = (swirl - 0.5) * 0.0035 * bend;
	float2 refracted = uv + outward * (bend * bend * 0.022 + shimmer);
	float2 split = outward * (bend * bend * 0.006);

	float3 view;
	view.r = tex2D(colorMapSampler, refracted + split).r;
	view.g = tex2D(colorMapSampler, refracted).g;
	view.b = tex2D(colorMapSampler, refracted - split).b;

	// Grazing angles pick up the portal's own colour, like light caught in the surface.
	float grazing = saturate(1.0 - abs(dot(normalize(input.viewDir), normalize(input.normal))));
	float fresnel = grazing * grazing * grazing;
	view = lerp(view, view * PORTAL_COLOR * 1.35, fresnel * 0.35 + bend * 0.22);

	// Energy ring. With the ring model gone this is the entire rim, so it carries a wide coloured
	// band, a hot white core just inside the boundary, and filaments dragged around it.
	float band = smoothstep(APERTURE, LIP, radius) * (1.0 - smoothstep(LIP, 1.0, radius));
	float core = smoothstep(LIP - 0.05, LIP, radius) * (1.0 - smoothstep(LIP, LIP + 0.04, radius));
	float flicker = 0.78 + 0.22 * valueNoise(float2(dir.x * 3.0, time * 2.2));

	float3 rim = PORTAL_COLOR * (band * (1.15 + 2.3 * filament) + core * 3.4) * flicker;
	rim += core * core * 1.9 * flicker;

	// Fade the opening out under the ring so the two blend instead of meeting at a seam.
	float aperture = 1.0 - smoothstep(APERTURE, LIP, radius);
	float3 color = view * aperture + rim;

	// Alpha rolls off at the ellipse so the quad never shows as a rectangle.
	float alpha = saturate(aperture + band * 1.4 + core * 2.0) * (1.0 - smoothstep(0.985, 1.0, radius));
	return float4(color, alpha * colorTint.a);
}
