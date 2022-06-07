logArrayTypes(arr)
{
	if (isDefined(arr) && isDefined(arr.size))
	{
		for (i = 0; i < arr.size; i++)
		{
			if (isDefined(arr[i]))
				sysPrint(GetType(arr[i]) + " " + arr[i] + "\n");
		}
	}
}

logArrayKeys(arr)
{
	if (isDefined(arr))
	{
		keys = getArrayKeys(arr);
		if (isDefined(keys) && isDefined(keys.size))
		{
			for (i = 0; i < keys.size; i++)
			{
				if (isDefined(arr[keys[i]]))
					sysPrint(keys[i] + ": " + arr[keys[i]] + "\n");
			}
		}
	}
}

logArray(arr)
{
	if (isDefined(arr) && isDefined(arr.size))
	{
		for (i = 0; i < arr.size; i++)
		{
			if (isDefined(arr[i]))
				sysPrint(arr[i] + "\n");
		}
	}
}

logVariable(var)
{
	if (isDefined(var))
		sysPrint(var + "\n");
}

logVariableType(var)
{
	if (isDefined(var))
		sysPrint(GetType(var) + " " + var + "\n");
}

spawnBots(number)
{
	bots = [];
	for (i = 0; i < number; i++)
	{
		bot = addTestClient();
		wait 0.05;
		bot notify("menuresponse", game["menu_team"], "autoassign");
		bots[bots.size] = bot;
	}
	return bots;
}
