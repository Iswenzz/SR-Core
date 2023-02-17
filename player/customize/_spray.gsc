#include sr\sys\_events;
#include sr\player\customize\_main;

main()
{
	precache();

	menu("sr_customize", "spray", ::menu_Spray);
}

precache()
{
	level.assets["spray"] = [];
	tableName = "mp/sprayTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["spray"][i]["id"] = i;
		level.assets["spray"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["spray"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["spray"][i]["type"] = tableLookup(tableName, 0, i, 3);
		level.assets["spray"][i]["effect"] = tableLookup(tableName, 0, i, 4);
		level.assets["spray"][i]["name"] = tableLookup(tableName, 0, i, 5);
		level.assets["spray"][i]["callback"] = sr\player\customize\_spray::pick;
		level.assets["spray"][i]["unlock"] = sr\game\_rank::isSprayUnlocked;

		switch (level.assets["spray"][i]["type"])
		{
			case "fx":
				level.assets["spray"][i]["effect"] = loadFX(level.assets["spray"][i]["effect"]);
				break;
			case "gif":
				precacheModel(level.assets["spray"][i]["effect"]);
				break;
		}
	}
}

menu_Spray(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "spray";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Sprays");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread build();
}

build()
{
	self endon("disconnect");

	self buildButtons();
}

pick(id)
{
	if (!self sr\game\_rank::isSprayUnlocked(id))
		return;

	self setStat(979, id);
}
