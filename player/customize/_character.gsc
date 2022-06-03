#include sr\sys\_menu;
#include sr\player\customize\_main;

init()
{
	precache();

	menu("sr_customize", "character", ::menu_Character);
}

precache()
{
	level.assets["character"] = [];
	level.numCharacters = 0;

	tableName = "mp/characterTable.csv";

	for (idx = 1; isDefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["character"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["character"][id]["prestige"] = int(tableLookup(tableName, 0, idx, 3));
		level.assets["character"][id]["model"] = tableLookup(tableName, 0, idx, 4);
		level.assets["character"][id]["handsModel"] = tableLookup(tableName, 0, idx, 5);
		level.assets["character"][id]["name"] = tableLookup(tableName, 0, idx, 6);
		level.assets["character"][id]["desc"] = tableLookup(tableName, 0, idx, 7);
		level.assets["character"][id]["callback"] = sr\player\customize\_character::pick;
		level.assets["character"][id]["unlock"] = sr\sys\_rank::isCharacterUnlocked;

		precacheModel(level.assets["character"][id]["model"]);
		precacheModel(level.assets["character"][id]["handsModel"]);
		level.numCharacters++;
	}
}

menu_Character(response)
{
	self closeMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "character";
	self.customize_max_page = countPages(level.assets["character"]);
	self setClientDvar("menuName", "Characters");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self thread build(response);
}

build(response)
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
	up = (anglesToUp(self getPlayerAngles()) * 32) * -1;
    forward = anglesToForward(self getPlayerAngles()) * 75;
	right = anglesToRight(self getPlayerAngles()) * 25;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + up + eye;

	buildButtons(level.assets["character"]);
}

pick(id)
{
	if (!self sr\sys\_rank::isCharacterUnlocked(id))
		return;

	self setStat(980, id);
	self setClientDvar("drui_character", id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["character"][id]["model"]);
}
