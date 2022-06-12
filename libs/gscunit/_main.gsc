#include sr\libs\gscunit\_utils;

gscunitEnv()
{
	level.gscunit = spawnStruct();
	level.gscunit.enabled = getDvarInt("gscunit");

	if (!level.gscunit.enabled)
		return false;

	level.gscunit.bots = spawnBots(5);
	level.gscunit.debug = getDvarInt("gscunit_debug");
	level.gscunit.clock = undefined;
	level.gscunit.fail = false;
	level.gscunit.count_pass = 0;
	level.gscunit.count_fail = 0;

	return true;
}

it(callback, name, beforeCallback, afterCallback)
{
	if (!level.gscunit.enabled)
		return;

	// Before
	sysPrint("^2(          )^0 %s ^7", name);
	if (isDefined(beforeCallback) && ![[beforeCallback]]())
	{
		sysPrintLn(" (ERROR beforeCallback)");
		return;
	}
	sysPrintLn();

	// Test
	clock = startClock();
    [[callback]]();
	time = stopClock(clock);

	// Global clock
	if (!isDefined(level.gscunit.clock))
		level.gscunit.clock = startClock();

	// Result
	result = Ternary(level.gscunit.fail, "FAIL", "PASS");
	color = Ternary(level.gscunit.fail, "^1", "^2");
	sysPrint("%s(   %s   )^7 %s (%dms) ^7", color, result, name, time);

	// After
	if (isDefined(afterCallback) && ![[afterCallback]]())
		sysPrintLn(" (ERROR afterCallback)");
	sysPrintLn("");

	// Summarize
	if (result == "PASS")
		level.gscunit.count_pass++;
	else
		level.gscunit.count_fail++;
	level.gscunit.fail = false;
}

suite(name)
{
	if (!level.gscunit.enabled) return;
    sysPrintLn("^2(============) %s^7", name);
}

startClock()
{
	return GetSysTime();
}

stopClock(clock)
{
	return GetSysTime() - clock;
}

summarize(exit)
{
	if (!level.gscunit.enabled)
		return;

	time = stopClock(level.gscunit.clock);
	color = Ternary(level.gscunit.count_fail > 0, "^1", "^2");
	sysPrintLn("\n%sPassed: %d Failed: %d (%dms)\n", color,
		level.gscunit.count_pass, level.gscunit.count_fail, time);

	if (exit)
		exit(level.gscunit.count_fail > 0);

	level.gscunit.fail = false;
	level.gscunit.count_pass = 0;
	level.gscunit.count_fail = 0;
}

FAIL()
{
	level.gscunit.fail = true;
	return false;
}

EXPECT_EQ(a, b)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] == b[0] && a[1] == b[1] && a[2] == b[2])
				return true;
			break;

		default:
			if (a == b)
				return true;
			break;
	}

	error_expect(a, b);
	return FAIL();
}

EXPECT_NE(a, b)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] != b[0] && a[1] != b[1] && a[2] != b[2])
				return true;
			break;

		default:
			if (a != b)
				return true;
			break;
	}

	error_expect(a, b);
	return FAIL();
}

EXPECT_CONTAIN(a, b)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] == b || a[1] == b || a[2] == b)
				return true;
			break;

		case "ARRAY":
			for (i = 0; i < a.size; i++)
			{
				if (a[i] == b)
					return true;
			}
			break;

		case "STRING":
		case "ISTRING":
			if (isSubStr(a, b))
				return true;
			break;

		default:
			if (a == b)
				return true;
			break;
	}

	error_expect(a, b);
	return FAIL();
}

EXPECT_NOT_CONTAIN(a, b)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] != b || a[1] != b || a[2] != b)
				return true;
			break;

		case "ARRAY":
			found = false;
			for (i = 0; i < a.size; i++)
			{
				if (a[i] == b)
				{
					found = true;
					break;
				}
			}
			if (!found)
				return true;
			break;

		case "STRING":
		case "ISTRING":
			if (!isSubStr(a, b))
				return true;
			break;

		default:
			if (a != b)
				return true;
			break;
	}

	error_expect(a, b);
	return FAIL();
}

EXPECT_TRUE(a)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] && a[1] && a[2])
				return true;
			break;

		default:
			if (a)
				return true;
			break;
	}

	error_expect(true, a);
	return FAIL();
}

EXPECT_FALSE(a)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (!a[0] && !a[1] && !a[2])
				return true;
			break;

		default:
			if (!a)
				return true;
			break;
	}

	error_expect(false, a);
	return FAIL();
}

EXPECT_UNDEFINED(a)
{
	gscunit_debug(a);
	if (!isDefined(a)) return true;

	error_expect(undefined, a);
	return FAIL();
}

EXPECT_LT(a, b)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] < b[0] && a[1] < b[1] && a[2] < b[2])
				return true;
			break;

		default:
			if (a < b)
				return true;
			break;
	}

	error_expect(a, b);
	return FAIL();
}

EXPECT_LE(a, b)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] <= b[0] && a[1] <= b[1] && a[2] <= b[2])
				return true;
			break;

		default:
			if (a <= b)
				return true;
			break;
	}

	error_expect(a, b);
	return FAIL();
}

EXPECT_GT(a, b)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] > b[0] && a[1] > b[1] && a[2] > b[2])
				return true;
			break;

		default:
			if (a > b)
				return true;
			break;
	}

	error_expect(a, b);
	return FAIL();
}

EXPECT_GE(a, b)
{
	gscunit_debug(a);
	switch (GetType(a))
	{
		case "UNDEFINED":
			break;

		case "VECTOR":
			if (a[0] >= b[0] && a[1] >= b[1] && a[2] >= b[2])
				return true;
			break;

		default:
			if (a >= b)
				return true;
			break;
	}

	error_expect(a, b);
	return FAIL();
}

EXPECT_TYPE(a, b)
{
	gscunit_debug(a);
	if (GetType(a) != GetType(b)) return true;

	error_expect(GetType(a), GetType(a));
	return FAIL();
}

printable(a)
{
	switch (GetType(a))
	{
		case "ARRAY":
			string = "[";
			for (i = 0; i < a.size; i++)
				string += printable(a[i]) + ", ";
			return getSubStr(string, 0, string.size - 2) + "]";

		case "STRING":
		case "ISTRING":
		case "VECTOR":
		case "FLOAT":
		case "INTEGER":
			return toString(a);
	}
	return "";
}

error_expect(a, b)
{
	received = printable(a);
	expected = printable(b);

	sysPrintLn("\n\t^1Received: %s\n\t^2Expected: %s\n^7", received, expected);
}

gscunit_debug(a)
{
	if (!level.gscunit.debug) return;

	switch (GetType(a))
	{
		case "ARRAY":
			logArrayTypes(a);
			break;

		case "UNDEFINED":
		case "STRING":
		case "ISTRING":
		case "VECTOR":
		case "FLOAT":
		case "INTEGER":
			logVariableType(a);
			break;
	}
}
