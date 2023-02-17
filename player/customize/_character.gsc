#include sr\sys\_events;
#include sr\player\customize\_main;

main()
{
	precache();

	menu("sr_customize", "character", ::menu_Character);
}

precache()
{
	level.assets["character"] = [];
	tableName = "mp/characterTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["character"][i]["id"] = i;
		level.assets["character"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["character"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["character"][i]["model"] = tableLookup(tableName, 0, i, 3);
		level.assets["character"][i]["handsModel"] = tableLookup(tableName, 0, i, 4);
		level.assets["character"][i]["name"] = tableLookup(tableName, 0, i, 5);
		level.assets["character"][i]["callback"] = sr\player\customize\_character::pick;
		level.assets["character"][i]["unlock"] = sr\game\_rank::isCharacterUnlocked;

		precacheModel(level.assets["character"][i]["model"]);
		precacheModel(level.assets["character"][i]["handsModel"]);
	}
}

menu_Character(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "character";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Characters");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread build();
}

build()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
	up = (anglesToUp(self getPlayerAngles()) * 32) * -1;
    forward = anglesToForward(self getPlayerAngles()) * 75;
	right = anglesToRight(self getPlayerAngles()) * 20;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + up + eye;

	self buildButtons();
}

pick(id)
{
	if (!self sr\game\_rank::isCharacterUnlocked(id))
		return;

	self setStat(980, id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["character"][id]["model"]);
}
