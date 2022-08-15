#include sr\sys\_events;
#include sr\utils\_hud;

main()
{
	precacheShader("sr_shake");

	event("connect", ::shake);
}

shake()
{
	shakeSpeedX = 6.0;
	shakeSpeedY = 3.0;
	intensity = 0.05;

	self.huds["shaders"]["shake"] = addHud(self, 0, 0, 1, "left", "top", 1.4, 1, true);
	self.huds["shaders"]["shake"].horzAlign = "fullscreen";
	self.huds["shaders"]["shake"].vertAlign = "fullscreen";
	self.huds["shaders"]["shake"] setShader("sr_shake", 640, 480);
	self.huds["shaders"]["shake"].color = (shakeSpeedX, shakeSpeedY, intensity);
	self.huds["shaders"]["shake"].color = (0, 0, 0);
}
