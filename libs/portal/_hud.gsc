updateHud(color)
{
	NewShader = "";
	img = "reticle_portal";

	if (color == "none")
	{
		self.portal["hud"].alpha = 0;
		return;
	}
	else if (color == "default")
		NewShader = img;
	else if (color == "red" || color == "blue")
	{
		if (self.portal[othercolor(color) + "_exist"])
			newShader = img + "_both";
		else
			newShader = img + "_" + color;
	}
	else
		return;

	size = 64;
	self.portal["hud"] setShader(NewShader, size, size);
	self.portal["hud"].AlignX = "center";
	self.portal["hud"].AlignY = "middle";
	self.portal["hud"].horzAlign = "center_safearea";
	self.portal["hud"].vertAlign = "center_safearea";
	self.portal["hud"].alpha = 1;
}

otherColor(color)
{
	if (color == "red")
		return "blue";
	else
		return "red";
}
