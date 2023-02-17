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

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["fx"][i]["id"] = i;
		level.assets["fx"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["fx"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["fx"][i]["name"] = tableLookup(tableName, 0, i, 3);
		level.assets["fx"][i]["callback"] = sr\player\customize\_fx::pick;
		level.assets["fx"][i]["unlock"] = sr\game\_rank::isFxUnlocked;
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

	self setStat(986, id);

	if (id > 0)
	{
		eye = self sr\utils\_math::eyePos();
		forward = anglesToForward(self getPlayerAngles()) * 70;
		left = (anglesToRight(self getPlayerAngles()) * 10) * -1;
		oriLeft = forward + left + eye;

		self.customize_fx = spawn("script_model", oriLeft);
		self.customize_fx setModel("tag_origin");
		wait 0.05;

		PlayFXOnTag(level.gfx["viptrail" + id], self.customize_fx, "tag_origin");
		self thread movePreview(self.customize_fx);
	}
}
