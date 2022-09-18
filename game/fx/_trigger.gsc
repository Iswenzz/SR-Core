#include sr\utils\_common;

effect(trigger, fx)
{
	if (!isDefined(trigger) || !isDefined(fx))
		return;

	waitMapLoad();

	switch (fx)
	{
		case "yellow": 	fx = level.fx["yellow_fx"]; break;
		case "darkred": fx = level.fx["red_fx"]; 	break;
		case "purple": 	fx = level.fx["purple_fx"]; break;
		case "orange": 	fx = level.fx["orange_fx"]; break;
		case "green": 	fx = level.fx["green_fx"]; 	break;
		case "cyan": 	fx = level.fx["cyan_fx"]; 	break;

		case "endtrig":
		case "red":
			fx = level.fx["endtrigcircle_fx"];
			break;

		case "blue":
		case "secret":
		default:
			fx = level.fx["secrettrigcircle_fx"];
			break;
	}
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
	while (isDefined(self))
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
