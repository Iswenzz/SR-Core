#include sr\sys\_menu;
#include sr\player\customize\_main;

init()
{
	precache();

	menu("sr_customize", "theme", ::menu_Theme);
}

precache()
{
	level.assets["theme"] = [];
	level.numTheme = 0;

	tableName = "mp/themeTable.csv";

	for (idx = 1; isdefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["theme"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["theme"][id]["shader"] = tableLookup(tableName, 0, idx, 3);
		level.assets["theme"][id]["item"] = tableLookup(tableName, 0, idx, 4);
		level.assets["theme"][id]["name"] = tableLookup(tableName, 0, idx, 5);
		level.assets["theme"][id]["desc"] = tableLookup(tableName, 0, idx, 6);
		level.assets["theme"][id]["model"] = "";
		level.assets["theme"][id]["callback"] = sr\player\customize\_theme::pick;
		level.assets["theme"][id]["unlock"] = sr\player\customize\_theme::unlock;

		level.numTheme++;
	}
}

menu_Theme(response)
{
	self closeMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "theme";
	self.customize_max_page = countPages(level.assets["theme"]);
	self setClientDvar("menuName", "Themes");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self thread build(response);
}

build(response)
{
	self endon("disconnect");
	self setClientDvar("preview_theme", "1");

	buildButtons(level.assets["theme"]);
}

unlock(id)
{
	if (id <= -1)
		return false;
	return true;
}

pick(id)
{
	if (!self unlock(id))
		return;

	self setStat(984, id);
}
