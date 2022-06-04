#include sr\sys\_menu;
#include sr\player\customize\_main;

init()
{
	precache();

	menu("sr_customize", "glove", ::menu_Glove);
}

precache()
{
	level.assets["glove"] = [];
	level.numGlove = 0;

	tableName = "mp/gloveTable.csv";

	for (idx = 1; isDefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["glove"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["glove"][id]["prestige"] = int(tableLookup(tableName, 0, idx, 3));
		level.assets["glove"][id]["model"] = tableLookup(tableName, 0, idx, 4);
		level.assets["glove"][id]["name"] = tableLookup(tableName, 0, idx, 5);
		level.assets["glove"][id]["callback"] = sr\player\customize\_glove::pick;
		level.assets["glove"][id]["unlock"] = sr\game\_rank::isGloveUnlocked;

		precacheModel(level.assets["glove"][id]["model"]);
		level.numGlove++;
	}
}

menu_Glove(response)
{
	self closeMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "glove";
	self.customize_max_page = countPages(level.assets["glove"]);
	self setClientDvar("menuName", "Gloves");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self thread build(response);
}

build(response)
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
	up = anglesToUp(self getPlayerAngles()) * 7;
    forward = anglesToForward(self getPlayerAngles()) * 45;
	right = anglesToRight(self getPlayerAngles()) * 13;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + up + eye;

	buildButtons(level.assets["glove"]);
}

pick(id)
{
	if (!self sr\game\_rank::isGloveUnlocked(id))
		return;

	self setStat(985, id);
	self setClientDvar("drui_glove", id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["glove"][id]["model"]);
}
