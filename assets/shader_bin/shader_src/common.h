#include <shader.h>

float2 mirrorTexCoords(float2 texcoords)
{
	float2 t = frac(texcoords * 0.5) * 2.0;
    float2 length = {1.0, 1.0};
    return length - abs(t - length);
}
