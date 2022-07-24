updateHud(color)
{
	shader = "";
	img = "reticle_portal";

	if (color == "none")
	{
		self.portal["hud"].alpha = 0;
		return;
	}
	else if (color == "default")
		shader = img;
	else if (color == "red" || color == "blue")
	{
		if (self.portal[othercolor(color) + "_exist"])
			shader = img + "_both";
		else
			shader = img + "_" + color;
	}
	else
		return;

	size = 64;
	if (isDefined(self.portal["hud"]))
	{
		self.portal["hud"] setShader(shader, size, size);
		self.portal["hud"].AlignX = "center";
		self.portal["hud"].AlignY = "middle";
		self.portal["hud"].horzAlign = "center_safearea";
		self.portal["hud"].vertAlign = "center_safearea";
		self.portal["hud"].alpha = 1;
	}
}

otherColor(color)
{
	return Ternary(color == "red", "blue", "red");
}
