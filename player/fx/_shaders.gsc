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
	precacheShader("sr_glitch");
	precacheShader("sr_psy_glass");
	precacheShader("sr_psy_edge");
	precacheShader("sr_grid");
	precacheShader("sr_loader");
	precacheShader("sr_bokeh");
	precacheShader("sr_bokeh_add");
	precacheShader("sr_bokeh_multiply");

	precacheModel("x_screen");
	precacheModel("x_mirror");
	precacheModel("x_volumetric_clouds");
	precacheModel("x_space_curvature");
	precacheModel("x_aurora");
	precacheModel("x_hexagon");
}

blur(blurMode, blurAmount, blurSpeed)
{
	blurMode = IfUndef(blurMode, 0);
	blurAmount = IfUndef(blurAmount, 0.5);
	blurSpeed = IfUndef(blurSpeed, 1);

	self.huds["shader"] = self addShader("sr_blur");
	self.huds["shader"].color = (blurMode, blurAmount, blurSpeed);
	self.huds["shader"].alpha = 1;
}

translate(translateSpeedX, translateSpeedY, intensity)
{
	translateSpeedX = IfUndef(translateSpeedX, 6);
	translateSpeedY = IfUndef(translateSpeedY, 0);
	intensity = IfUndef(intensity, 0.05);

	self.huds["shader"] = self addShader("sr_translate");
	self.huds["shader"].color = (translateSpeedX, translateSpeedY, intensity);
	self.huds["shader"].alpha = 1;
}

vhs(letterBox, range, noiseIntensity, offsetIntensity)
{
	range = IfUndef(range, 0.1);
	noiseIntensity = IfUndef(noiseIntensity, 0.00088);
	offsetIntensity = IfUndef(offsetIntensity, 0.004);
	letterBox = IfUndef(letterBox, 0.375); // I.E 0.375, 0.875

	self.huds["shader"] = self addShader("sr_vhs");
	self.huds["shader"].color = (range, noiseIntensity, offsetIntensity);
	self.huds["shader"].alpha = letterBox;
}

edge(color, alpha)
{
	color = IfUndef(color, (1, 1, 1));
	alpha = IfUndef(alpha, 1);

	self.huds["shader"] = self addShader("sr_edge");
	self.huds["shader"].color = color;
	self.huds["shader"].alpha = alpha;
}

zoom(zoomMode, zoomAmount, zoomSpeed)
{
	zoomMode = IfUndef(zoomMode, 0);
	zoomAmount = IfUndef(zoomAmount, 0.5);
	zoomSpeed = IfUndef(zoomSpeed, 0.05);

	self.huds["shader"] = self addShader("sr_zoom");
	self.huds["shader"].color = (zoomMode, zoomAmount, zoomSpeed);
	self.huds["shader"].alpha = 1;
}

shake(shakeSpeedX, shakeSpeedY, intensity, zoomAmount)
{
	shakeSpeedX = IfUndef(shakeSpeedX, 0.2);
	shakeSpeedY = IfUndef(shakeSpeedY, 0.1);
	zoomAmount = IfUndef(zoomAmount, 0.05);
	intensity = IfUndef(intensity, 0.05);

	self.huds["shader"] = self addShader("sr_shake");
	self.huds["shader"].color = (shakeSpeedX, shakeSpeedY, zoomAmount);
	self.huds["shader"].alpha = intensity;
}

psyEdge(color)
{
	self.huds["shader"] = self addShader("sr_psy_edge");
	self.huds["shader"].color = color;
	self.huds["shader"].alpha = 1;
}

psyGlass(blend)
{
	blend = IfUndef(blend, 0.4);

	self.huds["shader"] = self addShader("sr_psy_glass");
	self.huds["shader"].color = (blend, 0, 0);
	self.huds["shader"].alpha = 1;
}

glitch(amt, speed)
{
	amt = IfUndef(amt, 0.5);
	speed = IfUndef(speed, 0.043);

	self.huds["shader"] = self addShader("sr_glitch");
	self.huds["shader"].color = (amt, speed, 0);
	self.huds["shader"].alpha = 1;
}

vision()
{
	self.huds["shader"] = self addShader("sr_translate");
	self.huds["shader"].color = (0, 0, 0);
	self.huds["shader"].alpha = 1;
}

removeShaders()
{
	if (isDefined(self.huds["shader"]))
	{
		self.huds["shader"] destroy();
		self.huds["shader"] = undefined;
	}
}

addShader(name)
{
	shader = self.huds["shader"];
	if (!isDefined(shader))
	{
		shader = addHud(self, 0, 0, 0, "left", "top", 1.4, 0, true);
		shader.horzAlign = "fullscreen";
		shader.vertAlign = "fullscreen";
		shader.archived = true;
		shader.sort = 0;
	}
	shader setShader(name, 640, 480);

	return shader;
}
