addHud(who, x, y, alpha, alignX, alignY, fontScale)
{
	if (isPlayer(who))
		hud = newClientHudElem(who);
	else
		hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.alignX = alignX;
	hud.alignY = alignY;
	hud.horzAlign = alignX;
	hud.vertAlign = alignY;
	hud.fontScale = fontScale;
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
