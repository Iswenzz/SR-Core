#include sr\sys\_events;
#include sr\player\customize\_main;

main()
{
	precache();

	menu("sr_customize", "fx", ::menu_FX);
}

precache()
{
	level.assets["fx"] = [];
	tableName = "mp/fxTable.csv";

	for (idx = 1; isDefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["fx"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["fx"][id]["prestige"] = int(tableLookup(tableName, 0, idx, 3));
		level.assets["fx"][id]["name"] = tableLookup(tableName, 0, idx, 4);
		level.assets["fx"][id]["callback"] = sr\player\customize\_fx::pick;
		level.assets["fx"][id]["unlock"] = sr\game\_rank::isFxUnlocked;
	}
}

menu_FX(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "fx";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "FX");
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
	self endon("customize_close");
	self endon("disconnect");

	if (!self sr\game\_rank::isFxUnlocked(id))
		return;

	if (isDefined(self.customize_fx))
		self.customize_fx delete();

	self.vip_trail = id;
	self setStat(986, id);
	self setClientDvar("drui_fx", id);

	if (self.vip_trail > 0)
	{
		eye = self sr\utils\_math::eyePos();
		forward = anglesToForward(self getPlayerAngles()) * 70;
		left = (anglesToRight(self getPlayerAngles()) * 10) * -1;
		oriLeft = forward + left + eye;

		self.customize_fx = spawn("script_model", oriLeft);
		self.customize_fx setModel("tag_origin");
		wait 0.05;

		PlayFXOnTag(level.gfx["viptrail" + self.vip_trail], self.customize_fx, "tag_origin");
		self thread movePreview(self.customize_fx);
	}
}
