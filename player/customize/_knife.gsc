#include sr\sys\_events;
#include sr\player\customize\_main;

main()
{
	precache();

	menu("sr_customize", "knife", ::menu_Knife);
}

precache()
{
	level.assets["knife"] = [];
	tableName = "mp/knifeTable.csv";

	for (idx = 1; !IsNullOrEmpty(tableLookup(tableName, 0, idx, 0)); idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["knife"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["knife"][id]["prestige"] = int(tableLookup(tableName, 0, idx, 3));
		level.assets["knife"][id]["item"] = (tableLookup(tableName, 0, idx, 4) + "_mp");
		level.assets["knife"][id]["name"] = tableLookup(tableName, 0, idx, 5);
		level.assets["knife"][id]["model"] = tableLookup(tableName, 0, idx, 6);
		level.assets["knife"][id]["callback"] = sr\player\customize\_knife::pick;
		level.assets["knife"][id]["unlock"] = sr\game\_rank::isKnifeUnlocked;

		precacheItem(level.assets["knife"][id]["item"]);
		precacheModel(level.assets["knife"][id]["model"]);
	}
}

menu_Knife(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "knife";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Knifes");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread build();
}

build()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
    forward = anglesToForward(self getPlayerAngles()) * 35;
	right = anglesToRight(self getPlayerAngles()) * 11;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + eye;

	self buildButtons();
}

pick(id)
{
	if (!self sr\game\_rank::isKnifeUnlocked(id))
		return;

	self setStat(982, id);
	self setClientDvar("drui_knife", id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["knife"][id]["model"]);
}
