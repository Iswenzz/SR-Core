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

static float3 _GridColor = float3(0.2, 0.05, 1);
static const int _HueShift = 0;
static const float _RGBCycleSpeed = 0.5;
static const int _Iterations = 70;
static const float _LineWidth = 0.2;
static const int _LineCountX = 35;
static const int _LineCountY = 17;
static const int _Speed = 3;

static const int _SunSize = 1;
static const int _SunLines = 35;
static const float3 _TopColor = float3(1, 1.1, 0);
static const float3 _BaseColor = float3(4, 0, 0.2);
static const float3 _GlowColor = float3(1.5, 0.3, 1.2);

static const float _FlickerIntensity = 0.1;
static const int _FlickerFreq = 1400;
static const int _FlickerSpeed = 30;

float smin(float a, float b, float k)
{
	float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
	return lerp(b, a, h) - k * h * (1.0 - h);
}

float noise(float2 seed)
{
	return frac(sin(dot(seed, float2(12.9898, 4.1414))) * 43758.5453);
}

float getHeight(float2 uv)
{
	float time = gameTime.w;
	uv += 0.5;
	uv.y -= time * _Speed;

	float y1 = floor(uv.y);
	float y2 = floor(uv.y + 1);
	float x1 = floor(uv.x) ;
	float x2 = floor(uv.x + 1);
	float iX1 = lerp(noise(float2(x1, y1)), noise(float2(x2, y1)), frac(uv.x));
	float iX2 = lerp(noise(float2(x1, y2)), noise(float2(x2, y2)), frac(uv.x));
	return lerp(iX1, iX2, frac(uv.y));
}

float getDistance(float3 p)
{
	return p.z - (1 - cos(p.x * 15)) * 0.03 * getHeight(float2(p.x * _LineCountX, p.y * _LineCountY));
}

float getGridColor(float2 uv)
{
	float time = gameTime.w;
	float zoom = 1, col;
	float3 cam = float3(0, 1, 0.1), fwd = normalize(-cam), u = normalize(cross(fwd, float3(1, 0, 0))),
		r= cross(u, fwd), c = cam + fwd * zoom, i = c + r * uv.x + u * uv.y, ray = normalize(i - cam);

	float distSur, distOrigin = 0;

	float3 p = cam;
	for(int i = 0; i < _Iterations; i++)
	{
		distSur = getDistance(p);

		if(distOrigin > 2) break;
		if(distSur < 0.001)
		{
			float lineW = _LineWidth * distOrigin;
			float xLines = smoothstep(lineW, 0, abs(frac(p.x * _LineCountX) - 0.5));
			float yLines = smoothstep(lineW * 2, 0, abs(frac(p.y * _LineCountY - time * _Speed) - 0.5));
			col += max(xLines, yLines);
			break;
		}

		p += ray * distSur;
		distOrigin += distSur;
	}

	return max(0, col - (distOrigin * 0.8));
}

float3 hue2rgb(float hue)
{
	hue = frac(hue); // only use fractional part of hue, making it loop
	float r = abs(hue * 6 - 3) - 1;
	float g = 2 - abs(hue * 6 - 2);
	float b = 2 - abs(hue * 6 - 4);
	float3 rgb = float3(r, g, b);
	rgb = saturate(rgb);
	return rgb;
}

float3 hsv2rgb(float3 hsv)
{
	float3 rgb = hue2rgb(hsv.x);
	rgb = lerp(1, rgb,  hsv.y);
	rgb *= hsv.z;
	return rgb;
}

float3 rgb2hsv(float3 rgb)
{
	float maxComponent = max(rgb.r, max(rgb.g, rgb.b));
	float minComponent = min(rgb.r, min(rgb.g, rgb.b));
	float diff = maxComponent - minComponent;
	float hue = 0;

	if(maxComponent == rgb.r)
		hue = 0+(rgb.g - rgb.b) / diff;
	else if(maxComponent == rgb.g)
		hue = 2+(rgb.b - rgb.r) / diff;
	else if(maxComponent == rgb.b)
		hue = 4 + (rgb.r - rgb.g) / diff;

	hue = frac(hue / 6);
	float saturation = diff / maxComponent;
	float value = maxComponent;

	return float3(hue, saturation, value);
}

PixelOutput ps_main(const PixelInput pixel)
{
	PixelOutput fragment;

	float3 rd = normalize(pixel.worldpos.xzy);
	float2 uv = rd.xy; // Wrong coordinates

	float time = gameTime.w;
	float3 resolution = 1;
	float val = 0;
	float sunHeight = sin(time * 0.1) * 0.1 + 0.1;
	uv.y -= sunHeight;

	float dist = _SunSize * length(uv - 0.5);
	float divisions = _SunLines;
	float pattern = (sin(uv.y * divisions * 10 - time * 2) * 1.2 + uv.y * 8.3) * uv.y - 1.5 + sin(uv.x * 20 + time * 5) * 0.01;
	float sunOutline = smoothstep(0, -0.0315, max(dist - 0.315, -pattern));
	float3 c = sunOutline * lerp(_BaseColor, _TopColor, uv.y);
	float glow = max(0, 1 - dist * 1.25);

	glow = min(pow(glow, 3), 0.325);
	c += glow * _GlowColor * 1.1;
	uv -= 0.5;
	uv.y += sunHeight + 0.18;

	if (uv.y < 0.1)
	{
		float3 hsv = rgb2hsv(_GridColor);
		hsv.x += pixel.worldpos.y + gameTime.w * _RGBCycleSpeed;
		_GridColor = lerp(_GridColor, hsv2rgb(hsv), _HueShift);
		c += getGridColor(uv) * 4 * _GridColor;
	}

	float p = 0.1;
	fragment.color = (1.3 + sin(time * _FlickerSpeed + uv.y * _FlickerFreq) * _FlickerIntensity) * float4(c, 1);
	float scanline = smoothstep(1 - 0.2 / _FlickerFreq, 1, sin(time * _FlickerSpeed * 0.1 + uv.y * 4));
	fragment.color *= scanline * 0.2 + 1;

	return fragment;
}
