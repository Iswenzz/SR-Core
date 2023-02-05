#include sr\utils\_common;

// All the matrix shit cause IW cant make a working function
localToWorldCoordinates(vec, angles)
{
	if (vec == (0, 0, 0))
		return (0, 0, 0);
	M = [];
	M[0] = [];
	M[1] = [];
	M[2] = [];

	a = anglesToForward(angles);
	b = anglesToRight(angles) * -1;
	c = vectorProd(a, b);

	M[0][0] = a[0];
	M[0][1] = a[1];
	M[0][2] = a[2];
	M[1][0] = b[0];
	M[1][1] = b[1];
	M[1][2] = b[2];
	M[2][0] = c[0];
	M[2][1] = c[1];
	M[2][2] = c[2];

	return matrixSolve(M, vec);
}

matrixSolve(A, b)
{
	// extended matrix
	A[0][3] = b[0];
	A[1][3] = b[1];
	A[2][3] = b[2];

	M = A;

	for (i = 0; i < 3; i++)
	{
		A = matrixPivotRow(M, i);
		M = A;
		for (j = 0; j < 3; j++)
		{
			if (M[j][i] && j != i)
				M = matrixRestoreRow(matrixSubstractRow(matrixMultiplyRow(M, i, M[j][i]), j, i), A, i);
		}
	}
	return (M[0][3], M[1][3], M[2][3]);
}

matrixRestoreRow(M, A, n)
{
	for (i = 0; i < 4; i++)
		M[n][i] = A[n][i];
	return M;
}

matrixMultiplyRow(M, n, s)
{
	for (i = 0; i < 4; i++)
		M[n][i] *= s;
	return M;
}

matrixSubstractRow(M, n, j)
{
	for (i = 0; i < 4; i++)
		M[n][i] -= M[j][i];
	return M;
}

matrixPivotRow(M, n)
{
	// If its 0 it has to be swapped with row x
	if (!M[n][n])
	{
		x = vectorBiggestValueIndex((0, M[1][n] * (n < 1), M[2][n] * (n < 2)));

		// Swap row
		temp = M[n];
		M[n] = M[x];
		M[x] = temp;
	}

	// Divide row to pivot
	d = M[n][n];
	for (i = 0; i < 4; i++)
		M[n][i] /= d;
	return M;
}

matrixPrint(A)
{
	iPrintLn(".");
	for (i = 0; i < A.size; i++)
	{
		line = "";
		for (j = 0; j < A[i].size; j++)
			line += A[i][j] + " | ";

		iPrintLn(line);
	}
	iPrintLn(".");
}

vectorProd(vec1, vec2)
{
	return (
		(vec1[1] * vec2[2] - vec1[2] * vec2[1]),
		(vec1[2] * vec2[0] - vec1[0] * vec2[2]),
		(vec1[0] * vec2[1] - vec1[1] * vec2[0])
	);
}

vectorRandom(max)
{
	return (randomIntRange(max * -1, max + 1), randomIntRange(max * -1, max + 1), randomIntRange(max * -1, max + 1));
}

vectorRotateX(vec, deg)
{
	a = sin(deg);
	b = cos(deg);
	return (vec[0], vec[1] * b - vec[2] * a, vec[1] * a + vec[2] * b);
}

vectorRotateY(vec, deg)
{
	a = sin(deg);
	b = cos(deg);
	return (vec[0] * b + vec[2] * a, vec[1], vec[2] * b - vec[0] * a);
}

vectorRotateZ(vec, deg)
{
	a = sin(deg);
	b = cos(deg);
	return (vec[0] * b - vec[1] * a, vec[0] * a + vec[1] * b, vec[2]);
}

vectorDivideIndex(v, i, s)
{
	switch (i)
	{
		case 0: return (v[0] / s, v[1], v[2]);
		case 1: return (v[0], v[1] / s, v[2]);
		case 2: return (v[0], v[1], v[2] / s);
	}
}

vector2D(vec)
{
	return vectorNormalize((vec[0], vec[1], 0));
}

vectorBiggestValueIndex(vec)
{
	return 0 * (vec[0] >= vec[1] && vec[0] >= vec[2])
		+ 1 * (vec[1] > vec[0] && vec[1] >= vec[2])
		+ 2 * (vec[2] > vec[1] && vec[2] > vec[0]);
}

vectorSmallestValueIndex(vec)
{
	return 0 * (vec[0] <= vec[1] && vec[0] <= vec[2])
		+ 1 * (vec[1] < vec[0] && vec[1] <= vec[2])
		+ 2 * (vec[2] < vec[1] && vec[2] < vec[0]);
}

vectorMultiply(vecA, vecB)
{
	return (vecA[0] * vecB[0], vecA[1] * vecB[1], vecA[2] * vecB[2]);
}

vectorScale(vec, scale)
{
	return (vec[0] * scale, vec[1] * scale, vec[2] * scale);
}

// The translation of point q from p oriented by the given angles
vectorTranslationAngles(vec, angles)
{
	a = anglesToForward(angles);
	b = anglesToRight(angles);
	c = vectorNormalize(vectorProd(b, a));

	return (vectorDot(vec, b), vectorDot(vec, c), vectorDot(vec, a));
}

// The actual translation of point q from p oriented by the given angles
vectorTranslationAngles2(vec, angles)
{
	a = anglesToForward(angles);
	b = anglesToRight(angles) * -1;
	c = vectorProd(a, b);

	return (vectorDot(vec, a), vectorDot(vec, b), vectorDot(vec, c));
}

// return angles needed in order to look in vectors direction from angles point of view
combinedAnglesToVector(vec, angles)
{
	a = vectorTranslationAngles(vec, angles);
	//iPrintLn(a);
	angles = anglesNormalize(vectorToAngles(a));
	return (angles[0],angles[1]*-1,0);
}

// The translation of point q from p oriented by the given vector angles
pointTranslation(p, q, forward, right, up)
{
	vec = q - p;
	return (vectorDot(vec, right), vectorDot(vec, up), vectorDot(vec, forward));
}

// The translation of point q from p oriented by the given angles
pointTranslationAngles(p, q, angles)
{
	vec = q - p;

	a = anglesToForward(angles);
	b = anglesToRight(angles);
	c = vectorNormalize(vectorProd(b, a));

	return (vectorDot(vec, b), vectorDot(vec, c), vectorDot(vec, a));
}

angleNormalize(angle)
{
	while (abs(angle) > 180)
		angle += 360 * sign(angle) * -1;
	return angle;
}

anglesNormalize(angles)
{
	return(angleNormalize(angles[0]), angleNormalize(angles[1]), angleNormalize(angles[2]));
}

angleMax(angle)
{
	while (abs(angle) > 90)
		angle = sign(angle) * 180 - angle;
	return angle;
}

angleSubstract(angle1, angle2)
{
	return angleNormalize(angleNormalize(angle2) - angleNormalize(angle1));
}

angleSnap(angle, deg)
{
	return round(angle / deg, 0) * deg;
}

angleSnap90(angle, offset)
{
	return round((angle - offset) / 90, 0) * 90 + offset;
}

drawText(pos, text, time, color, alpha, scale)
{
	if (!isDefined(color))
		color = randomColorDark();

	if (!isDefined(time) || time == 0)
		time = -1;

	time = int(time * 20);
	for (i = 0; i != time; i++)
	{
		print3d(pos, text, color, alpha, scale);
		wait 0.05;
	}
}

drawPoint(pos, time, color)
{
	if (!isDefined(color))
		color = randomColorDark();

	if (!isDefined(time))
		time = 0;

	lines = [];
	count = 5;

	for (i = 0; i < count * 2; i += 2)
	{
		l = vectorNormalize(randomColor());
		lines[i] = pos - l / 10;
		lines[i + 1] = pos + l / 10;
	}

	for (j = 1; j != 20 * time; j++)
	{
		for (i = 0; i < count * 2; i += 2)
			line(lines[i], lines[i + 1], color, true);
		wait 0.05;
	}
}

drawLine(from, to, time, color)
{
	if (!isDefined(color))
		color = randomColorDark();

	if (!isDefined(time) || time == 0)
		time = -1;

	time = int(time * 20);

	for (i = 0; i != time; i++)
	{
		line(from, to, color, true);
		wait 0.05;
	}
}

drawAxis(time, pos)
{
	if (!isDefined(time))
		time = 0;

	time = int(time*20);

	if (!isDefined(pos))
		pos = self.origin;
	if (!isDefined(pos))
		return;

	f = anglesToForward(self.angles) * 20;
	r = anglesToRight(self.angles) * -20;
	u = anglesToUp(self.angles) * 20;

	for (i = 1; i != time; i++)
	{
		thread drawLine(pos, pos + f, 0.05, (1, 0, 0));
		thread drawLine(pos, pos + r, 0.05, (0, 0, 1));
		thread drawLine(pos, pos + u, 0.05, (0, 1, 0));

		wait 0.05;
	}
}

drawCollision(color)
{
	self notify("drawCollision");
	self endon("drawCollision");

	if (!isDefined(color))
		color = randomColorDark();

	if (self.physics["colType"] == "cube")
	{
		while (true)
		{
			f = anglesToForward(self.angles) * self.physics["colSize"];
			r = anglesToRight(self.angles) * self.physics["colSize"]*-1;
			u = anglesToUp(self.angles) * self.physics["colSize"];

			thread drawLine(self.origin, self.origin + f / 2, 0.05, (1, 0, 0));
			thread drawLine(self.origin, self.origin + r / 2, 0.05, (0, 0, 1));
			thread drawLine(self.origin, self.origin + u / 2, 0.05, (0, 1, 0));

			thread drawLine(self.origin - f - u - r, self.origin + f - u - r, 0.05, color);
			thread drawLine(self.origin - f + u - r, self.origin + f + u - r, 0.05, color);
			thread drawLine(self.origin - f - u + r, self.origin + f - u + r, 0.05, color);
			thread drawLine(self.origin - f + u + r, self.origin + f + u + r, 0.05, color);

			thread drawLine(self.origin - f - u - r, self.origin - f - u + r, 0.05, color);
			thread drawLine(self.origin + f - u - r, self.origin + f - u + r, 0.05, color);
			thread drawLine(self.origin - f + u - r, self.origin - f + u + r, 0.05, color);
			thread drawLine(self.origin + f + u - r, self.origin + f + u + r, 0.05, color);

			thread drawLine(self.origin - f - u - r, self.origin - f + u - r, 0.05, color);
			thread drawLine(self.origin + f - u - r, self.origin + f + u - r, 0.05, color);
			thread drawLine(self.origin - f - u + r, self.origin - f + u + r, 0.05, color);
			thread drawLine(self.origin + f - u + r, self.origin + f + u + r, 0.05, color);

			wait 0.05;
		}
	}
}

debug_bulletTrace(start, end, hit_characters, ignore_entity)
{
	drawline(start, end, 0.1);
	return bulletTrace(start, end, hit_characters, ignore_entity);
}

debug_physicsTrace(start, end)
{
	drawline(start, end, 0.1);
	return physicstrace(start, end);
}

cheapSinSetup()
{
	level._sin[0] = 0.000;
	level._sin[1] = 0.017;
	level._sin[2] = 0.035;
	level._sin[3] = 0.052;
	level._sin[4] = 0.070;
	level._sin[5] = 0.087;
	level._sin[6] = 0.105;
	level._sin[7] = 0.122;
	level._sin[8] = 0.139;
	level._sin[9] = 0.156;
	level._sin[10] = 0.174;
	level._sin[11] = 0.191;
	level._sin[12] = 0.208;
	level._sin[13] = 0.225;
	level._sin[14] = 0.242;
	level._sin[15] = 0.259;
	level._sin[16] = 0.276;
	level._sin[17] = 0.292;
	level._sin[18] = 0.309;
	level._sin[19] = 0.326;
	level._sin[20] = 0.342;
	level._sin[21] = 0.358;
	level._sin[22] = 0.375;
	level._sin[23] = 0.391;
	level._sin[24] = 0.407;
	level._sin[25] = 0.423;
	level._sin[26] = 0.438;
	level._sin[27] = 0.454;
	level._sin[28] = 0.469;
	level._sin[29] = 0.485;
	level._sin[30] = 0.500;
	level._sin[31] = 0.515;
	level._sin[32] = 0.530;
	level._sin[33] = 0.545;
	level._sin[34] = 0.559;
	level._sin[35] = 0.574;
	level._sin[36] = 0.588;
	level._sin[37] = 0.602;
	level._sin[38] = 0.616;
	level._sin[39] = 0.629;
	level._sin[40] = 0.643;
	level._sin[41] = 0.656;
	level._sin[42] = 0.669;
	level._sin[43] = 0.682;
	level._sin[44] = 0.695;
	level._sin[45] = 0.707;
	level._sin[46] = 0.719;
	level._sin[47] = 0.731;
	level._sin[48] = 0.743;
	level._sin[49] = 0.755;
	level._sin[50] = 0.766;
	level._sin[51] = 0.777;
	level._sin[52] = 0.788;
	level._sin[53] = 0.799;
	level._sin[54] = 0.809;
	level._sin[55] = 0.819;
	level._sin[56] = 0.829;
	level._sin[57] = 0.839;
	level._sin[58] = 0.848;
	level._sin[59] = 0.857;
	level._sin[60] = 0.866;
	level._sin[61] = 0.875;
	level._sin[62] = 0.883;
	level._sin[63] = 0.891;
	level._sin[64] = 0.899;
	level._sin[65] = 0.906;
	level._sin[66] = 0.914;
	level._sin[67] = 0.921;
	level._sin[68] = 0.927;
	level._sin[69] = 0.934;
	level._sin[70] = 0.940;
	level._sin[71] = 0.946;
	level._sin[72] = 0.951;
	level._sin[73] = 0.956;
	level._sin[74] = 0.961;
	level._sin[75] = 0.966;
	level._sin[76] = 0.970;
	level._sin[77] = 0.974;
	level._sin[78] = 0.978;
	level._sin[79] = 0.982;
	level._sin[80] = 0.985;
	level._sin[81] = 0.988;
	level._sin[82] = 0.990;
	level._sin[83] = 0.993;
	level._sin[84] = 0.995;
	level._sin[85] = 0.996;
	level._sin[86] = 0.998;
	level._sin[87] = 0.999;
	level._sin[88] = 0.999;
	level._sin[89] = 1.000;
	level._sin[90] = 1.000;
}

cheapSin(deg)
{
	deg = int(round(deg, 0));
	p = deg % 360;
	if (p < 0)
		return cheapSin(p * -1) * -1;
	if (p > 90 && p <= 180)
		return level._sin[180 - p];
	if (p > 180 && p <= 270)
		return level._sin[p - 180] * -1;
	if (p > 270)
		return level._sin[360 - p] *-1;
	return level._sin[p];
}

cheapCos(deg)
{
	return cheapSin(deg+90);
}

// Rounds the float number using e valid digits, e can be negative
round(f, e)
{
	s = sign2(f);
    c =  exp(10, e);
	a = (c * f * 10 - int(c * f) * 10);
	a = (a >= 5) || (a < -5);
    return ((int(f * c) + a * s) / c);
}

exp(base, e)
{
	if (e < 0)
	{
		base = 1 / base;
		e *= -1;
	}
	output = 1;
	for (i = 0; i < e; i++)
		output *= base;
	return output;
}

sign(x)
{
	if (isDefined(x) && x >= 0)
		return 1;
	return -1;
}

sign2(x)
{
	if (isDefined(x) && x > 0)
		return 1;
	if (x < 0)
		return -1;
	return 0;
}

pi()
{
	return 3.14159265;
}

getHeight()
{
	switch (self getstance())
	{
		case "crouch":	height = (0, 0, 52);
		break;
		case "prone":	height = (0, 0, 31);
		break;
		default:		height = (0, 0, 72);
	}
	return height;
}

getCenter()
{
	return self getheight() / 2;
}

centerPos()
{
	return self.origin + self getcenter();
}

pow(base, exponent)
{
	result = 1.0;
    for (i = 0; i < exponent; i++)
        result *= base;
    return result;
}

eye()
{
	switch (self getstance())
	{
		case "crouch":	height = (0, 0, 40);  break;
		case "prone":	height = (0, 0, 11);  break;
		default:		height = (0, 0, 60);  break;
	}
	return height;
}

eyePos()
{
	return self eye() + self.origin;
}

swapScale(v, n, i)
{
	w[n] = v[i];
	w[i] = v[n];
	w[3 - n - i] = v[3 - n - i];
	return (w[0], w[1], w[2]);
}

neg(v)
{
	return v * -1;
}

getResolution()
{
	resolution = strTok(self getUserInfo("r_mode"), "x");
	if (resolution.size == 2)
	{
		resolution[0] = ToInt(resolution[0]);
		resolution[1] = ToInt(resolution[1]);
	}
	else
	{
		resolution[0] = 1920;
		resolution[1] = 1080;
	}
	return resolution;
}

getFov()
{
	fov = self getUserInfo("cg_fov");
	if (IsStringInt(fov))
		return ToInt(fov);
	return 80;
}

getFovScale()
{
	fov = self getUserInfo("cg_fovScale");
	if (IsStringFloat(fov))
		return ToFloat(fov);
	return self.settings["gfx_fov"] / 1000;
}

calculateFov()
{
	resolution = self getResolution();
	playerFov = self getFov();
	playerFovScale = self getFovScale();

	comPrintLn("[Debug] %dx%d %d %f", resolution[0], resolution[1], playerFov, playerFovScale);

	fov = playerFov * playerFovScale;
	wFov = tan1(fov * 0.01745329238474369 * 0.5) * 0.75;

	tanHalfFovX = wFov * (resolution[0] / resolution[1]);
	tanHalfFovY = wFov;

	return tanHalfFovX;
}

angleScreenProjection(angle)
{
	tanHalfFovX = self calculateFov();
	halfFovX = atan1(tanHalfFovX);

	if (angle >= halfFovX)
		return 0;

	if (angle <= neg(halfFovX))
		return 640;

	return 640 / 2 * (1 - tan1(angle) / tan1(halfFovX));
}

angleNormalizePi(angle)
{
	t_angle = fmod(angle + pi(), 2 * pi());

	if (t_angle < 0)
		return t_angle + pi();
	return t_angle - pi();
}

vectorLengthSquared2(vec)
{
	return vec[0] * vec[0] + vec[1] * vec[1];
}

vectorLength2(vec)
{
	return sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
}

short2rad(x)
{
	return x * (pi() / 32768);
}

rad2short(x)
{
	return x * (32768 / pi());
}

angleNormalize65536(angle)
{
	return angle & 65535;
}
