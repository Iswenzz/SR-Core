#include sr\sys\_events;
#include sr\player\customize\_main;

main()
{
	precache();

	menu("sr_customize", "theme", ::menu_Theme);
}

precache()
{
	level.assets["theme"] = [];
	tableName = "mp/themeTable.csv";

	for (idx = 1; isDefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["theme"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["theme"][id]["prestige"] = 0;
		level.assets["theme"][id]["shader"] = tableLookup(tableName, 0, idx, 3);
		level.assets["theme"][id]["item"] = tableLookup(tableName, 0, idx, 4);
		level.assets["theme"][id]["name"] = tableLookup(tableName, 0, idx, 5);
		level.assets["theme"][id]["desc"] = tableLookup(tableName, 0, idx, 6);
		level.assets["theme"][id]["callback"] = sr\player\customize\_theme::pick;
		level.assets["theme"][id]["unlock"] = sr\game\_rank::isThemeUnlocked;
	}
}

menu_Theme(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "theme";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Themes");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread build();
}

build()
{
	self endon("disconnect");
	self setClientDvar("sr_customize_theme", "1");

	self buildButtons();
}

pick(id)
{
	if (!self sr\game\_rank::isThemeUnlocked(id))
		return;

	self setStat(984, id);
}
