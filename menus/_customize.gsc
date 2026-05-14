#include sr\sys\_events;

main()
{
	level.customize_max_entries = 16;

	menu("sr_customize_category", "open", ::menu_Open);
	menu("sr_customize_category", "close", ::menu_Close);
	menu_multiple("sr_customize_category", "pick", ::menu_Pick);
	menu("sr_customize_category", "next", ::menu_NextPage);
	menu("sr_customize_category", "prev", ::menu_PrevPage);

	menu("sr_customize", "character", ::menu_Character);
	menu("sr_customize", "fx", ::menu_FX);
	menu("sr_customize", "glove", ::menu_Glove);
	menu("sr_customize", "knife_skin", ::menu_KnifeSkin);
	menu("sr_customize", "knife", ::menu_Knife);
	menu("sr_customize", "spray", ::menu_Spray);
	menu("sr_customize", "weapon", ::menu_Weapon);

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

menu_Character(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "character";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Characters");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread buildCharacter();
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
	self thread buildFx();
}

menu_Glove(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "glove";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Gloves");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread buildGlove();
}

menu_Knife(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "knife";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Knifes");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread buildKnife();
}

menu_KnifeSkin(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "knife_skin";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Knife Skins");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread buildKnifeSkin();
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
	self thread buildSpray();
}

menu_Weapon(response)
{
	self closeInGameMenu();
	self clean();
	self openMenu("sr_customize_category");
	self.customize_category = "weapon";
	self.customize_max_page = self countPages();
	self setClientDvar("sr_customize_name", "Weapons");
	self setClientDvar("sr_customize_page", "1/" + self.customize_max_page);
	self spawnPreview();
	self thread buildWeapon();
}

buildCharacter()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
	up = (anglesToUp(self getPlayerAngles()) * 32) * -1;
    forward = anglesToForward(self getPlayerAngles()) * 75;
	right = anglesToRight(self getPlayerAngles()) * 20;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + up + eye;

	self buildButtons();
}

buildFx()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
	forward = anglesToForward(self getPlayerAngles()) * 70;
	left = (anglesToRight(self getPlayerAngles()) * 10) * -1;

	self.customize_preview.origin = forward + left + eye;
	self buildButtons();
}

buildGlove()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
	up = anglesToUp(self getPlayerAngles()) * 7;
    forward = anglesToForward(self getPlayerAngles()) * 45;
	right = anglesToRight(self getPlayerAngles()) * 11;

    self.customize_preview.origin = forward + right + up + eye;
	self buildButtons();
}

buildKnife()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
    forward = anglesToForward(self getPlayerAngles()) * 35;
	right = anglesToRight(self getPlayerAngles()) * 11;

    self.customize_preview.origin = forward + right + eye;
	self buildButtons();
}

buildKnifeSkin()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
    forward = anglesToForward(self getPlayerAngles()) * 25;
	right = anglesToRight(self getPlayerAngles()) * 6;

    self.customize_preview.origin = forward + right + eye;
	self buildButtons();
}

buildSpray()
{
	self endon("disconnect");

	self buildButtons();
}

buildWeapon()
{
	self endon("disconnect");

	eye = self sr\utils\_math::eyePos();
    forward = anglesToForward(self getPlayerAngles()) * 45;
	right = anglesToRight(self getPlayerAngles()) * 11;

    self.customize_preview.origin = forward + right + eye;
	self buildButtons();
}

pickCharacter(id)
{
	if (!self sr\core\_assets::isCharacterUnlocked(id))
		return;

	self setStat(980, id);
	self.customize_preview setModel(level.assets["character"][id]["model"]);
}

pickFx(id)
{
	if (!self sr\core\_assets::isFxUnlocked(id))
		return;

	if (isDefined(self.customize_fx))
		self.customize_fx delete();

	self setStat(986, id);

	if (isDefined(self.customize_preview) && id > 0)
	{
		self.customize_fx = spawn("script_model", self.customize_preview.origin);
		self.customize_fx setModel("tag_origin");
		wait 0.05;

		PlayFXOnTag(level.gfx["viptrail" + id], self.customize_fx, "tag_origin");
		self thread movePreview(self.customize_fx);
	}
}

pickGlove(id)
{
	if (!self sr\core\_assets::isGloveUnlocked(id))
		return;

	self setStat(985, id);
	self.customize_preview setModel(level.assets["glove"][id]["model"]);
}

pickKnife(id)
{
	if (!self sr\core\_assets::isKnifeUnlocked(id))
		return;

	self setStat(982, id);
	self.customize_preview setModel(level.assets["knife"][id]["model"]);
}

pickKnifeSkin(id)
{
	if (!self sr\core\_assets::isKnifeSkinUnlocked(id))
		return;

	self setStat(983, id);
	self.customize_preview setModel(level.assets["knife_skin"][id]["model"]);
}

pickSpray(id)
{
	if (!self sr\core\_assets::isSprayUnlocked(id))
		return;

	self setStat(979, id);
}

pickWeapon(id)
{
	if (!self sr\core\_assets::isWeaponUnlocked(id))
		return;

	self setStat(981, id);
	self.customize_preview setModel(level.assets["weapon"][id]["model"]);
}

buildButtons()
{
	self endon("disconnect");

	assets = level.assets[self.customize_category];
	startIndex = self.customize_page * level.customize_max_entries;

	for (i = 0; i < level.customize_max_entries; i++)
	{
		itemIndex = startIndex + i;
		rank = assets[itemIndex];

		if (!isDefined(rank))
		{
			self setClientDvar("sr_customize_" + i, "");
			continue;
		}

		switch ([[rank["unlock"]]](itemIndex))
		{
			case 0:
				lock = fmt("^2LOCKED (%d)", rank["rank"] + 1);
				if (rank["prestige"])
					lock = fmt("^2LOCKED (%d)^3(%d)", rank["rank"] + 1, rank["prestige"]);
				self setClientDvar("sr_customize_" + i, lock);
				break;
			case 1:
				self setClientDvar("sr_customize_" + i, rank["name"]);
				break;
			case 2:
				self setClientDvar("sr_customize_" + i, "^3VIP");
				break;
		}
	}
}

countPages()
{
	count = int(ceil(level.assets[self.customize_category].size / level.customize_max_entries));
	count = Ternary(count <= 1, 1, count);
	return count;
}

clean()
{
	self endon("disconnect");

	self.customize_category = "null";
	self.customize_page = 0;
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
	right = anglesToRight(self getPlayerAngles()) * 40;
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
