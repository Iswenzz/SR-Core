#include sr\sys\_menu;
#include sr\player\_customize;

init()
{
	precache();

	menu("sr_customize", "fx", ::menu_FX);
}

precache()
{
	level.assets["fx"] = [];
	level.numFx = 0;

	tableName = "mp/fxTable.csv";

	for (idx = 1; isdefined(tableLookup(tableName, 0, idx, 0)) && tableLookup(tableName, 0, idx, 0) != ""; idx++)
	{
		id = int(tableLookup(tableName, 0, idx, 1));
		level.assets["fx"][id]["rank"] = (int(tableLookup(tableName, 0, idx, 2)) - 1);
		level.assets["fx"][id]["prestige"] = int(tableLookup(tableName, 0, idx, 3));
		level.assets["fx"][id]["name"] = tableLookup(tableName, 0, idx, 4);
		level.assets["fx"][id]["model"] = "";
		level.assets["fx"][id]["callback"] = sr\player\_customize_fx::pick;
		level.assets["fx"][id]["unlock"] = sr\player\_customize_fx::unlock;

		level.numFx++;
	}
}

menu_FX(response)
{
	self closeMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "fx";
	self.customize_max_page = countPages(level.assets["fx"]);
	self setClientDvar("menuName", "FX");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self thread build(response);
}

build(response)
{
	self endon("disconnect");

	buildButtons(level.assets["fx"]);
}

unlock(id)
{
	if (id <= -1)
		return 0;
	else if (!self sr\sys\_admins::isVIP())
		return 0;
	return 1;
}

pick(id)
{
	self endon("customize_close");
	self endon("disconnect");

	if (!self unlock(id))
		return;

	if (isDefined(self.customize_fx))
		self.customize_fx delete();

	self.vip_trail = id;
	self setClientDvar("drui_fx", id);

	if (self.vip_trail > 0)
	{
		eye = self sr\weapons\_bullet_trace::eyepos();
		forward = anglesToForward(self getPlayerAngles()) * 70;
		left = (anglesToRight(self getPlayerAngles()) * 10) * -1;
		oriLeft = forward + left + eye;

		self.customize_fx = spawn("script_model", oriLeft);
		self.customize_fx setmodel("tag_origin");
		wait 0.05;

		PlayFXOnTag(level.fx["viptrail" + self.vip_trail], self.customize_fx, "tag_origin");
		self thread movePreview(self.customize_fx);
	}
}
