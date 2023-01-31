#include sr\utils\_common;

updateHud()
{
	shader = "reticle_portal";
	if (self.portal["blue_exist"] && self.portal["red_exist"])
		shader = "reticle_portal_both";
	else if (self.portal["blue_exist"])
		shader = "reticle_portal_blue";
	else if (self.portal["red_exist"])
		shader = "reticle_portal_red";

	if (!isDefined(self.portal["hud"]))
		self.portal["hud"] = newClientHudElem(self);

	self.portal["hud"] setShader(shader, 64, 64);
	self.portal["hud"].AlignX = "center";
	self.portal["hud"].AlignY = "middle";
	self.portal["hud"].horzAlign = "center_safearea";
	self.portal["hud"].vertAlign = "center_safearea";
	self.portal["hud"].alpha = 1;
}

cleanHud()
{
	if (isDefined(self.portal["hud"]))
		self.portal["hud"] destroy();
}

othercolor(color)
{
	return Ternary(color == "red", "blue", "red");
}
