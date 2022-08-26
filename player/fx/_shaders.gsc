#include sr\sys\_events;
#include sr\utils\_hud;

initShaders()
{
	precacheShader("sr_translate");
	precacheShader("sr_shake");
	precacheShader("sr_zoom");
	precacheShader("sr_edge");
	precacheShader("sr_vhs");
	precacheShader("sr_blur");

	event("connect", ::shaders);
}

shaders()
{
	self.huds["shaders"] = [];
}

blur(blurMode, blurAmount, blurSpeed)
{
	self clearShaders();

	blurMode = IfUndef(blurMode, 0);
	blurAmount = IfUndef(blurAmount, 0.5);
	blurSpeed = IfUndef(blurSpeed, 1);

	if (!isDefined(self.huds["shaders"]["blur"]))
		self.huds["shaders"]["blur"] = addShader(self, "sr_blur");

	self.huds["shaders"]["blur"].color = (blurMode, blurAmount, blurSpeed);
	self.huds["shaders"]["blur"].alpha = 1;
}

translate(translateSpeedX, translateSpeedY, intensity)
{
	self clearShaders();

	translateSpeedX = IfUndef(translateSpeedX, 6);
	translateSpeedY = IfUndef(translateSpeedY, 0);
	intensity = IfUndef(intensity, 0.05);

	if (!isDefined(self.huds["shaders"]["translate"]))
		self.huds["shaders"]["translate"] = addShader(self, "sr_translate");

	self.huds["shaders"]["translate"].color = (translateSpeedX, translateSpeedY, intensity);
	self.huds["shaders"]["translate"].alpha = 1;
}

vhs(letterBox, range, noiseIntensity, offsetIntensity)
{
	self clearShaders();

	range = IfUndef(range, 0.1);
	noiseIntensity = IfUndef(noiseIntensity, 0.00088);
	offsetIntensity = IfUndef(offsetIntensity, 0.004);
	letterBox = IfUndef(letterBox, 0.5); // I.E 0.375, 0.875

	if (!isDefined(self.huds["shaders"]["vhs"]))
		self.huds["shaders"]["vhs"] = addShader(self, "sr_vhs");

	self.huds["shaders"]["vhs"].color = (range, noiseIntensity, offsetIntensity);
	self.huds["shaders"]["vhs"].alpha = letterBox;
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

zoom(zoomMode, zoomAmount, zoomSpeed)
{
	self clearShaders();

	zoomMode = IfUndef(zoomMode, 0);
	zoomAmount = IfUndef(zoomAmount, 0.5);
	zoomSpeed = IfUndef(zoomSpeed, 0);

	if (!isDefined(self.huds["shaders"]["zoom"]))
		self.huds["shaders"]["zoom"] = addShader(self, "sr_zoom");

	self.huds["shaders"]["zoom"].color = (zoomMode, zoomAmount, zoomSpeed);
	self.huds["shaders"]["zoom"].alpha = 1;
}

shake(shakeSpeedX, shakeSpeedY, intensity, zoomAmount)
{
	self clearShaders();

	shakeSpeedX = IfUndef(shakeSpeedX, 6.0);
	shakeSpeedY = IfUndef(shakeSpeedY, 3.0);
	zoomAmount = IfUndef(zoomAmount, 0);
	intensity = IfUndef(intensity, 0.05);

	if (!isDefined(self.huds["shaders"]["shake"]))
		self.huds["shaders"]["shake"] = addShader(self, "sr_shake");

	self.huds["shaders"]["shake"].color = (shakeSpeedX, shakeSpeedY, zoomAmount);
	self.huds["shaders"]["shake"].alpha = intensity;
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
