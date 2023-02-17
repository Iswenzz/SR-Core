#include sr\sys\_events;
#include sr\player\customize\_main;

main()
{
	precache();

	menu("sr_customize", "glove", ::menu_Glove);
}

precache()
{
	level.assets["glove"] = [];
	tableName = "mp/gloveTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["glove"][i]["id"] = i;
		level.assets["glove"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["glove"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["glove"][i]["model"] = tableLookup(tableName, 0, i, 3);
		level.assets["glove"][i]["name"] = tableLookup(tableName, 0, i, 4);
		level.assets["glove"][i]["callback"] = sr\player\customize\_glove::pick;
		level.assets["glove"][i]["unlock"] = sr\game\_rank::isGloveUnlocked;

		precacheModel(level.assets["glove"][i]["model"]);
	}
}

menu_Glove(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "glove";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Gloves");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread build();
}

build()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
	up = anglesToUp(self getPlayerAngles()) * 7;
    forward = anglesToForward(self getPlayerAngles()) * 45;
	right = anglesToRight(self getPlayerAngles()) * 11;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + up + eye;

	self buildButtons();
}

pick(id)
{
	if (!self sr\game\_rank::isGloveUnlocked(id))
		return;

	self setStat(985, id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["glove"][id]["model"]);
}
