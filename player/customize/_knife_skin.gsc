#include sr\sys\_events;
#include sr\player\customize\_main;

main()
{
	precache();

	menu("sr_customize", "knife_skin", ::menu_KnifeSkin);
}

precache()
{
	level.assets["knife_skin"] = [];
	tableName = "mp/knifeSkinTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["knife_skin"][i]["id"] = i;
		level.assets["knife_skin"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["knife_skin"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["knife_skin"][i]["name"] = tableLookup(tableName, 0, i, 3);
		level.assets["knife_skin"][i]["model"] = tableLookup(tableName, 0, i, 4);
		level.assets["knife_skin"][i]["callback"] = sr\player\customize\_knife_skin::pick;
		level.assets["knife_skin"][i]["unlock"] = sr\game\_rank::isKnifeSkinUnlocked;

		precacheModel(level.assets["knife_skin"][i]["model"]);
	}
}

menu_KnifeSkin(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "knife_skin";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Knife Skins");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread build();
}

build()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
    forward = anglesToForward(self getPlayerAngles()) * 25;
	right = anglesToRight(self getPlayerAngles()) * 6;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + eye;

	self buildButtons();
}

pick(id)
{
	if (!self sr\game\_rank::isKnifeSkinUnlocked(id))
		return;

	self setStat(983, id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["knife_skin"][id]["model"]);
}
