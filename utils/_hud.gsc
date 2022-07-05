#include sr\utils\_math;

addHud(who, x, y, alpha, alignX, alignY, fontScale, sort)
{
	if (isPlayer(who))
		hud = newClientHudElem(who);
	else
		hud = newHudElem();

	fontScale = IfUndef(fontScale, 1.4);

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.horzAlign = alignX;
	hud.vertAlign = alignY;
	hud.fontScale = Ternary(fontScale < 1.4, 1.4, fontScale);
	hud.sort = IfUndef(sort, 0);
	return hud;
}

getVertical(int)
{
	switch (int)
	{
		case 1:
		case 2:
		case 3:
			return "top";

		case 4:
		case 5:
		case 6:
			return "bottom";

		default:
			return "bottom";
	}
}

getHorizontal(int)
{
	switch (int)
	{
		case 1:
		case 4:
			return "left";

		case 2:
		case 5:
			return "center";

		case 3:
		case 6:
			return "right";

		default:
			return "left";
	}
}

fadeOut(time, direction, speed)
{
	if (!isDefined(self))
		return;
	if (isDefined(direction))
	{
		self moveOverTime(IfUndef(speed, 0.2));

		switch (direction)
		{
			case "top": 	self.y -= 600; 	break;
			case "left": 	self.x -= 600; 	break;
			case "bottom": 	self.y += 600; 	break;
			case "right": 	self.x += 600; 	break;
		}
	}
	self fadeOverTime(time);
	self.alpha = 0;

	wait time;
	if (isDefined(self))
		self destroy();
}

fadeIn(time, direction, speed)
{
	if (!isDefined(self))
		return;
	if (isDefined(direction))
	{
		switch (direction)
		{
			case "top": 	self.y += 600; 	break;
			case "left": 	self.x += 600; 	break;
			case "bottom": 	self.y -= 600; 	break;
			case "right": 	self.x -= 600; 	break;
		}

		self moveOverTime(IfUndef(speed, 0.2));

		switch (direction)
		{
			case "top": 	self.y -= 600; 	break;
			case "left": 	self.x -= 600; 	break;
			case "bottom": 	self.y += 600; 	break;
			case "right": 	self.x += 600; 	break;
		}
	}
	alpha = self.alpha;
	self.alpha = 0;
	self fadeOverTime(time);
	self.alpha = alpha;
}

fillAngleYaw(player, start, end, yaw, y, h)
{
	range = angleToRange(player, start, end, yaw);

	if (!range.split)
		self fillRect(range.x1, y, range.x2 - range.x1, h);
	else
	{
		self fillRect(0, y, range.x1, h);
		self fillRect(range.x2, y, 640 - range.x2, h);
	}
}

fillRect(x, y, w, h)
{
	w = int(abs(w));
	h = int(abs(h));

	if (!w || !h)
	{
		self.alpha = 0;
		return;
	}

	self setShader("white", w, h);
	self.alpha = 0.5;
	self.x = x;
	self.y = y;
}

angleToRange(player, start, end, yaw)
{
	range = spawnStruct();

	if (abs(end - start) > 2 * pi())
	{
		range.x1 = 0;
		range.x2 = 640;
		range.split = false;
		return range;
	}

	split = end > start;
	start = angleNormalizePi(start - yaw);
	end	= angleNormalizePi(end - yaw);

	if (end > start)
	{
		split = !split;

		tmp = start;
		start = end;
		end	= tmp;
	}

	range.x1 = player angleScreenProjection(start);
	range.x2 = player angleScreenProjection(end);
	range.split = split;
	return range;
}
