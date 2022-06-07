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

	for (idx = 1; isDefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["weapon"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["weapon"][id]["prestige"] = int(tableLookup(tableName, 0, idx, 3));
		level.assets["weapon"][id]["item"] = (tableLookup(tableName, 0, idx, 4) + "_mp");
		level.assets["weapon"][id]["name"] = tableLookup(tableName, 0, idx, 5);
		level.assets["weapon"][id]["desc"] = tableLookup(tableName, 0, idx, 6);
		level.assets["weapon"][id]["model"] = getWeaponModel(level.assets["weapon"][id]["item"]);
		level.assets["weapon"][id]["callback"] = sr\player\customize\_weapon::pick;
		level.assets["weapon"][id]["unlock"] = sr\game\_rank::isWeaponUnlocked;

		precacheItem(level.assets["weapon"][id]["item"]);
	}
}

menu_Weapon(response)
{
	self closeMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "weapon";
	self.customize_max_page = countPages(level.assets["weapon"]);
	self setClientDvar("menuName", "Weapons");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self thread build(response);
}

build(response)
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
    forward = anglesToForward(self getPlayerAngles()) * 45;
	right = anglesToRight(self getPlayerAngles()) * 13;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + eye;

	buildButtons(level.assets["weapon"]);
}

pick(id)
{
	if (!self sr\game\_rank::isWeaponUnlocked(id))
		return;

	self setStat(981, id);
	self setClientDvar("drui_weapon", id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["weapon"][id]["model"]);
}
