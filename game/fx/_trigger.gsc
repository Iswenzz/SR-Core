effect(trigger, fx)
{
	if (!isDefined(trigger) || !isDefined(fx))
		return;
	type = trigger.classname;
	z = getFloor(trigger)[2];

	switch (fx)
	{
		case "yellow": 	fx = level.fx["yellow_fx"]; 			break;
		case "darkred": fx = level.fx["red_fx"]; 				break;
		case "purple": 	fx = level.fx["purple_fx"]; 			break;
		case "orange": 	fx = level.fx["orange_fx"]; 			break;
		case "green": 	fx = level.fx["green_fx"]; 				break;
		case "cyan": 	fx = level.fx["cyan_fx"]; 				break;

		case "endtrig":
		case "red":		fx = level.fx["endtrigcircle_fx"]; 		break;
		case "blue":
		case "secret":
		default: 		fx = level.fx["secrettrigcircle_fx"]; 	break;
	}

	if (type == "trigger_radius")
	{
		if (!isDefined(trigger.radius))
			trigger.radius = 0;
		if (isDefined(trigger.inAir) && trigger.inAir)
			z = trigger.origin[2];
		width = trigger.radius;

		points = circlePoints(trigger, z, width);
		trigger fxCircle(points, fx);
	}
	else
	{
		size = getTrigsize(trigger);
		width = size[0];
		length = size[1];
		height_bottom = size[2];
		points = [];

		if (isDefined(trigger.inAir) && trigger.inAir)
			z = trigger.origin[2] + height_bottom;

		x = trigger.origin[0] + width;
		y = trigger.origin[1] + length;
		points[points.size] = (x, y, z);
		x = trigger.origin[0] + width;
		y = trigger.origin[1] - length;
		points[points.size] = (x, y, z);
		x = trigger.origin[0] - width;
		y = trigger.origin[1] - length;
		points[points.size] = (x, y, z);
		x = trigger.origin[0] - width;
		y = trigger.origin[1] + length;
		points[points.size] = (x, y, z);

		fxRect(points, fx);
	}
}

fxCircle(points, fx)
{
	level endon("game over");
	while (isDefined(self))
	{
		tag = spawn("script_model", points[0]);
		tag setmodel("tag_origin");
		wait 0.1;

		playFXOnTag(fx, tag, "tag_origin");
		for (i = 0; i < points.size + 1; i++)
		{
			if (i >= points.size)
				tag MoveTo(points[0], 0.1);
			else
				tag MoveTo(points[i], 0.1);
			wait 0.1;
		}
		tag delete();
		wait 0.05;
	}
}

fxRect(points, fx)
{
	level endon("game over");
	while (true)
	{
		tag = spawn("script_model", points[0]);
		tag setmodel("tag_origin");
		wait 0.1;

		playFXOnTag(fx, tag, "tag_origin");
		for (i = 0; i < points.size + 1; i++)
		{
			if (i >= points.size)
				tag MoveTo(points[0], 5, 0.5, 0.5);
			else
				tag MoveTo(points[i], 5, 0.5, 0.5);
			wait 5;
		}
		tag delete();
		wait 1;
	}
}

getFloor(trigger)
{
	trace = BulletTrace(trigger.origin, trigger.origin - (0, 0, 999999), false, undefined);
	return Ternary(trace["fraction"] != 1, trace["position"], trigger);
}

getTrigSize(trigger)
{
	arr = [];
	tag = spawn("script_origin", trigger.origin);
	ori1 = tag GetOrigin();
	x = 0;

	while (tag IsTouching(trigger))
	{
		tag.origin = (tag.origin + (x, 0, 0));
		wait 0.05;
		x++;
	}
	ori2 = tag GetOrigin();
	x = ori2[0] - ori1[0];
	arr[arr.size] = x;

	tag.origin = trigger.origin - (0, 0, 0);
	ori1 = tag GetOrigin();
	y = 0;
	while (tag IsTouching(trigger))
	{
		tag.origin = (tag.origin + (0, y, 0));
		wait 0.05;
		y++;
	}
	ori2 = tag GetOrigin();
	y = ori2[1] - ori1[1];

	arr[arr.size] = y;
	tag.origin = trigger.origin - (0,0,0);
    ori1 = tag GetOrigin();
    z = 0;
    while (tag IsTouching(trigger))
    {
        tag.origin = (tag.origin + (0, 0, z));
        wait 0.05;
        z--;
    }
    ori2 = tag GetOrigin();
    z = ori2[2] - ori1[2];

    arr[arr.size] = z;
	tag Delete();

	return arr;
}

circlePoints(trigger, floor, radius)
{
	points = [];
	r = radius;
	z = floor;
	idx = 0;

	h = trigger.origin[0];
	k = trigger.origin[1];
	for (i = 0; i < 360; i++)
	{
		x = h + r * cos(i);
		y = k - r * sin(i);
		points[idx] = (x, y, z);

		if (i % 2 == 0)
			idx++;
	}
	return points;
}
