#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

struct PixelInput
{
	float4 position : POSITION;
	float3 worldpos : TEXCOORD;
	float3 camerapos : TEXCOORD1;
};

struct PixelOutput
{
	float4 color : COLOR;
};

// Shader combined from two other shaders by Leo Gallatin
// USING https://www.shadertoy.com/view/XtBXDw (based on it)

// FILTER_TAP_0
static float3 outscatter_color01 = { 0.859f, 0.654f, 0.362f };	// xyz
static float outscatter_scale01 = 0.61f;						// w
static float4 outscatter1 = float4(outscatter_color01, outscatter_scale01);

// FILTER_TAP_1
static float3 outscatter_color02 = { 1.0f, 1.00f, 1.00f };		// xyz
static float outscatter_scale02 = 15.0f;						// w
static float4 outscatter2 = float4(outscatter_color02, outscatter_scale02);

// FILTER_TAP_2
static float dn_skydome_scale = 80.0f; 		// x
static float dn_cloud_coverage = 0.55f; 	// y
static float dn_cloud_thickness = 10.0f; 	// z
static float dn_cloud_absorbtion = 0.36f; 	// w
static float4 dn_skydome = float4(dn_skydome_scale, dn_cloud_coverage, dn_cloud_thickness, dn_cloud_absorbtion);

// FILTER_TAP_3
static float dn_star_scale	= 0.02f;				// x
static float dn_cloud_step_distance_xz	= 150.0f; 	// y
static float dn_cloud_exposure	= 0.65f; 			// w
static float4 dn_star = float4(dn_star_scale, dn_cloud_step_distance_xz, 0.0, dn_cloud_exposure);

// FILTER_TAP_4
static float3 dn_cloud_wind_vec = { 0.01f, 0.00f, 0.01f };		// xyz
static float dn_cloud_wind_speed = 1.3f;						// w
static float4 dn_wind = float4(dn_cloud_wind_vec, dn_cloud_wind_speed);

// FILTER_TAP_5
static float dn_sky_sun_intensity = 22.0f;							// x
static float3 dn_sky_rayleigh_coeff = { 7.52f, 13.0f, 22.4f };		// yzw
static float4 dn_sun = float4(dn_sky_sun_intensity, dn_sky_rayleigh_coeff);

// FILTER_TAP_6
static float dn_sky_mie_coeff = 7.00f;				// x
static float dn_sky_rayleigh_scale	= 1000.0f;		// y
static float dn_sky_mie_scale = 400.0f;				// z
static float dn_sky_mie_scatter_dir = 0.99f;		// w
static float4 dn_sky_mie = float4(dn_sky_mie_coeff, dn_sky_rayleigh_scale, dn_sky_mie_scale, dn_sky_mie_scatter_dir);

#define SKYDOME_SCALE           1.0f / dn_skydome.x
#define COVERAGE                dn_skydome.y
#define THICKNESS               dn_skydome.z
#define ABSORPTION              dn_skydome.w

#define STEPS                   32
#define STEP_DISTANCE_XZ        dn_star.y
#define STEPS_AFTER_THRESHOLD   STEPS * 0.5
#define EXPOSURE                dn_star.w

#define WIND_VEC                dn_wind.xyz
#define WIND_SPEED              dn_wind.w

// Atmosphere code from: https://github.com/wwwtyro/glsl-atmosphere
// Transferred to Godot by Bastiaan Olij

#define earth_radius_km     6371
#define atmo_radius_km      6471
#define cam_height_m        1.8

#define sun_pos             sunPosition.xzy

#define sun_intensity       dn_sun.x
#define rayleigh_coeff      dn_sun.yzw

#define mie_coeff           dn_sky_mie.x
#define rayleigh_scale      dn_sky_mie.y
#define mie_scale           dn_sky_mie.z
#define mie_scatter_dir     dn_sky_mie.w

//#define SATURATE          0.3

static const float NOISE_GRANULARITY = 0.5/255.0;

inline float3x3 xRotation3dRadians(float rad)
{
	float s = sin(rad);
	float c = cos(rad);

	return float3x3(
		1, 0, 0,
		0, c, s,
		0, -s, c
	);
}

inline float3x3 yRotation3dRadians(float rad)
{
	float s = sin(rad);
	float c = cos(rad);

	return float3x3(
		c, 0, -s,
		0, 1, 0,
		s, 0, c
	);
}

inline float3x3 zRotation3dRadians(float rad)
{
	float s = sin(rad);
	float c = cos(rad);

	return float3x3(
		c, s, 0,
		-s, c, 0,
		0, 0, 1
	);
}

float noise(in float3 x)
{
	x *= 0.01;
	float  z = x.z * 256.0;
	float2 offz = float2(0.317, 0.123);
	float2 uv1 = x.xy + offz * floor(z);
	float2 uv2 = uv1  + offz;

	float4 uv01 = float4(uv1, 0.0, 0.0);
	float4 uv02 = float4(uv2, 0.0, 0.0);

	return mix(tex2Dlod(detailMapSampler, uv01).x, tex2Dlod(detailMapSampler, uv02).x, fract(z));
}

float fbm(float3 pos, float lacunarity)
{
	float3 p = pos;

	// animation
	//p = p - float3(0.0, 1.0, 0.0) * iTime * 0.02;

	float
	t  = 0.51749673 * noise(p); p *= lacunarity;
	t += 0.25584929 * noise(p); p *= lacunarity;
	t += 0.12527603 * noise(p); p *= lacunarity;
	t += 0.06255931 * noise(p);

	return t;
}

float get_noise(float3 x)
{
	float FBM_FREQ = 2.76434;
	return fbm(x, FBM_FREQ);
}

// sky shader interjection
float3 ray_dir_from_uv(float2 uv)
{
	float PI = 3.14159265358979;
	float3 dir;

	float x = sin(PI * uv.y);
	dir.y = cos(PI * uv.y);

	dir.x = x * sin(2.0 * PI * (0.5 - uv.x));
	dir.z = x * cos(2.0 * PI * (0.5 - uv.x));

	return dir;
}

float2 uv_from_ray_dir(float3 dir)
{
	float PI = 3.14159265358979;
	float2 uv;

	uv.y = acos(dir.y) / PI;

	dir.y = 0.0;
	dir = normalize(dir);
	uv.x = acos(dir.z) / (2.0 * PI);

	if (dir.x < 0.0)
		uv.x = 1.0 - uv.x;

	uv.x = 0.5 - uv.x;

	if (uv.x < 0.0)
		uv.x += 1.0;
	return uv;
}

float2 rsi(float3 r0, float3 rd, float sr)
{
	// ray-sphere intersection that assumes
	// the sphere is centered at the origin.
	// No intersection when result.x > result.y

	float a = dot(rd, rd);
	float b = 2.0 * dot(rd, r0);
	float c = dot(r0, r0) - (sr * sr);
	float d = (b*b) - 4.0*a*c;

	if (d < 0.0)
		return float2(100000.0, -100000.0);
	return float2((-b - sqrt(d)) / (2.0 * a), (-b + sqrt(d)) / (2.0 * a));
}

float3 atmosphere(float3 r, float3 r0, float3 pSun, float iSun, float rPlanet, float rAtmos,
	float3 kRlh, float kMie, float shRlh, float shMie, float g)
{
	float PI = 3.14159265358979;
	int iSteps = 16;
	int jSteps = 8;

	// Normalize the sun and view directions.
	pSun = normalize(pSun);
	r = normalize(r);

	// Calculate the step size of the primary ray.
	float2 p = rsi(r0, r, rAtmos);

	if (p.x > p.y)
		return float3(0.0f, 0.0f , 0.0f);

	p.y = min(p.y, rsi(r0, r, rPlanet).x);
	float iStepSize = (p.y - p.x) / float(iSteps);

	// Initialize the primary ray time.
	float kTime = 0.0;

	// Initialize accumulators for Rayleigh and Mie scattering.
	float3 totalRlh = float3(0,0,0);
	float3 totalMie = float3(0,0,0);

	// Initialize optical depth accumulators for the primary ray.
	float iOdRlh = 0.0;
	float iOdMie = 0.0;

	// Calculate the Rayleigh and Mie phases.
	float mu = dot(r, pSun);
	float mumu = mu * mu;
	float gg = g * g;
	float pRlh = 3.0 / (16.0 * PI) * (1.0 + mumu);
	float pMie = 3.0 / (8.0 * PI) * ((1.0 - gg) * (mumu + 1.0)) / (pow(abs(1.0 + gg - 2.0 * mu * g), 1.5) * (2.0 + gg));

	// Sample the primary ray.
	//[loop]
	for (int i = 0; i < iSteps; i++)
	{
		// Calculate the primary ray sample position.
		float3 iPos = r0 + r * (kTime + iStepSize * 0.5);

		// Calculate the height of the sample.
		float iHeight = length(iPos) - rPlanet;

		// Calculate the optical depth of the Rayleigh and Mie scattering for this step.
		float odStepRlh = exp(-iHeight / shRlh) * iStepSize;
		float odStepMie = exp(-iHeight / shMie) * iStepSize;

		// Accumulate optical depth.
		iOdRlh += odStepRlh;
		iOdMie += odStepMie;

		// Calculate the step size of the secondary ray.
		float jStepSize = rsi(iPos, pSun, rAtmos).y / float(jSteps);

		// Initialize the secondary ray time.
		float jTime = 0.0;

		// Initialize optical depth accumulators for the secondary ray.
		float jOdRlh = 0.0;
		float jOdMie = 0.0;

		// Sample the secondary ray.
		//[loop]
		for (int j = 0; j < jSteps; j++)
		{
			// Calculate the secondary ray sample position.
			float3 jPos = iPos + pSun * (jTime + jStepSize * 0.5);

			// Calculate the height of the sample.
			float jHeight = length(jPos) - rPlanet;

			// Accumulate the optical depth.
			jOdRlh += exp(-jHeight / shRlh) * jStepSize;
			jOdMie += exp(-jHeight / shMie) * jStepSize;

			// Increment the secondary ray time.
			jTime += jStepSize;
		}

		// Calculate attenuation.
		float3 attn = exp(-(kMie * (iOdMie + jOdMie) + kRlh * (iOdRlh + jOdRlh)));

		// Accumulate scattering.
		totalRlh += odStepRlh * attn;
		totalMie += odStepMie * attn;

		// Increment the primary ray time.
		kTime += iStepSize;

	}
	// Calculate and return the final color.
	return iSun * (pRlh * kRlh * totalRlh + pMie * kMie * totalMie);
}

float3 render_sky_color(float3 dir)
{
	// determine our sky color
	float3 color = atmosphere(
		dir
		, float3(0.0, earth_radius_km * 100.0 + cam_height_m * 0.1, 0.0)
		, sun_pos
		, sun_intensity
		, earth_radius_km * 100.0
		, atmo_radius_km * 100.0
		, rayleigh_coeff / 100000.0
		, mie_coeff / 100000.0
		, rayleigh_scale
		, mie_scale
		, mie_scatter_dir
	);

	// Apply exposure.
	color = 1.0 - exp(-1.0 * color); //Makes night sky too bright and gross looking...

	//saturate sky
	//float dot_col = dot(float3(0.2126,0.7152,0.0722), color);
	//float3 gray = float3(dot_col, dot_col, dot_col);
	//float3 colorfinal = clamp(float3(mix(color, gray, -SATURATE)) , 0., 1.);
	//return colorfinal;

	return color;
}

bool SphereIntersect(float3 SpPos, float SpRad, float3 ro, float3 rd, out float t, out float3 norm)
{
	ro -= SpPos;

	float A = dot(rd, rd);
	float B = 2.0f * dot(ro, rd);
	float C = dot(ro, ro) - SpRad * SpRad;
	float D = B * B - 4.0f * A * C;

	if (D < 0.0f)
		return false;

	D  = sqrt(D);
	A *= 2.0;

	float t1 = (-B + D) / A;
	float t2 = (-B - D) / A;

	if (t1 < 0.0)
		t1 = t2;

	if (t2 < 0.0)
		t2 = t1;

	t1 = min(t1, t2);

	if (t1 < 0.0)
		return false;

	norm = ro+t1*rd;
	t = t1;

	return true;
}

float density(float3 pos, float3 offset,float t)
{
	float3 p = pos * 0.0212242f + offset;
	float dens = get_noise(p);

	float cov = 1.0f - COVERAGE;
	dens *= smoothstep (cov, cov + 0.05f, dens);

	return clamp(dens, 0.0f, 1.0f);
}

float light(in float3 origin)
{
	const int steps = 8;
	float march_step = 1.0f;

	float3 pos = origin;
	float3 dir_step = sun_pos * march_step;
	float Tx = 1.0f; // transmitance

	float3 wind = float3(gameTime.w * (WIND_VEC.xyz * WIND_SPEED));

	for (int i = 0; i < steps; i++)
	{
		float dens = density(pos, wind, 0.0f);

		float T_i = exp(-ABSORPTION * dens * march_step);
		Tx *= T_i;

		pos += dir_step;
	}
	return Tx;
}

float4 render_clouds(float3 ro, float3 rd)
{
	float3 apos = float3(0, -450.0f, 0);
	float arad = 550.0f;
	float3 wind = float3(gameTime.w * (WIND_VEC.xyz * WIND_SPEED));
	float3 C = float3(0.0f, 0.0f, 0.0f);
	float alpha = 0.0f;

	float3 n;
	float tt;

	if (SphereIntersect(apos, arad, ro, rd, tt, n))
	{
		float thickness = THICKNESS;
		int steps = STEPS;

		float  march_step = thickness / float(steps);

		float3 dir_step = rd / rd.y * march_step;
		float3 pos = n;
		float T = 1.0f;

		int steps_threshold = 0;

		[loop]
		for (int i = 0; i < steps; i++)
		{
			// amount of steps after distance threshold was reached (fade effect)
			if (steps_threshold > int(STEPS_AFTER_THRESHOLD))
				break;

			//float h = float(i) / float(steps);
			float h = float(i) / float(steps);

			float dens = density(pos, wind, h);
			float T_i  = exp(-ABSORPTION * dens * march_step);

			T *= T_i;
			if (T < 0.01)
				break;

			// fakelight (compiler doesnt like that)
			//C += T * (exp(h) / 1.75) * dens * march_step;

			// simulate light (why does that work and the above fails?)
			C += T * light(pos) * dens * march_step;

			alpha += (1.0 - T_i) * (1.0 - alpha);
			pos += dir_step;

			// less detailed / stepped clouds at distance
			if (length(pos.xz) > STEP_DISTANCE_XZ)
			{
				// take half size steps (better fade)
				pos -= (dir_step * 0.5f);
				march_step = thickness / float(steps * 0.5f);

				steps_threshold++;
			}
			if (length(pos) > 800.0f) // 1e3 = 1000
				break;
		}
		C *= EXPOSURE;

		return float4(C, alpha);
	}
	return float4(C, alpha);
}

float dts(float3 camm, float3 poss, float3 center, float radius, float sig)
{
	float returnVal;
	float a = pow((dot(normalize(poss - camm), camm - center)), 2.0) -pow(length(camm - center), 2.0) + pow(radius, 2.0);

	if (a < 0.0)
		return -1.0f;
	return -(dot(normalize(poss - camm), (camm - center))) + sig * sqrt(a);
}

#define CENTER float3(0.0, -63710.0, 0.0)

float sdis(float3 from,float3 to, float3 cam)
{
	float returnVal;

	float3 plac = CENTER - float3(0.0f, 0.0f, 0.0f);
	float  rad = -CENTER.y + (100.0f * dn_skydome.x);

	float a = dts(from, to, plac, rad, -1.0f);
	float b = dts(from, to, plac, rad,  1.0f);

	if (a < 0.0f && b < 0.0f)
		return -1.0f;
	else if (a < 0.0f)
		return b;
	else if (b < 0.0f)
		return a;
	return min(a,b);
}

float random(in float3 _st)
{
	return fract(sin(dot(_st.xyz, float3(12.9898f, 78.233f, 82.19f))) * 43758.5453123f);
}

float starnoise(in float3 _st)
{
	float3 i = floor(_st);
	float3 f = fract(_st);

	// Four corners in 2D of a tile
	float starthreshhold = 0.998;

	float a = float(random(i) > starthreshhold);
	float b = float(random(i + float3(1.0, 0.0,0.0)) > starthreshhold);
	float c = float(random(i + float3(0.0, 1.0,0.0)) > starthreshhold);
	float d = float(random(i + float3(1.0, 1.0,0.0)) > starthreshhold);

	float e = float(random(i + float3(0.0, 0.0,1.0)) > starthreshhold);
	float g = float(random(i + float3(1.0, 0.0,1.0)) > starthreshhold);
	float h = float(random(i + float3(0.0, 1.0,1.0)) > starthreshhold);
	float j = float(random(i + float3(1.0, 1.0,1.0)) > starthreshhold);

	f = (1.0 - cos(f * 3.1415)) / 2.0;

	float a1 = lerp(a, b, f.x);
	float a2 = lerp(c, d, f.x);
	float a3 = lerp(e, g, f.x);
	float a4 = lerp(h, j, f.x);

	float a5 = lerp(a1, a2, f.y);
	float a6 = lerp(a3, a4, f.y);

	return lerp(a5, a6, f.z);
}

float get_night_time(float3 sun_dir, float s, float o)
{
	float night_time = dot(sun_dir, float3(0.0f, 1.0f, 0.0f));
	return clamp(night_time * s + o, -1.0f, 1.0f);
}

float get_night_time_sat(float3 sun_dir, float s, float o)
{
	float night_time = dot(sun_dir, float3(0.0f, 1.0f, 0.0f));
	return saturate(night_time * s + o);
}

PixelOutput ps_main(const PixelInput pixel)
{
	PixelOutput fragment;

	float3 ro = pixel.camerapos.xzy * SKYDOME_SCALE;
	float3 rd = normalize(pixel.worldpos.xzy);

	float3 sky = render_sky_color(rd);
	float4 cld = float4(0.0f, 0.0f, 0.0f, 0.0f);
	float skyPow = dot(rd, float3(0.0f, -1.0f, 0.0f));
	float horizonPow = 1.0f - pow(abs(1.0f - abs(skyPow)), outscatter2.a);

	// slightly compensate lighttweak contrast/brightness
	float compensate_lighttweak_bias = ((-colorBias.r + 1.0f) * 1.5f); // film.brightness + 0.5 - 0.5 * film.contrast

	// scalar for cloud coloring
	float night_time_clouds = get_night_time(-sun_pos, 2.00f, 0.40f);

	// cloud colors
	float3 sunset = outscatter1.rgb; // 0.263, 0.138, 0.059
	float3 day = outscatter2.rgb; // 0.190, 0.180, 0.180
	float3 night = float3(0.0f, 0.0f, 0.0f);

	float3 extinction;
	if (night_time_clouds < -0.0f)
		extinction = lerp(day, sunset, 1 + night_time_clouds);
	else
		extinction = lerp(sunset, night, night_time_clouds);

	if (rd.y > 0.0)
	{
		cld = render_clouds(ro, rd);
		cld = clamp(cld, float4(0.0, 0.0, 0.0, 0.0), float4(1.0, 1.0, 1.0, 1.0));
		cld.rgb += 0.04f * cld.rgb * horizonPow;

		// fade away clouds at the horizon
		cld *= clamp((1.0f - exp(-2.3f * pow(max((0.0), horizonPow), (2.6f)))), 0.0f, 1.0f);

		// day / sunset / night
		cld.rgb *= mix(cld.rgb, extinction * outscatter1.a * 5.0f, min(outscatter1.a, 1.0f) * max(rd.y, 0.0f)); // outscatter1.a = 0.93f
	}

	// night sky - stars
	float3 cam = pixel.camerapos.xzy;
	float3 sky_position = cam + rd * sdis(cam, cam + rd, cam);

	float3 night_sky = float3(0.0f, 0.0f, 0.0f);
	float star = starnoise(sky_position * dn_star.x); // dn_star.x = 0.01f
	float3 star3 = float3(star, star, star);
	star3 *= compensate_lighttweak_bias; // film.brightness + 0.5 - 0.5 * film.contrast //1.8f; // compensate lighttweaks

	float night_time  = get_night_time_sat(-sun_pos, 1.50, 0.75);
	float3 night_time3 = float3(night_time, night_time, night_time);

	// mix nightsky with stars
	night_sky = lerp(night_sky, star3, night_time3);
	// mix nightsky with rayleigh sky
	sky = lerp(sky, night_sky, night_time3 * max(rd.y, 0.35));
	// add clouds
	sky = lerp(sky, cld.rgb / (0.0001 + cld.a), cld.a);

	// sample sky texture or the material will fail to compile
	float3 nullsky = texCUBE(skyMapSampler, pixel.worldpos).xyz;
	nullsky *= 0.0001;

	// the sampled sky texture has to contribute to the final color output in some way
	fragment.color = float4(sky + nullsky, 1.0f);

	// dither the final color to remove color banding (https://shader-tutorial.dev/advanced/color-banding-dithering/)
	fragment.color.rgb += lerp(-NOISE_GRANULARITY, NOISE_GRANULARITY, random(rd));

	return fragment;
}
