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

	for (idx = 1; !IsNullOrEmpty(tableLookup(tableName, 0, idx, 0)); idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["knife_skin"][id]["id"] = id;
		level.assets["knife_skin"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["knife_skin"][id]["prestige"] = 0;
		level.assets["knife_skin"][id]["shader"] = tableLookup(tableName, 0, idx, 3);
		level.assets["knife_skin"][id]["item"] = int(tableLookup(tableName, 0, idx, 4));
		level.assets["knife_skin"][id]["name"] = tableLookup(tableName, 0, idx, 5);
		level.assets["knife_skin"][id]["model"] = tableLookup(tableName, 0, idx, 6);
		level.assets["knife_skin"][id]["callback"] = sr\player\customize\_knife_skin::pick;
		level.assets["knife_skin"][id]["unlock"] = sr\game\_rank::isKnifeSkinUnlocked;

		precacheModel(level.assets["knife_skin"][id]["model"]);
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
