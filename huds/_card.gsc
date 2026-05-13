#include sr\utils\_hud;

hud(attacker, victim)
{
	if (!isDefined(self) || attacker == victim || !isPlayer(attacker))
		return;

    self endon("disconnect");
	self notify("new emblem");
	wait 0.05;
	self endon("new emblem");

    self clear();

	logo1 = level.assets["rank"][attacker.pers["rank"]];
	logo2 = level.assets["rank"][victim.pers["rank"]];

	if (attacker.pers["prestige"] > 0)
		logo1 = level.assets["prestige"][attacker.pers["prestige"]];
	if (victim.pers["prestige"] > 0)
		logo2 = level.assets["prestige"][victim.pers["prestige"]];

	self.huds["card"] = [];
	self.huds["card"]["background"] = addHud(self, 0, 30, 0.9, "center", "top", 1.4, 990, true);
	self.huds["card"]["background"].color = (0, 0, 0);
	self.huds["card"]["background"] setShader("sr_bokeh", 300, 64);
	self.huds["card"]["background"] thread fadeIn(0, 1);

	self.huds["card"]["rank_left"] = addHud(self, -120, 35, 1, "center", "top", 1.8, 998, true);
	self.huds["card"]["rank_left"] setShader(logo1, 64, 64);
	self.huds["card"]["rank_left"] thread fadeIn(0, 1);

	self.huds["card"]["rank_right"] = addHud(self, 120, 35, 1, "center", "top", 1.8, 998, true);
	self.huds["card"]["rank_right"] setShader(logo2, 64, 64);
	self.huds["card"]["rank_right"] thread fadeIn(0, 1);

	self.huds["card"]["title"] = addHud(self, 0, 50, 1, "center", "top", 1.5, 999, true);
	self.huds["card"]["title"] setText(attacker.name + " ^7 VS ^7 " + victim.name);
	self.huds["card"]["title"] setPulseFX(30, 100000, 700);
	self.huds["card"]["title"] thread fadeIn(0, 1);
	self.huds["card"]["title"].color = (0.8, 0.8, 0.8);
	self.huds["card"]["title"].glowColor = (0.6, 0.6, 0.6);
	self.huds["card"]["title"].glowAlpha = 1;

	wait 3;
	keys = getArrayKeys(self.huds["card"]);
	for (i = 0; i < keys.size; i++)
		self.huds["card"][keys[i]] thread fadeOut(0, 1);
	wait 3;

    self clear();
}

clear()
{
    if (!isDefined(self.huds["card"]))
		return;

	keys = getArrayKeys(self.huds["card"]);
	for (i = 0; i < keys.size; i++)
	{
		if (isDefined(self.huds["card"][keys[i]]))
			self.huds["card"][keys[i]] destroy();
	}
}
