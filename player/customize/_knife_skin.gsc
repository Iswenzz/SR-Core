#include sr\sys\_events;
#include sr\player\customize\_main;

init()
{
	precache();

	menu("sr_customize", "knifeskin", ::menu_KnifeSkin);
}

precache()
{
	level.assets["knifeSkin"] = [];
	level.numKnifeSkins = 0;

	tableName = "mp/knifeSkinTable.csv";

	for (idx = 1; isDefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["knifeSkin"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["knifeSkin"][id]["shader"] = tableLookup(tableName, 0, idx, 3);
		level.assets["knifeSkin"][id]["item"] = tableLookup(tableName, 0, idx, 4);
		level.assets["knifeSkin"][id]["name"] = tableLookup(tableName, 0, idx, 5);
		level.assets["knifeSkin"][id]["model"] = tableLookup(tableName, 0, idx, 6);
		level.assets["knifeSkin"][id]["callback"] = sr\player\customize\_knife_skin::pick;
		level.assets["knifeSkin"][id]["unlock"] = sr\game\_rank::isKnifeSkinUnlocked;

		precacheModel(level.assets["knifeSkin"][id]["model"]);
		level.numKnifeSkins++;
	}
}

menu_KnifeSkin(response)
{
	self closeMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "knifeskin";
	self.customize_max_page = countPages(level.assets["knifeSkin"]);
	self setClientDvar("menuName", "Knife Skins");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self thread build(response);
}

build(response)
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
    forward = anglesToForward(self getPlayerAngles()) * 25;
	right = anglesToRight(self getPlayerAngles()) * 7;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + eye;

	buildButtons(level.assets["knifeSkin"]);
}

pick(id)
{
	if (!self sr\game\_rank::isKnifeSkinUnlocked(id))
		return;

	self setStat(983, id);
	self setClientDvar("drui_knife_skin", id);

	if (isDefined(self.customize_preview))
		self.customize_preview setModel(level.assets["knifeSkin"][id]["model"]);
}
