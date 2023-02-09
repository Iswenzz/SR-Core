#include sr\utils\_math;

addHud(who, x, y, alpha, alignX, alignY, fontScale, sort, archived)
{
	if (isPlayer(who))
		hud = newClientHudElem(who);
	else
		hud = newHudElem();

	fontScale = IfUndef(fontScale, 1.4);

	hud.x = x;
	hud.y = y;
	hud.originalAlpha = alpha;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.horzAlign = alignX;
	hud.vertAlign = alignY;
	hud.fontScale = Ternary(fontScale < 1.4, 1.4, fontScale);
	hud.sort = IfUndef(sort, 1);
	hud.archived = IfUndef(archived, false);
	hud.hidewheninmenu = true;
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
			return "middle";

		case 7:
		case 8:
		case 9:
			return "bottom";
	}
	return "top";
}

getHorizontal(int)
{
	switch (int)
	{
		case 1:
		case 4:
		case 7:
			return "left";

		case 2:
		case 5:
		case 8:
			return "center";

		case 3:
		case 6:
		case 9:
			return "right";
	}
	return "left";
}

fadeOut(delay, time, direction, speed)
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
	wait delay;
	if (!isDefined(self))
		return;

	self fadeOverTime(time);
	self.alpha = 0;

	wait time;
	if (!isDefined(self))
		return;

	self destroy();
}

fadeIn(delay, time, direction, speed)
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

	wait delay;
	if (!isDefined(self))
		return;

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
	w = int(abs(ceil(w)));
	h = int(abs(ceil(h)));

	if (!w || !h)
	{
		self.alpha = 0;
		return;
	}

	self setShader("white", w, h);
	self.alpha = self.originalAlpha;
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

getTextWidth(string, fontSize)
{
	texts = strTok(string, "\n");
	chars = 0;
	biggestIndex = 0;

	for (i = 0; i < texts.size; i++)
	{
		if (texts[i].size > chars)
		{
			chars = texts[i].size;
			biggestIndex = i;
		}
	}
	text = texts[biggestIndex];

	return int((strPixLen(text) * (fontSize / 1.4)) * 2);
}

getTextHeight(text, fontSize)
{
	breaks = strTok(text, "\n").size;
	if (!breaks) breaks = 1;

	return int(20 * (fontSize / 1.4) * (breaks * 0.9));
}

splitTextByWidth(text, maxWidth)
{
	return StrJoin(strTokByPixLen(text, maxWidth), "\n");
}
