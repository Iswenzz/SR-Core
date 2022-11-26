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

	for (idx = 1; isDefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["spray"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["spray"][id]["prestige"] = int(tableLookup(tableName, 0, idx, 3));
		level.assets["spray"][id]["type"] = tableLookup(tableName, 0, idx, 4);
		level.assets["spray"][id]["effect"] = tableLookup(tableName, 0, idx, 5);
		level.assets["spray"][id]["name"] = tableLookup(tableName, 0, idx, 6);
		level.assets["spray"][id]["callback"] = sr\player\customize\_spray::pick;
		level.assets["spray"][id]["unlock"] = sr\game\_rank::isSprayUnlocked;

		switch (level.assets["spray"][id]["type"])
		{
			case "fx":
				level.assets["spray"][id]["effect"] = loadFX(level.assets["spray"][id]["effect"]);
				break;
			case "gif":
				precacheModel(level.assets["spray"][id]["effect"]);
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

	// angles = self getPlayerAngles();
	// self setPlayerAngles((85, angles[1], 0));

	self buildButtons();
}

pick(id)
{
	if (!self sr\game\_rank::isSprayUnlocked(id))
		return;

	self setStat(979, id);
	self setClientDvar("drui_spray", id);

	// TODO FIND A WAY TO CLEAR FX/DECALS
	// if (isDefined(self.customize_fx))
	// 	self.customize_fx delete();

	// angles = self getPlayerAngles();
	// eye = self getTagOrigin("j_head");
	// forward = eye + vectorScale(anglesToForward(angles), 70);
	// trace = bulletTrace(eye, forward, false, self);

	// if (trace["fraction"] == 1) // we didnt hit the wall or floor
	// 	return true;

	// position = trace["position"] - vectorScale(anglesToForward(angles), -2);
	// angles = vectorToAngles(eye - position);
	// forward = anglesToForward(angles);
	// up = anglesToUp(angles);

	// self.customize_fx = spawnFX(level.assets["spray"][id]["effect"], position, forward, up);
	// triggerFX(self.customize_fx);
}
