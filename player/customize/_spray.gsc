#include sr\sys\_menu;
#include sr\player\customize\_main;

init()
{
	precache();

	menu("sr_customize", "spray", ::menu_Spray);
}

precache()
{
	level.assets["spray"] = [];
	level.numSprays = 0;

	tableName = "mp/sprayTable.csv";

	for (idx = 1; isdefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["spray"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["spray"][id]["prestige"] = int(tableLookup(tableName, 0, idx, 3));
		level.assets["spray"][id]["effect"] = loadFx(tableLookup(tableName, 0, idx, 4));
		level.assets["spray"][id]["name"] = tableLookup(tableName, 0, idx, 5);
		level.assets["spray"][id]["model"] = "";
		level.assets["spray"][id]["callback"] = sr\player\customize\_spray::pick;
		level.assets["spray"][id]["unlock"] = sr\player\customize\_spray::unlock;

		level.numSprays++;
	}
}

menu_Spray(response)
{
	self closeMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "spray";
	self.customize_max_page = countPages(level.assets["spray"]);
	self setClientDvar("menuName", "Sprays");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self thread build(response);
}

build(response)
{
	self endon("disconnect");

	// angles = self getPlayerAngles();
	// self setPlayerAngles((85, angles[1], 0));

	buildButtons(level.assets["spray"]);
}

unlock(id)
{
	if (id <= -1)
		return 0;
	else if (!self braxi\_rank::isSprayUnlocked(id))
		return 0;
	return 1;
}

pick(id)
{
	if (!self unlock(id))
		return;

	self setStat(979, id);
	self setClientDvar("drui_spray", id);

	// TODO FIND A WAY TO CLEAR FX/DECALS
	// if (isDefined(self.customize_fx))
	// 	self.customize_fx delete();

	// angles = self getPlayerAngles();
	// eye = self getTagOrigin("j_head");
	// forward = eye + vector_scale(anglesToForward(angles), 70);
	// trace = bulletTrace(eye, forward, false, self);

	// if (trace["fraction"] == 1) // we didnt hit the wall or floor
	// 	return true;

	// position = trace["position"] - vector_scale(anglesToForward(angles), -2);
	// angles = vectorToAngles(eye - position);
	// forward = anglesToForward(angles);
	// up = anglesToUp(angles);

	// self.customize_fx = spawnFX(level.assets["spray"][id]["effect"], position, forward, up);
	// triggerFX(self.customize_fx);
}
