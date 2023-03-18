#include sr\sys\_events;
#include sr\utils\_common;
#include sr\game\menus\_main;

main()
{
	event("connect", ::onConnect);
	event("spawn", ::onSpawn);

	main = menuElement("Main", "shop", "main");

    // Main
	menuOption(main, "Life", 			::menu_Life, 50);
	menuOption(main, "Heal", 			::menu_Heal, 50);
	menuOption(main, "Dog", 			::menu_Dog, 75);
	menuOption(main, "Random Weapon", 	::menu_RandomWeapon, 150);
	menuOption(main, "Random Perk", 	::menu_RandomPerk, 150);
	menuOption(main, "200 XP", 			::menu_XP, 200);
	menuOption(main, "Portal", 			::menu_Portal, 250);
	menuOption(main, "Defrag", 			::menu_Defrag, 250);
	menuOption(main, "Unlimited Ammo", 	::menu_UAmmo, 300);
	menuOption(main, "Party Mode", 		::menu_PartyMode, 400);
}

onConnect()
{
	self endon("disconnect");

	if (level.freeRun)
		return;

    self thread loop("shop", "shop_mp");
	self.pers["shopPoints"] = self getStat(2358);

	while (true)
	{
		wait 30;

		if (self.pers["shopPoints"] >= 500)
			continue;
		self.pers["shopPoints"]++;
		self setStat(2358, self.pers["shopPoints"]);
	}
}

onSpawn()
{
	self endon("spawned");
	self endon("disconnect");
	self endon("death");

	while (true)
	{
		self waittill("scriptmenu_open", id);
		if (id != "shop")
			continue;

		self.huds["script_menu"]["options"] setText(self getOptions());
		self.huds["script_menu"]["help"] setText(self getHelp());
	}
}

menu_Life(points)
{
	if (!self canBuy(points))
		return;

	self deathrun\game\_game::giveLife();
	self pm("^2You bought an additional life !");
	self done();
}

menu_Heal(points)
{
	if (!self canBuy(points))
		return;

	self cheat();
	self.health = self.maxhealth;

	self pm("^2Health restored !");
	self done();
}

menu_Dog(points)
{
	if (!self canBuy(points))
		return;

	self pm("^2Dogo !");
	self done();

	wait 0.5;
	self deathrun\game\_game::dog();
}

menu_RandomWeapon(points)
{
	if (!self canBuy(points))
		return;

	asset = level.assets["weapon"][randomInt(level.assets["weapon"].size)];
	weapon = asset["item"];
	name = asset["name"];

	self pm(fmt("^2You got %s !", name));
	self done();

	wait 0.5;
	self cheat();
	self giveWeapon(weapon);
	self switchToWeapon(weapon);
}

menu_RandomPerk(points)
{
	if (!self canBuy(points))
		return;

	self cheat();
	keys = getArrayKeys(level.perks);
	perk = level.perks[keys[randomInt(keys.size)]];
	self sr\game\_perks::playerSetPerk(perk.id);

	self pm(fmt("^2You got %s !", perk.name));
	self done();
}

menu_UAmmo(points)
{
	if (!self canBuy(points))
		return;

	self cheat();
	self sr\commands\_player::unlimitedAmmo();

	self pm("^2You got unlimited ammo !");
	self done();
}

menu_XP(points)
{
	if (!self canBuy(points))
		return;

	self sr\game\_rank::giveRankXP("", 200);

	self pm("^2You got 200 XP !");
	self done();
}

menu_PartyMode(points)
{
	if (!self canBuy(points))
		return;

	alias = fmt("end_map%d", randomIntRange(1, 9));
	thread sr\game\music\_main::play(alias);

	self message(fmt("%s ^5throw a party !!!", self.name));
	self done();
}

menu_Portal(points)
{
	if (!self canBuy(points))
		return;

	self deathrun\player\run\_portal::start();

	self pm("^5Portal mode !");
	self done();
}

menu_Defrag(points)
{
	if (!self canBuy(points))
		return;

	self deathrun\player\run\_defrag::start();

	self pm("^3Defrag mode !");
	self done();
}

canBuy(points)
{
	if (self.pers["shopPoints"] < points)
	{
		self pm("^1Not enough points for this item !");
		self done();
		return false;
	}
	self.pers["shopPoints"] -= points;
	self setStat(2358, self.pers["shopPoints"]);
	return true;
}

getOptions()
{
	options = "";
	for (i = 0; i < level.huds["script_menu"]["shop"]["main"].size; i++)
	{
		item = level.huds["script_menu"]["shop"]["main"][i];

		points = fmt("%s[%d]", Ternary(self.pers["shopPoints"] >= item.args, "^2", "^1"), item.args);
		options += fmt("%s^7 %s\n", points, level.huds["script_menu"]["shop"]["main"][i].name);
	}
	return options;
}

getHelp()
{
	return fmt("^2Points: ^7%d\n\n^5Select: [Right or Left Mouse]\nUse: [[{+activate}]]\nLeave: [[{+melee}]]", self.pers["shopPoints"]);
}
