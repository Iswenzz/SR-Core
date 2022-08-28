#include sr\utils\_common;
#include sr\utils\_hud;

start()
{
	level.creditTime = 20;
	cleanScreen();

	thread showCredit("SR Mod 2016-2022", 2, 40, 17.5, 0);
	thread showCredit("SuX Lolz", 1.8, 80, 17, 2);
	thread showCredit("Additional Help", 2, 140, 14, 3);
	thread showCredit("Sheep Wizard   BraXi   Phelix", 1.6, 180, 14.5, 3.5);
	thread showCredit("IzNoGod   3xP'Noob   xoxor4d   Neko", 1.6, 220, 15, 4);
	thread showCredit("Vc' Blade   n1kjs   Mist", 1.6, 260, 15.5, 4.5);
	thread showCredit("kLeiN   stu   Death", 1.6, 300, 15.5, 4.5);

	wait level.creditTime;
}

showCredit(text, scale, y, duration, startTime)
{
	hud = newHudElem();
	hud.font = "objective";
	hud.fontScale = scale;
	hud SetText(text);
	hud.alignX = "center";
	hud.alignY = "top";
	hud.horzAlign = "center";
	hud.vertAlign = "top";
	hud.x = 0;
	hud.y = y;
	hud.sort = 900;
	hud.glowColor = ToRGB(120, 0, 255);
	hud.glowAlpha = 1;
	hud fade(duration, startTime);
}

fade(duration, startTime)
{
	self.alpha = 0;
	wait startTime;
	self.alpha = 1;

	self fadeIn(1, "right", 2);
	wait duration - startTime;
	self fadeOut(1, "right", 2);
}
