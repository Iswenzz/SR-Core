float grid(vec2 uv, float t)
{
    vec2 size = vec2(uv.y, uv.y * uv.y * 0.2) * 0.01;
    uv += vec2(0.0, iTime * 4.0 * (t + 0.05));
    uv = abs(fract(uv) - 0.5);
 	vec2 lines = smoothstep(size, vec2(0.0), uv);
 	lines += smoothstep(size * 5.0, vec2(0.0), uv) * 0.4 * t;
    return clamp(lines.x + lines.y, 0.0, 3.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;

    float t = 0.5;
    float fog = smoothstep(0.1, -0.02, abs(uv.y + 0.2));
    vec3 col = vec3(0.0, 0.0, 0.1);

    if (uv.y < -0.2)
    {
        vec2 uvA = uv;
        uvA.y = 2.0 / (abs(uvA.y + 0.2) + 0.05);
        uvA.x *= uvA.y * 0.9;
        float gridVal = grid(uvA, t);
        col = mix(col, vec3(0.3, 0.1, 1.0), gridVal);
    }

    col += fog * fog * fog * 0.3;
    col = mix(vec3(col.r, col.r, col.r) * 0.5, col, t * 1.5);

    fragColor = vec4(col, 1.0);
}
