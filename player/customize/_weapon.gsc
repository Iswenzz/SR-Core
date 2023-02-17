#include sr\sys\_events;
#include sr\player\customize\_main;

main()
{
	precache();

	menu("sr_customize", "weapon", ::menu_Weapon);
}

precache()
{
	level.assets["weapon"] = [];
	tableName = "mp/itemTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["weapon"][i]["id"] = i;
		level.assets["weapon"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["weapon"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["weapon"][i]["item"] = (tableLookup(tableName, 0, i, 3) + "_mp");
		level.assets["weapon"][i]["name"] = tableLookup(tableName, 0, i, 4);
		level.assets["weapon"][i]["model"] = getWeaponModel(level.assets["weapon"][i]["item"]);
		level.assets["weapon"][i]["callback"] = sr\player\customize\_weapon::pick;
		level.assets["weapon"][i]["unlock"] = sr\game\_rank::isWeaponUnlocked;

		precacheItem(level.assets["weapon"][i]["item"]);
		precacheModel(level.assets["weapon"][i]["model"]);
	}
}

menu_Weapon(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "weapon";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Weapons");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread build();
}

build()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
    forward = anglesToForward(self getPlayerAngles()) * 45;
	right = anglesToRight(self getPlayerAngles()) * 11;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + eye;

	self buildButtons();
}

pick(id)
{
	if (!self sr\game\_rank::isWeaponUnlocked(id))
		return;

	self setStat(981, id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["weapon"][id]["model"]);
}
