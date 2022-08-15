#include sr\sys\_events;
#include sr\utils\_hud;

main()
{
	precacheShader("sr_shake");
	precacheShader("sr_zoom");
	precacheShader("sr_edge");
	precacheShader("sr_vhs");

	event("connect", ::shaders);
}

shaders()
{
	self thread shake();
	self thread zoom();
	self thread edge();
	self thread vhs();
}

vhs()
{
	range = 1;
	noiseIntensity = 0.000088;
	offsetIntensity = 0.0002;

	self.huds["shaders"]["vhs"] = addShader(self, "sr_vhs");
	self.huds["shaders"]["vhs"].color = (range, noiseIntensity, offsetIntensity);
}

edge()
{
	color = (1, 0, 0);

	self.huds["shaders"]["edge"] = addShader(self, "sr_edge");
	self.huds["shaders"]["edge"].color = color;
}

zoom()
{
	zoomAmount = 0.5;

	self.huds["shaders"]["zoom"] = addShader(self, "sr_zoom");
	self.huds["shaders"]["zoom"].color = (zoomAmount, 0, 0);
}

shake()
{
	shakeSpeedX = 6.0;
	shakeSpeedY = 3.0;
	intensity = 0.05;

	self.huds["shaders"]["shake"] = addShader(self, "sr_shake");
	self.huds["shaders"]["shake"].color = (shakeSpeedX, shakeSpeedY, intensity);
}

addShader(who, name)
{
	shader = addHud(who, 0, 0, 0, "left", "top", 1.4, 1, true);
	shader.horzAlign = "fullscreen";
	shader.vertAlign = "fullscreen";
	shader setShader(name, 640, 480);
	return shader;
}
