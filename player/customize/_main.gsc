#include sr\sys\_events;

initCustomize()
{
	level.customize_max_entries = 10;

	sr\player\customize\_character::main();
	sr\player\customize\_fx::main();
	sr\player\customize\_glove::main();
	sr\player\customize\_knife_skin::main();
	sr\player\customize\_knife::main();
	sr\player\customize\_spray::main();
	sr\player\customize\_theme::main();
	sr\player\customize\_weapon::main();

	menu("sr_customize_category", "open", ::menu_Open);
	menu("sr_customize_category", "close", ::menu_Close);
	menu_multiple("sr_customize_category", "pick", ::menu_Pick);
	menu("sr_customize_category", "next", ::menu_NextPage);
	menu("sr_customize_category", "prev", ::menu_PrevPage);

	event("death", ::deletePreview);
	event("disconnect", ::deletePreview);
}

menu_Open(arg)
{
	self endon("disconnect");
	self endon("death");

	self.customize_open = true;
	self disableWeapons();
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
	self buildButtons();
}

menu_PrevPage(arg)
{
	if (self.customize_page <= 0)
		return;

	self.customize_page--;
	self setClientDvar("sr_customize_page", (self.customize_page + 1) + "/" + self.customize_max_page);
	self buildButtons();
}

menu_Pick(args)
{
	selected = ToInt(args[1]) + (self.customize_page * level.customize_max_entries);
	category = self.customize_category;

	if (isDefined(level.assets[category][selected]))
		self [[level.assets[category][selected]["callback"]]](selected);
}

buildButtons()
{
	self endon("disconnect");

	assets = level.assets[self.customize_category];
	startIndex = self.customize_page * level.customize_max_entries;

	for (i = 0; i < level.customize_max_entries; i++)
	{
		itemIndex = startIndex + i;

		if (!isDefined(assets[itemIndex]))
		{
			self setClientDvar("sr_customize_" + i, "");
			continue;
		}

		switch ([[assets[itemIndex]["unlock"]]](itemIndex))
		{
			case 0:
				self setClientDvar("sr_customize_" + i, fmt("^2LOCKED (%d)^3(%d)",
					assets[itemIndex]["rank"] + 1,
					assets[itemIndex]["prestige"]));
				break;
			case 1:
				self setClientDvar("sr_customize_" + i, assets[itemIndex]["name"]);
				break;
			case 2:
				self setClientDvar("sr_customize_" + i, "^3VIP");
				break;
		}
	}
}

countPages()
{
	count = int(level.assets[self.customize_category].size / level.customize_max_entries);
	count = Ternary(count <= 1, 1, count + 1);
	return count;
}

clean()
{
	self endon("disconnect");

	self.customize_category = "null";
	self.customize_page = 0;
	self setClientDvar("sr_customize_theme", "0");
	self setClientDvar("sr_customize_page", self.customize_page);
}

spawnPreview()
{
	if (isDefined(self.customize_preview))
		return;

	angles = self getPlayerAngles();
	self setPlayerAngles((0, angles[1], 0));

	self.customize_preview = spawn("script_model", self.origin);
	self.customize_preview.angles = (0, 90, 0);
	self thread rotatePreview(self.customize_preview);
}

movePreview(ent)
{
	self endon("customize_close");
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
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

deletePreview()
{
	if (isDefined(self.customize_preview))
		self.customize_preview delete();
}
