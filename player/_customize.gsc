#include sr\sys\_menu;

initCustomize()
{
	level.assets = [];
	level.customize_max_entries = 10;

	precacheMenu("sr_customize");
	precacheMenu("sr_customize_category");

	sr\player\_customize_character::init();
	sr\player\_customize_fx::init();
	sr\player\_customize_glove::init();
	sr\player\_customize_knife_skin::init();
	sr\player\_customize_knife::init();
	sr\player\_customize_spray::init();
	sr\player\_customize_theme::init();
	sr\player\_customize_weapon::init();

	menu("sr_customize_category",			"open",		::menu_Open);
	menu("sr_customize_category",			"close",	::menu_Close);
	menu("sr_customize_category", 			"next", 	::menu_NextPage);
	menu("sr_customize_category", 			"prev", 	::menu_PrevPage);
	menu_multiple("sr_customize_category",	"pick", 	::menu_Pick);
}

menu_Open(arg)
{
	self endon("disconnect");
	self endon("death");

	self.customize_open = true;
	angles = self getPlayerAngles();
	self setPlayerAngles((0, angles[1], 0));

	self disableWeapons();
	self.customize_preview = spawn("script_model", self.origin);
	self.customize_preview.angles = (0, 90, 0);
	self thread rotatePreview(self.customize_preview);
}

menu_Close(arg)
{
	self notify("customize_close");
	self endon("disconnect");

	self enableWeapons();
	self.customize_open = undefined;

	if (isDefined(self.customize_preview))
		self.customize_preview delete();
	if (isDefined(self.customize_fx))
		self.customize_fx delete();
}

menu_NextPage(arg)
{
	if (self.customize_page >= self.customize_max_page - 1)
		return;

	self.customize_page++;
	self setClientDvar("sr_customize_page", (self.customize_page + 1) + "/" + self.customize_max_page);
}

menu_PrevPage(arg)
{
	if (self.customize_page <= 0)
		return;

	self.customize_page--;
	self setClientDvar("sr_customize_page", (self.customize_page + 1) + "/" + self.customize_max_page);
}

menu_Pick(arg)
{
	args = strTok(arg, ":");
	selected = ToInt(args[0]);
	category = self.customize_category;

	if (isDefined(level.assets[category][selected]))
		self [[level.assets[category][selected]["callback"]]](selected);
}

buildButtons(array)
{
	self endon("disconnect");

	startIndex = self.customize_page * level.customize_max_entries;

	for (i = 0; i < level.customize_max_entries; i++)
		self setClientDvar("sr_customize_" + i, "");

	for (i = 0; i < level.customize_max_entries; i++)
	{
		itemIndex = startIndex + i;

		if (!isDefined(array[i]))
			continue;

		switch ([[array[i]["unlock"]]](i))
		{
			case 0:
				self setClientDvar("sr_customize_" + i, fmt("^2LOCKED (%d)", int(array[itemIndex]["rank"]) + 1));
				break;
			case 1:
				self setClientDvar("sr_customize_" + i, array[itemIndex]["name"]);
				break;
			case 2:
				self setClientDvar("sr_customize_" + i, "^3VIP");
				break;
		}
	}
}

countPages(array)
{
	count = int(array.size / level.customize_max_entries);
	count = Ternary(count <= 0, 1, count);
	return count;
}

clean()
{
	self endon("disconnect");

	self.customize_category = "null";
	self.customize_page = 0;
	self setClientDvar("preview_theme", "0");
	self setClientDvar("sr_customize_page", self.customize_page);

	for (i = 0; i < level.customize_max_entries; i++)
		self setClientDvar("sr_customize_" + i, "");
}

movePreview(ent)
{
	self endon("customize_close");
	self endon("disconnect");

	eye = self sr\weapons\_bullet_trace::eyepos();
    forward = anglesToForward(self getPlayerAngles()) * 70;
	right = anglesToRight(self getPlayerAngles()) * 50;
	left = (anglesToRight(self getPlayerAngles()) * 10) * -1;

	oriRight = forward + right + eye;
	oriLeft = forward + left + eye;

	while (isDefined(ent))
	{
		if (isDefined(ent))
			ent moveTo(oriRight, 1, 0.15, 0.15);
		wait 1;
		if (isDefined(ent))
			ent moveTo(oriLeft, 1, 0.15, 0.15);
		wait 1;
	}
}

rotatePreview(ent)
{
	self endon("customize_close");
	self endon("disconnect");

	while (isDefined(ent))
	{
		if (isDefined(ent))
			ent rotateYaw(360, 3);
		wait 2.9;
	}
}
