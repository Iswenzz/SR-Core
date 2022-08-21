#include <shader.h>

float2 mirrorTexCoords(float2 texcoords)
{
	float2 t = frac(texcoords * 0.5) * 2.0;
    float2 length = {1.0, 1.0};
    return length - abs(t - length);
}

// Unpack fixed integer uv coordinates
float2 computeTextureUV(const float4 uv)
{
	// Fixed-point integer texcoords to float :: int / 2^10 does the same as int >> 10
    float4 fixedCoords = float4(uv.zx / exp2(10), uv.zx / exp2(15))
		+ float4(uv.wy / exp2(2),  uv.wy / exp2(7));

    float4 fractionalParts = frac(fixedCoords);
    float4 setup;

	setup.xy = fractionalParts.xy * -0.03125 + fractionalParts.zw;
	setup.zw = fixedCoords.zw + -fractionalParts.zw;
	setup = setup * float4(32, 32, -2, -2) + float4(-15, -15, 1, 1);
	setup.zw = setup.zw * fractionalParts.xy + setup.zw;

    return setup.zw * exp2(setup.xy);
}

// Unpack packed vertex normals
float4 computeNormal(const float4 normal)
{
    // Unpack normals
    float3 unpackedNormal = normal.xyz * (1.0f / 127.0f) + float3(-1.0f, -1.0f, -1.0f);
    unpackedNormal *= (normal.w * (1.0f / 255.0f) + (1.0f / 1.328f));

    // Return without fog (.w = 1.0)
    float4 worldNormal = mul(unpackedNormal, worldMatrix);
   	worldNormal.w  = 1.0f;

    return worldNormal;
}

// Calculate fog using world-transformed vertices
float computeFog(const float4 worldPosition)
{
    float fog = sqrt(dot(worldPosition.xyz, worldPosition.xyz)) * fogConsts.z + fogConsts.w;
    fog *= 1.442695f;
    return exp2(saturate(fog));
}
