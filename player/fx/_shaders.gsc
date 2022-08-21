#include sr\sys\_events;
#include sr\utils\_hud;

initShaders()
{
	precacheShader("sr_shake");
	precacheShader("sr_zoom");
	precacheShader("sr_edge");
	precacheShader("sr_vhs");
	precacheShader("sr_motion_blur");

	event("connect", ::shaders);
}

shaders()
{
	self.huds["shaders"] = [];
}

motionBlur(blurAmount)
{
	self clearShaders();

	blurAmount = IfUndef(blurAmount, 0.6);

	if (!isDefined(self.huds["shaders"]["motion_blur"]))
		self.huds["shaders"]["motion_blur"] = addShader(self, "sr_motion_blur");

	self.huds["shaders"]["motion_blur"].alpha = blurAmount;
}

vhs(range, noiseIntensity, offsetIntensity)
{
	self clearShaders();

	range = IfUndef(range, 1);
	noiseIntensity = IfUndef(noiseIntensity, 0.000088);
	offsetIntensity = IfUndef(offsetIntensity, 0.0002);

	if (!isDefined(self.huds["shaders"]["vhs"]))
		self.huds["shaders"]["vhs"] = addShader(self, "sr_vhs");

	self.huds["shaders"]["vhs"].color = (range, noiseIntensity, offsetIntensity);
	self.huds["shaders"]["vhs"].alpha = 1;
}

edge(color, alpha)
{
	self clearShaders();

	color = IfUndef(color, (1, 1, 1));
	alpha = IfUndef(alpha, 1);

	if (!isDefined(self.huds["shaders"]["edge"]))
		self.huds["shaders"]["edge"] = addShader(self, "sr_edge");

	self.huds["shaders"]["edge"].color = color;
	self.huds["shaders"]["edge"].alpha = alpha;
}

zoom(zoomAmount)
{
	self clearShaders();

	zoomAmount = IfUndef(zoomAmount, 0.5);

	if (!isDefined(self.huds["shaders"]["zoom"]))
		self.huds["shaders"]["zoom"] = addShader(self, "sr_zoom");

	self.huds["shaders"]["zoom"].color = (zoomAmount, 0, 0);
	self.huds["shaders"]["zoom"].alpha = 1;
}

shake(shakeSpeedX, shakeSpeedY, intensity)
{
	self clearShaders();

	shakeSpeedX = IfUndef(shakeSpeedX, 6.0);
	shakeSpeedY = IfUndef(shakeSpeedY, 3.0);
	intensity = IfUndef(intensity, 0.05);

	if (!isDefined(self.huds["shaders"]["shake"]))
		self.huds["shaders"]["shake"] = addShader(self, "sr_shake");

	self.huds["shaders"]["shake"].color = (shakeSpeedX, shakeSpeedY, intensity);
	self.huds["shaders"]["shake"].alpha = 1;
}

clearShaders()
{
	if (!isDefined(self.huds["shaders"]))
		return;

	keys = getArrayKeys(self.huds["shaders"]);
	for (i = 0; i < keys.size; i++)
	{
		if (isDefined(self.huds["shaders"][keys[i]]))
			self.huds["shaders"][keys[i]].alpha = 0;
	}
}

removeShaders()
{
	if (!isDefined(self.huds["shaders"]))
		return;

	keys = getArrayKeys(self.huds["shaders"]);
	for (i = 0; i < keys.size; i++)
	{
		if (isDefined(self.huds["shaders"][keys[i]]))
			self.huds["shaders"][keys[i]] destroy();
	}
}

addShader(who, name)
{
	shader = addHud(who, 0, 0, 0, "left", "top", 1.4, 1, true);
	shader.horzAlign = "fullscreen";
	shader.vertAlign = "fullscreen";
	shader setShader(name, 640, 480);
	return shader;
}
