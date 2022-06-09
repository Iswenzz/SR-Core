#include sr\utils\_common;

start()
{
	level.creditTime = 0;

	cleanScreen();

	showCredit("SR Mod (c) 2016-2022", 2, 80, 0.5);
	showCredit("SuX Lolz", 1.8, 120, 1);
	showCredit("Additional Help", 2, 160, 0.5);
	showCredit("Sheep Wizard", 1.7, 200, 0.5);
	showCredit("IzNoGod", 1.7, 240, 0.5);
	showCredit("Vc' Blade", 1.7, 280, 0.5);
	showCredit("3xP' Noob", 1.7, 320, 1);

	wait 2;
}

showCredit(text, scale, y, time)
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
	hud.sort = -1;
	hud.glowColor = (119 / 255, 0 / 255, 255 / 255);
	hud.glowAlpha = 1;
	hud.alpha = 0;
	hud fadeOverTime(1);
	hud.alpha = 1;
	hud.foreground = true;
	hud thread fadeCredit();

	level.creditTime += time;
	wait time;
}

fadeCredit()
{
	wait level.creditTime;
	self fadeOverTime(1);
	self.alpha = 0;
	wait 1;
	self destroy();
}

neon()
{
	neon = addNeon("", 1.4);
	while (true)
	{
		neon moveOverTime(12);
		neon.x = 800;
		wait 15;

		neon moveOverTime(12);
		neon.x = -800;
		wait 15;
	}
}

addNeon(text, scale)
{
	text = newHudElem();
	text.font = "objective";
	text.fontScale = scale;
	text SetText(text);
	text.alignX = "center";
	text.alignY = "top";
	text.horzAlign = "center";
	text.vertAlign = "top";
	text.x = -200;
	text.y = 8;
	text.sort = -1;
	text.alpha = 1;
	text.foreground = true;
	return text;
}
