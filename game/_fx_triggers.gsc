#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
	wait 5;
	trig = getEntArray( "endmap_trig", "targetname" );
	if( !trig.size || trig.size > 1 )
	{
		iPrintln("^1NO END TRIG!! CREATE ONE!");
		return;
	}
	createTrigFx(trig[0], "endtrig");
}

createTrigFx(trigger, fx)
{
	if(!isDefined(trigger) || !isDefined(fx))
		return;
	type = trigger.classname;	
	z = getfloor(trigger)[2];

	//trigger radius requires you to define .radius
	if(type == "trigger_radius")
	{
		switch (fx)
		{
			case "yellow": fx = level.fx["yellow_fx"]; break;
			case "darkred": fx = level.fx["red_fx"]; break;
			case "purple": fx = level.fx["purple_fx"]; break;
			case "orange": fx = level.fx["orange_fx"]; break;
			case "green": fx = level.fx["green_fx"]; break;
			case "cyan": fx = level.fx["cyan_fx"]; break;

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
		if(!isDefined(trigger.radius)) trigger.radius = 0;
		if(isDefined(trigger.inAir) && trigger.inAir) z = trigger.origin[2];
		width = trigger.radius;

		points = thread circlePoints(trigger, z, width);
		wait 0.1;

		trigger thread moveFxcir(points, fx);

		/*
		for(i=0; i<points.size-1; i++)
			thread drawLine(points[i], points[i+1], (1,0,0), false);
		*/
	}
	else
	{
		if(fx == "endtrig")
			fx = level.fx["endtrig_fx"];
		else
			fx = level.fx["secrettrig_fx"];
		width = getTrigsize(trigger)[0];
		length = getTrigsize(trigger)[1];
		height_bottom = getTrigsize(trigger)[2];
		points = [];
		if(isDefined(trigger.inAir) && trigger.inAir)
			z = trigger.origin[2]+height_bottom;

		x = trigger.origin[0]+width;
		y = trigger.origin[1]+length;
		points[points.size] = (x,y,z);
		x = trigger.origin[0]+width;
		y = trigger.origin[1]-length;
		points[points.size] = (x,y,z);
		x = trigger.origin[0]-width;
		y = trigger.origin[1]-length;
		points[points.size] = (x,y,z);
		x = trigger.origin[0]-width;
		y = trigger.origin[1]+length;
		points[points.size] = (x,y,z);

		thread moveFxrect(points, fx);

		/*
		thread drawLine(points[0], points[1], (1,0,0), false);
		thread drawLine(points[1], points[2], (0,1,0), false);
		thread drawLine(points[2], points[3], (0,0,1), false);
		thread drawLine(points[3], points[0], (1,0,1), false);
		*/
	}
}

moveFxcir(a, fx)
{
	level endon("game over");
	while(isDefined(self))
	{
		tag = spawn("script_model", a[0]);
		tag setmodel("tag_origin");
		wait 0.1;
		PlayFXOnTag(fx, tag, "tag_origin");
		for(i=0; i<a.size+1; i++)
		{
			if(i >= a.size)
				tag MoveTo(a[0], 0.1);
			else
				tag MoveTo(a[i], 0.1);
			wait 0.1;
		}
		tag delete();
		wait 0.05;
	}
}

//move tag around points with fx playing
//delete tag and respawn each loop other wise new connections wont be able to see fx
moveFxrect(a, fx)
{
	level endon("game over");
	while(1)
	{
		tag = spawn("script_model", a[0]);
		tag setmodel("tag_origin");
		wait 0.1;
		PlayFXOnTag(fx, tag, "tag_origin");
		for(i=0; i<a.size+1; i++)
		{
			if(i >= a.size)
				tag MoveTo(a[0], 5, 0.5, 0.5);
			else
				tag MoveTo(a[i], 5, 0.5, 0.5);
			wait 5;
		}
		tag delete();
		wait 1;
	}
}

//get ground below trigger
//returns x,y,z
getfloor(a)
{
	trace = BulletTrace(a.origin, a.origin - (0,0,999999), false, undefined);
	if(trace["fraction"] != 1)
		return trace["position"];
	else
		return a;
}

//get half of trig length and width
//returns x,y in an array
getTrigsize(a)
{
	arr = [];
	tag = spawn("script_origin", a.origin);
	ori1 = tag GetOrigin();
	x = 0;
	while(tag IsTouching(a))
	{	
		tag.origin = (tag.origin + (x,0,0));
		wait 0.05;
		x++;
	}
	ori2 = tag GetOrigin();
	x = ori2[0] - ori1[0];
	arr[arr.size] = x;

	tag.origin = a.origin - (0,0,0);
	ori1 = tag GetOrigin();
	y = 0;
	while(tag IsTouching(a))
	{	
		tag.origin = (tag.origin + (0,y,0));
		wait 0.05;
		y++;
	}
	ori2 = tag GetOrigin();
	y = ori2[1] - ori1[1];

	arr[arr.size] = y;
	tag.origin = a.origin - (0,0,0);
    ori1 = tag GetOrigin();
    z = 0;
    while(tag IsTouching(a))
    {    
        tag.origin = (tag.origin + (0,0,z));
        wait 0.05;
        z--;
    }
    ori2 = tag GetOrigin();
    z = ori2[2] - ori1[2];

    arr[arr.size] = z;
	tag Delete();

	//thread drawLine(a.origin, a.origin + (x,0,0), (1,0,0), false);
	//thread drawLine(a.origin, a.origin + (0,y,0), (0,1,0), false);

	return arr;
}

circlePoints(a, floor, radius)
{
	points = [];
	r = radius;
	z = floor;
	idx = 0;

	h = a.origin[0];
	k = a.origin[1];
	for(i = 0; i< 360; i++)
	{
		x = h + r*Cos(i);
		y = k - r*Sin(i);
		points[idx] = (x,y,z);
		if(i%2 == 0)	
			idx++;
	}
	return points;
}

drawLine(start, end, colour, depth)
{
	while(1)
	{
		/#
		line(start, end, colour, depth);
		#/
		wait 0.05;
	}
}
