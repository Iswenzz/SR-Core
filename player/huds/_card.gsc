#include sr\utils\_hud;

hud(attacker, victim)
{
    self endon("disconnect");

	if (attacker == victim || !isPlayer(attacker))
		return;

	self notify("new emblem");
	self endon("new emblem");

    self clean();

	logo1 = level.assets["rank"][attacker.pers["rank"]];
	logo2 = level.assets["rank"][victim.pers["rank"]];

	if (attacker.pers["prestige"] > 0)
		logo1 = level.assets["prestige"][attacker.pers["prestige"]];
	if (victim.pers["prestige"] > 0)
		logo2 = level.assets["prestige"][victim.pers["prestige"]];

	self.huds["card"] = [];
	self.huds["card"]["background"] = addHud(self, 0, 30, 0 , "center", "top", 1.4, 990);
	self.huds["card"]["background"] setShader("black", 300, 64);

	self.huds["card"]["rank_left"] = addHud(self, -120, 35, 0, "center", "top", 1.8, 998);
	self.huds["card"]["rank_left"] setShader(logo1, 64, 64);

	self.huds["card"]["rank_right"] = addHud(self, 120, 35, 0, "center", "top", 1.8, 998);
	self.huds["card"]["rank_right"] setShader(logo2, 64, 64);

	self.huds["card"]["title"] = addHud(self, 0, 50, 5, "center", "top", 1.5, 999);
	self.huds["card"]["title"] setText(attacker.name + " ^7 VS ^7 " + victim.name);
	self.huds["card"]["title"] setPulseFX(30, 100000, 700);
	self.huds["card"]["title"].color = (0.8, 0.8, 0.8);
	self.huds["card"]["title"].glowColor = (0.6, 0.6, 0.6);
	self.huds["card"]["title"].glowAlpha = 1;

	keys = getArrayKeys(self.huds["card"]);
	for (i = 0; i < keys.size; i++)
	{
		self.huds["card"][keys[i]] fadeOverTime(0.3);
		self.huds["card"][keys[i]].alpha = Ternary(keys[i] == "background", 0.5, 1.0);
	}
	wait 3;

	for (i = 0; i < keys.size; i++)
	{
		self.huds["card"][keys[i]] fadeOverTime(0.8);
		self.huds["card"][keys[i]].alpha = 0;
	}
	wait 0.8;

    self clean();
}

clean()
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
