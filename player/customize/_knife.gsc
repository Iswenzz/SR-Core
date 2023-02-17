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

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["knife"][i]["id"] = i;
		level.assets["knife"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["knife"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["knife"][i]["item"] = (tableLookup(tableName, 0, i, 3) + "_mp");
		level.assets["knife"][i]["name"] = tableLookup(tableName, 0, i, 4);
		level.assets["knife"][i]["model"] = tableLookup(tableName, 0, i, 5);
		level.assets["knife"][i]["callback"] = sr\player\customize\_knife::pick;
		level.assets["knife"][i]["unlock"] = sr\game\_rank::isKnifeUnlocked;

		precacheItem(level.assets["knife"][i]["item"]);
		precacheModel(level.assets["knife"][i]["model"]);
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

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["knife"][id]["model"]);
}
