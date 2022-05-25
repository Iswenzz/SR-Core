/*

  _|_|_|            _|      _|      _|                  _|
_|        _|    _|    _|  _|        _|          _|_|    _|  _|_|_|_|
  _|_|    _|    _|      _|          _|        _|    _|  _|      _|
      _|  _|    _|    _|  _|        _|        _|    _|  _|    _|
_|_|_|      _|_|_|  _|      _|      _|_|_|_|    _|_|    _|  _|_|_|_|

Script made by SuX Lolz (Iswenzz) and Sheep Wizard

Steam: http://steamcommunity.com/profiles/76561198163403316/
Discord: https://discord.gg/76aHfGF
Youtube: https://www.youtube.com/channel/UC1vxOXBzEF7W4g7TRU0C1rw
Paypal: suxlolz@outlook.fr
Email Pro: suxlolz1528@gmail.com

*/
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

#include braxi\_common;

executeResponse(menu, response)
{
	self endon("disconnect");
	tkn = strTok(response, ":");

	// direct menu call
	switch (tkn[1])
	{
		case "init": self initCustomizeMenu(); break;
		case "close": self closeCustomizeMenu(); break;
	}
	if (menu == "sr_customize")
	{
		// switch menu
		switch (tkn[1])
		{
			case "weapon":
				self closeMenu();
				self cleanArea();
				self openMenu("sr_customize_area");
				self.customize_area = "weapon";
				self.customize_maxpage = 4;
				self setClientDvar("menuName", "Weapons");
				self setClientDvar("sr_customize_page", "1/" + (self.customize_maxpage + 1));
				self thread buildWeaponMenu(response);
				break;
			case "character":
				self closeMenu();
				self cleanArea();
				self openMenu("sr_customize_area");
				self.customize_area = "character";
				self.customize_maxpage = 3;
				self setClientDvar("menuName", "Characters");
				self setClientDvar("sr_customize_page", "1/" + (self.customize_maxpage + 1));
				self thread buildCharacterMenu(response);
				break;
			case "knife":
				self closeMenu();
				self cleanArea();
				self openMenu("sr_customize_area");
				self.customize_area = "knife";
				self.customize_maxpage = 0;
				self setClientDvar("menuName", "Knifes");
				self setClientDvar("sr_customize_page", "1/" + (self.customize_maxpage + 1));
				self thread buildKnifeMenu(response);
				break;
			case "spray":
				self closeMenu();
				self cleanArea();
				self openMenu("sr_customize_area");
				self.customize_area = "spray";
				self.customize_maxpage = 2;
				self setClientDvar("menuName", "Sprays");
				self setClientDvar("sr_customize_page", "1/" + (self.customize_maxpage + 1));
				self thread buildSprayMenu(response);
				break;
			case "knifeskin":
				self closeMenu();
				self cleanArea();
				self openMenu("sr_customize_area");
				self.customize_area = "knifeskin";
				self.customize_maxpage = 0;
				self setClientDvar("menuName", "Knife Skins");
				self setClientDvar("sr_customize_page", "1/" + (self.customize_maxpage + 1));
				self thread buildKnifeSkinMenu(response);
				break;
			case "theme":
				self closeMenu();
				self cleanArea();
				self openMenu("sr_customize_area");
				self.customize_area = "theme";
				self.customize_maxpage = 0;
				self setClientDvar("menuName", "Themes");
				self setClientDvar("sr_customize_page", "1/" + (self.customize_maxpage + 1));
				self thread buildThemeMenu(response);
				break;
			case "fx":
				self closeMenu();
				self cleanArea();
				self openMenu("sr_customize_area");
				self.customize_area = "fx";
				self.customize_maxpage = 0;
				self setClientDvar("menuName", "Effects");
				self setClientDvar("sr_customize_page", "1/" + (self.customize_maxpage + 1));
				self thread buildFxMenu(response);
				break;
			case "glove":
				self closeMenu();
				self cleanArea();
				self openMenu("sr_customize_area");
				self.customize_area = "glove";
				self.customize_maxpage = 0;
				self setClientDvar("menuName", "Gloves");
				self setClientDvar("sr_customize_page", "1/" + (self.customize_maxpage + 1));
				self thread buildGloveMenu(response);
				break;
		}
	}
	else if (menu == "sr_customize_area")
	{
		// build response
		switch (tkn[1])
		{
			case "next":
				if (self.customize_page < self.customize_maxpage)
				{
					self.customize_page++;
					self setClientDvar("sr_customize_page", (self.customize_page + 1) + "/" + (self.customize_maxpage + 1));
				}
				break;
			case "prev":
				if (self.customize_page > 0)
				{
					self.customize_page--;
					self setClientDvar("sr_customize_page", (self.customize_page + 1) + "/" + (self.customize_maxpage + 1));
				}
				break;

			case "1":
			case "2":
			case "3":
			case "4":
			case "5":
			case "6":
			case "7":
			case "8":
			case "9":
			case "10":
				tableItemIndex = 0;
				if (isDefined(self.customize_id[int(tkn[1]) - 1]))
					tableItemIndex = self.customize_id[int(tkn[1]) - 1];

				switch (self.customize_area)
				{
					case "weapon":
						if (isDefined(level.itemInfo[tableItemIndex]))
							self [[level.itemInfo[tableItemIndex]["func"]]](tableItemIndex, true);
						break;
					case "character":
						if (isDefined(level.characterInfo[tableItemIndex]))
							self [[level.characterInfo[tableItemIndex]["func"]]](tableItemIndex, true);
						break;
					case "knife":
						if (isDefined(level.knifeInfo[tableItemIndex]))
							self [[level.knifeInfo[tableItemIndex]["func"]]](tableItemIndex, true);
						break;
					case "spray":
						if (isDefined(level.sprayInfo[tableItemIndex]))
							self [[level.sprayInfo[tableItemIndex]["func"]]](tableItemIndex, true);
						break;
					case "knifeskin":
						if (isDefined(level.knifeSkinInfo[tableItemIndex]))
							self [[level.knifeSkinInfo[tableItemIndex]["func"]]](tableItemIndex, true);
						break;
					case "theme":
						if (isDefined(level.themeInfo[tableItemIndex]))
							self [[level.themeInfo[tableItemIndex]["func"]]](tableItemIndex, true);
						break;
					case "fx":
						if (isDefined(level.fxInfo[tableItemIndex]))
							self [[level.fxInfo[tableItemIndex]["func"]]](tableItemIndex, true);
						break;
					case "glove":
						if (isDefined(level.gloveInfo[tableItemIndex]))
							self [[level.gloveInfo[tableItemIndex]["func"]]](tableItemIndex, true);
						break;
				}
				break;
		}
		// build pages
		switch (self.customize_area)
		{
			case "weapon": self thread buildWeaponMenu(response); break;
			case "character": self thread buildCharacterMenu(response); break;
			case "knife": self thread buildKnifeMenu(response); break;
			case "spray": self thread buildSprayMenu(response); break;
			case "knifeskin": self thread buildKnifeSkinMenu(response); break;
			case "theme": self thread buildThemeMenu(response); break;
			case "fx": self thread buildFxMenu(response); break;
			case "glove": self thread buildGloveMenu(response); break;
		}
	}
}

buildButtons(arrayTemplate, startIndex, endIndex)
{
	self endon("disconnect");
	self.customize_id = [];

	// clean dvar
	for (i = 1; i < 11; i++)
	{
		self setClientDvar("sr_customize_" + i, "");
		self setClientDvar("sr_customize_id_" + i, -1);
	}

	for (i = startIndex; i != endIndex; i++)
	{
		self.customize_id[i - startIndex] = i;
		self setClientDvar("sr_customize_id_" + (i + 1 - startIndex), i);

		switch ([[arrayTemplate[i]["func"]]](i, false))
		{
			case 0:
				self setClientDvar("sr_customize_" + (i + 1 - startIndex), "^2LOCKED (" + (int(arrayTemplate[i]["rank"]) + 1) + ")");
				break;
			case 1:
				self setClientDvar("sr_customize_" + (i + 1 - startIndex), arrayTemplate[i]["name"]);
				break;
			case 2:
				self setClientDvar("sr_customize_" + (i + 1 - startIndex), "^3VIP");
				break;
		}
	}
}

cleanArea()
{
	self endon("disconnect");

	self.customize_area = "null";
	self.customize_page = 0;
	self setClientDvar("preview_theme", "0");
	self setClientDvar("sr_customize_page", self.customize_page);

	for (i = 1; i < 11; i++)
	{
		self setClientDvar("sr_customize_" + i, "");
		self setClientDvar("sr_customize_id_" + i, -1);
	}
}

initCustomizeMenu()
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

closeCustomizeMenu()
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

// --------------------------------------------------------- //
// ------------------------ WEAPONS ------------------------ //
// --------------------------------------------------------- //

buildWeaponMenu(response)
{
	self endon("disconnect");

	eye = self sr\weapons\_bullet_trace::eyepos();
    forward = anglesToForward(self getPlayerAngles()) * 45;
	right = anglesToRight(self getPlayerAngles()) * 13;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + eye;

	switch (self.customize_page)
	{
		case 0: buildButtons(level.itemInfo, 0, 10); break;
		case 1: buildButtons(level.itemInfo, 10, 20); break;
		case 2: buildButtons(level.itemInfo, 20, 30); break;
		case 3: buildButtons(level.itemInfo, 30, 40); break;
		case 4: buildButtons(level.itemInfo, 40, 47); break;
	}
}

weaponPredicate(id, isClicked)
{
	if (id <= -1)
		return false;
	else if (self braxi\_rank::isItemUnlocked(id))
	{
		if (isClicked)
		{
			self setStat(981, id);
			self setClientDvar("drui_weapon", id);

			if (isDefined(self.customize_preview))
				self.customize_preview setModel(level.itemInfo[id]["model"]);
		}
		return true;
	}
	else
		return false;
}

// ------------------------------------------------------------ //
// ------------------------ CHARACTERS ------------------------ //
// ------------------------------------------------------------ //

buildCharacterMenu(response)
{
	self endon("disconnect");

	eye = self sr\weapons\_bullet_trace::eyepos();
	up = (anglesToUp(self getPlayerAngles()) * 32) * -1;
    forward = anglesToForward(self getPlayerAngles()) * 75;
	right = anglesToRight(self getPlayerAngles()) * 25;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + up + eye;

	switch (self.customize_page)
	{
		case 0: buildButtons(level.characterInfo, 0, 10); break;
		case 1: buildButtons(level.characterInfo, 10, 20); break;
		case 2: buildButtons(level.characterInfo, 20, 30); break;
		case 3: buildButtons(level.characterInfo, 30, 34); break;
	}
}

characterPredicate(id, isClicked)
{
	if (id <= -1)
		return false;
	else if (self braxi\_rank::isCharacterUnlocked(id))
	{
		if (isClicked)
		{
			self setStat(980, id);
			self setClientDvar("drui_character", id);

			if (isDefined(self.customize_preview))
				self.customize_preview setModel(level.characterInfo[id]["model"]);
		}
		return true;
	}
	else
		return false;
}

// -------------------------------------------------------- //
// ------------------------ KNIFES ------------------------ //
// -------------------------------------------------------- //

buildKnifeMenu(response)
{
	self endon("disconnect");

	eye = self sr\weapons\_bullet_trace::eyepos();
    forward = anglesToForward(self getPlayerAngles()) * 35;
	right = anglesToRight(self getPlayerAngles()) * 13;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + eye;

	switch (self.customize_page)
	{
		case 0: buildButtons(level.knifeInfo, 0, 7); break;
	}
}

knifePredicate(id, isClicked)
{
	if (id <= -1)
		return false;
	else if (self braxi\_rank::isKnifeUnlocked(id))
	{
		if (isClicked)
		{
			self setStat(982, id);
			self setClientDvar("drui_knife", id);

			if (isDefined(self.customize_preview))
				self.customize_preview setModel(level.knifeInfo[id]["model"]);
		}
		return true;
	}
	else
		return false;
}

// -------------------------------------------------------- //
// ------------------------ SPRAYS ------------------------ //
// -------------------------------------------------------- //

buildSprayMenu(response)
{
	self endon("disconnect");

	// angles = self getPlayerAngles();
	// self setPlayerAngles((85, angles[1], 0));

	switch (self.customize_page)
	{
		case 0: buildButtons(level.sprayInfo, 0, 10); break;
		case 1: buildButtons(level.sprayInfo, 10, 20); break;
		case 2: buildButtons(level.sprayInfo, 20, 25); break;
	}
}

sprayPredicate(id, isClicked)
{
	if (id <= -1)
		return false;
	else if (self braxi\_rank::isSprayUnlocked(id))
	{
		if (isClicked)
		{
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

			// self.customize_fx = spawnFX(level.sprayInfo[id]["effect"], position, forward, up);
			// triggerFX(self.customize_fx);
		}
		return true;
	}
	else
		return false;
}

// ------------------------------------------------------------- //
// ------------------------ KNIFE SKINS ------------------------ //
// ------------------------------------------------------------- //

buildKnifeSkinMenu(response)
{
	self endon("disconnect");

	eye = self sr\weapons\_bullet_trace::eyepos();
    forward = anglesToForward(self getPlayerAngles()) * 25;
	right = anglesToRight(self getPlayerAngles()) * 7;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + eye;

	switch (self.customize_page)
	{
		case 0: buildButtons(level.knifeSkinInfo, 0, 8); break;
	}
}

knifeSkinPredicate(id, isClicked)
{
	if (id <= -1)
		return false;
	else if (self braxi\_rank::isKnifeSkinUnlocked(id) || isDefined(self.isVIP) && self.isVIP)
	{
		if (isClicked)
		{
			self setStat(983, id);
			self setClientDvar("drui_knife_skin", id);

			if (isDefined(self.customize_preview))
				self.customize_preview setModel(level.knifeSkinInfo[id]["model"]);
		}
		return true;
	}
	else
		return false;
}

// ----------------------------------------------------- //
// ------------------------ FXS ------------------------ //
// ----------------------------------------------------- //

buildFxMenu(response)
{
	self endon("disconnect");

	switch (self.customize_page)
	{
		case 0: buildButtons(level.fxInfo, 0, 6); break;
	}
}

fxPredicate(id, isClicked)
{
	self endon("customize_close");
	self endon("disconnect");

	if (id <= -1)
		return false;
	else if (isDefined(self.isVIP))
	{
		if (isClicked)
		{
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
		return true;
	}
	else
		return 2;
}

// -------------------------------------------------------- //
// ------------------------ THEMES ------------------------ //
// -------------------------------------------------------- //

buildThemeMenu(response)
{
	self endon("disconnect");
	self setClientDvar("preview_theme", "1");

	switch (self.customize_page)
	{
		case 0: buildButtons(level.themeInfo, 0, 7); break;
	}
}

themePredicate(id, isClicked)
{
	if (id <= -1)
		return false;
	else
	{
		if (isClicked)
		{
			self setStat(984, id);
		}
		return true;
	}
}

// -------------------------------------------------------- //
// ------------------------ GLOVES ------------------------ //
// -------------------------------------------------------- //

buildGloveMenu(response)
{
	self endon("disconnect");

	eye = self sr\weapons\_bullet_trace::eyepos();
	up = anglesToUp(self getPlayerAngles()) * 7;
    forward = anglesToForward(self getPlayerAngles()) * 45;
	right = anglesToRight(self getPlayerAngles()) * 13;

    if (isDefined(self.customize_preview))
        self.customize_preview.origin = forward + right + up + eye;

	switch (self.customize_page)
	{
		case 0: buildButtons(level.gloveInfo, 0, 10); break;
	}
}

glovePredicate(id, isClicked)
{
	if (id <= -1)
		return false;
	else if (self braxi\_rank::isGloveUnlocked(id))
	{
		if (isClicked)
		{
			self setStat(985, id);
			self setClientDvar("drui_glove", id);

			if (isDefined(self.customize_preview))
				self.customize_preview setModel(level.gloveInfo[id]["model"]);
		}
		return true;
	}
	else
		return false;
}
