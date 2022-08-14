#include sr\sys\_events;
#include sr\utils\_hud;

main()
{
	precacheShader("sr_shake");

	event("connect", ::shake);
}

shake()
{
	self.huds["shaders"]["shake"] = addHud(self, 0, 0, 1, "left", "top", 1.4, 100, true);
	self.huds["shaders"]["shake"].horzAlign = "fullscreen";
	self.huds["shaders"]["shake"].vertAlign = "fullscreen";
	self.huds["shaders"]["shake"] setShader("sr_shake", 640, 480);
}
