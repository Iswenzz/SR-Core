#include sr\utils\_common;

effect(trigger, fx)
{
	if (!isDefined(trigger) || !isDefined(fx))
		return;

	switch (fx)
	{
		case "red":
		case "endtrig":
			fx = level.gfx["endtrigcircle_fx"];
			break;
		case "blue":
		case "secret":
			fx = level.gfx["secrettrigcircle_fx"];
			break;
		case "yellow":
			fx = level.gfx["yellow_fx"];
			break;
		case "darkred":
			fx = level.gfx["red_fx"];
			break;
		case "purple":
			fx = level.gfx["purple_fx"];
			break;
		case "orange":
			fx = level.gfx["orange_fx"];
			break;
		case "green":
			fx = level.gfx["green_fx"];
			break;
		case "cyan":
			fx = level.gfx["cyan_fx"];
			break;
		default:
			fx = undefined;
			break;
	}
	if (!isDefined(fx))
		return;
	if (trigger.classname == "trigger_radius")
	{
		points = trigger circlePoints();
		trigger fxCircle(points, fx);
	}
	else
	{
		points = trigger rectanglePoints();
		trigger fxRect(points, fx);
	}
}

fxCircle(points, fx)
{
	while (isDefined(self))
	{
		tag = spawn("script_model", points[0]);
		tag setModel("tag_origin");
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
	}
}

fxRect(points, fx)
{
	while (isDefined(self))
	{
		tag = spawn("script_model", points[0]);
		tag setModel("tag_origin");
		wait 0.1;
		playFXOnTag(fx, tag, "tag_origin");

		for (i = 0; i < points.size + 1; i++)
		{
			if (i >= points.size)
				tag MoveTo(points[0], 3, 0.5, 0.5);
			else
				tag MoveTo(points[i], 3, 0.5, 0.5);
			wait 3;
		}
		tag delete();
		wait 3.2;
	}
}
