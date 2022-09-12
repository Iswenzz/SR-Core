#define PC
#define IS_VERTEX_SHADER 0
#define IS_PIXEL_SHADER 1
#include <common.hlsl>

mat2 mm2(in float a)
{
    float c = cos(a), s = sin(a);
    return mat2(c, s, -s, c);
}

float tri(in float x)
{
    return clamp(abs(fract(x) - .5), 0.01, 0.49);
}

vec2 tri2(in vec2 p)
{
    return vec2(tri(p.x) + tri(p.y), tri(p.y + tri(p.x)));
}

float triNoise2d(in vec2 p, float spd)
{
    mat2 m2 = mat2(0.95534, 0.29552, -0.29552, 0.95534);

    float z = 1.8;
    float z2 = 2.5;
	float rz = 0.;
    p = mul(p, mm2(p.x * 0.06));
    vec2 bp = p;

	for (float i = 0.; i < 3.; i++)
	{
        vec2 dg = tri2(bp * 1.85) * .7;
        dg = mul(dg, mm2(gameTime.w*spd));
        p -= dg / z2;

        bp *= 1.3;
        z2 *= .45;
        z *= .42;
		p *= 1.21 + (rz - 1.0) * .02;

        rz += tri(p.x + tri(p.y)) * z;
        p= mul(p, -m2);
	}
    return clamp(1. / pow(abs(rz * 29.), 1.3), 0., .55);
}

float hash21(in vec2 n)
{
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

vec4 aurora(vec3 ro, vec3 rd)
{
    vec4 col = (vec4)0;
    vec4 avgCol = (vec4)0;

    for (float i = 0.; i < 10; i++) // 50 // 25 good too
    {
        float of = 0.006 * hash21((vec2)rd) * smoothstep(0., 15., i); // ??????????????????
        float pt = ((.8 + pow(abs(i), 1.4) * .002) - ro.y) / (rd.y * 2. + 0.4);
        pt -= of;
    	vec3 bpos = ro + pt * rd;
        vec2 p = bpos.zx;
        float rzt = triNoise2d(p, 0.06);
        vec4 col2 = vec4(0, 0, 0, rzt);
        col2.rgb = (sin(1. - vec3(2.15, -.5, 1.2) + i * 0.043) * 0.5 + 0.5) * rzt;
        avgCol =  mix(avgCol, col2, .5);
        col += avgCol*exp2(-i * 0.065 - 2.5) * smoothstep(0., 5., i);
    }
    col *= (clamp(rd.y*15.+.4,0.,1.));

    return col * 1.8;
}

//-------------------Background and Stars--------------------
// From Dave_Hoskins (https://www.shadertoy.com/view/4djSRW)
vec3 hash33(vec3 p)
{
    p = fract(p * vec3(443.8975,397.2973, 491.1871));
    p += dot(p.zxy, p.yxz + 19.27);
    return fract(vec3(p.x * p.y, p.z * p.x, p.y * p.z));
}

vec3 stars(in vec3 p)
{
    vec3 c = (vec3)0.0;
    float res = renderTargetSize.x * 1.0;

	for (float i = 0.; i < 2.; i++)
    {
        vec3 q = fract(p * (.15 * res)) - 0.5;
        vec3 id = floor(p * (.15 * res));
        vec2 rn = hash33(id).xy;
        float c2 = 1. - smoothstep(0., .6, length(q));
        c2 *= step(rn.x, .0005 + i * i * 0.001);
        c += c2*(mix(vec3(1.0, 0.49, 0.1), vec3(0.75, 0.9, 1.), rn.y) * 0.1 + 0.9);
        p *= 1.3;
    }
    return c * c * .8;
}

vec3 bg(in vec3 rd)
{
    float sd = dot(normalize(vec3(-0.5, -0.6, 0.9)), rd) * 0.5 + 0.5;
    sd = pow(sd, 5.);
    vec3 col = lerp(vec3(0.05, 0.1, 0.2), vec3(0.1, 0.05, 0.2), sd);
    return col * .63;
}

float4 ps_main(float3 worldPos : TEXCOORD) : COLOR
{
    float3 col;

    vec3 p = worldPos.xzy;
    vec3 ro = vec3(1, 0, -6.7); // 0 1 0 looks cool
    vec3 rd = normalize(p);

    float3 brd = rd;
    float fade = smoothstep(0., 0.01, abs(brd.y)) * 0.1 + 0.9;

    col = bg(rd) * fade;

    if (rd.y > 0.)
    {
        float4 aur = smoothstep(0., 1.5, aurora(ro, rd)) * fade;
        col = col * (1. - aur.a) + aur.rgb;
    }
    else if (glowSetup.w != 0.0) // Reflections	163
    {
        rd.y = abs(rd.y);
        col = bg(rd) * fade * 0.6;
        vec4 aur = smoothstep(0.0, 2.5, aurora(ro, rd));
        // col += stars(rd) * 0.1;
        col = col * (1. - aur.a) + aur.rgb;
        vec3 pos = ro + ((0.5 - ro.y) / rd.y) * rd;
        float nz2 = triNoise2d(pos.xz * vec2(.5, .7), 0.);
        col += mix(vec3(0.2, 0.25, 0.5) * 0.08, vec3(0.3, 0.3, 0.5) * 0.7, nz2 * 0.4);
    }

	float4 skycol = vec4(col, 1.0);
	float3 color = texCUBE(skyMapSampler, worldPos).xyz;

    if (sunSpecular.x == 0.0)
        skycol.b *= clamp(sin(gameTime.w * 3.0), 0.25, 1.0);

	return float4((color * 0.0001) + skycol.xyz, 0.0f);
}
