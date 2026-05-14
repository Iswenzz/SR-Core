main()
{
	precacheCharacter();
	precacheFx();
	precacheGlove();
	precacheKnife();
	precacheKnifeSkin();
	precacheSpray();
	precacheWeapon();
}

precacheCharacter()
{
	level.assets["character"] = [];
	tableName = "mp/characterTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["character"][i]["id"] = i;
		level.assets["character"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["character"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["character"][i]["model"] = tableLookup(tableName, 0, i, 3);
		level.assets["character"][i]["handsModel"] = tableLookup(tableName, 0, i, 4);
		level.assets["character"][i]["name"] = tableLookup(tableName, 0, i, 5);
		level.assets["character"][i]["callback"] = sr\menus\_customize::pickCharacter;
		level.assets["character"][i]["unlock"] = ::isCharacterUnlocked;

		precacheModel(level.assets["character"][i]["model"]);
		precacheModel(level.assets["character"][i]["handsModel"]);
	}
}

precacheFx()
{
	level.assets["fx"] = [];
	tableName = "mp/fxTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["fx"][i]["id"] = i;
		level.assets["fx"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["fx"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["fx"][i]["name"] = tableLookup(tableName, 0, i, 3);
		level.assets["fx"][i]["callback"] = sr\menus\_customize::pickFx;
		level.assets["fx"][i]["unlock"] = ::isFxUnlocked;
	}
}

precacheGlove()
{
	level.assets["glove"] = [];
	tableName = "mp/gloveTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["glove"][i]["id"] = i;
		level.assets["glove"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["glove"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["glove"][i]["model"] = tableLookup(tableName, 0, i, 3);
		level.assets["glove"][i]["name"] = tableLookup(tableName, 0, i, 4);
		level.assets["glove"][i]["callback"] = sr\menus\_customize::pickGlove;
		level.assets["glove"][i]["unlock"] = ::isGloveUnlocked;

		precacheModel(level.assets["glove"][i]["model"]);
	}
}

precacheKnife()
{
	level.assets["knife"] = [];
	tableName = "mp/knifeTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["knife"][i]["id"] = i;
		level.assets["knife"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["knife"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["knife"][i]["item"] = (tableLookup(tableName, 0, i, 3) + "_mp");
		level.assets["knife"][i]["name"] = tableLookup(tableName, 0, i, 4);
		level.assets["knife"][i]["model"] = tableLookup(tableName, 0, i, 5);
		level.assets["knife"][i]["callback"] = sr\menus\_customize::pickKnife;
		level.assets["knife"][i]["unlock"] = ::isKnifeUnlocked;

		precacheItem(level.assets["knife"][i]["item"]);
		precacheModel(level.assets["knife"][i]["model"]);
	}
}

precacheKnifeSkin()
{
	level.assets["knife_skin"] = [];
	tableName = "mp/knifeSkinTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["knife_skin"][i]["id"] = i;
		level.assets["knife_skin"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["knife_skin"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["knife_skin"][i]["name"] = tableLookup(tableName, 0, i, 3);
		level.assets["knife_skin"][i]["model"] = tableLookup(tableName, 0, i, 4);
		level.assets["knife_skin"][i]["callback"] = sr\menus\_customize::pickKnifeSkin;
		level.assets["knife_skin"][i]["unlock"] = ::isKnifeSkinUnlocked;

		precacheModel(level.assets["knife_skin"][i]["model"]);
	}
}

precacheSpray()
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
		level.assets["spray"][i]["callback"] = sr\menus\_customize::pickSpray;
		level.assets["spray"][i]["unlock"] = ::isSprayUnlocked;

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

precacheWeapon()
{
	level.assets["weapon"] = [];
	tableName = "mp/itemTable.csv";

	for (i = 0; !IsNullOrEmpty(tableLookup(tableName, 0, i, 0)); i++)
	{
		level.assets["weapon"][i]["id"] = i;
		level.assets["weapon"][i]["rank"] = (int(tableLookup(tableName, 0, i, 1)) - 1);
		level.assets["weapon"][i]["prestige"] = int(tableLookup(tableName, 0, i, 2));
		level.assets["weapon"][i]["item"] = (tableLookup(tableName, 0, i, 3) + "_mp");
		level.assets["weapon"][i]["name"] = tableLookup(tableName, 0, i, 4);
		level.assets["weapon"][i]["model"] = getWeaponModel(level.assets["weapon"][i]["item"]);
		level.assets["weapon"][i]["callback"] = sr\menus\_customize::pickWeapon;
		level.assets["weapon"][i]["unlock"] = ::isWeaponUnlocked;

		precacheItem(level.assets["weapon"][i]["item"]);
		precacheModel(level.assets["weapon"][i]["model"]);
	}
}

getCustomizeWeapon()
{
	num = self getStat(981);
	if (self isWeaponUnlocked(num))
		return level.assets["weapon"][num];
	return level.assets["weapon"][0];
}

getCustomizeCharacter()
{
	num = self getStat(980);
	if (self isCharacterUnlocked(num))
		return level.assets["character"][num];
	return level.assets["character"][0];
}

getCustomizeKnife()
{
	num = self getStat(982);
	if (self isKnifeUnlocked(num))
		return level.assets["knife"][num];
	return level.assets["knife"][0];
}

getCustomizeKnifeSkin()
{
	num = self getStat(983);
	if (self isKnifeSkinUnlocked(num))
		return level.assets["knife_skin"][num];
	return level.assets["knife_skin"][0];
}

getCustomizeSpray()
{
	num = self getStat(979);
	if (self isSprayUnlocked(num))
		return level.assets["spray"][num];
	return level.assets["spray"][0];
}

getCustomizeGlove()
{
	num = self getStat(985);
	if (self isGloveUnlocked(num))
		return level.assets["glove"][num];
	return level.assets["glove"][0];
}

getCustomizeFx()
{
	num = self getStat(986);
	if (self isFxUnlocked(num))
		return level.assets["fx"][num];
	return level.assets["fx"][0];
}

isCharacterUnlocked(num)
{
	return self isUnlocked(level.assets["character"], num);
}

isWeaponUnlocked(num)
{
	return self isUnlocked(level.assets["weapon"], num);
}

isSprayUnlocked(num)
{
	return self isUnlocked(level.assets["spray"], num);
}

isKnifeSkinUnlocked(num)
{
	return self isUnlocked(level.assets["knife_skin"], num, level.special_roles["vip"]);
}

isKnifeUnlocked(num)
{
	return self isUnlocked(level.assets["knife"], num);
}

isGloveUnlocked(num)
{
	return self isUnlocked(level.assets["glove"], num);
}

isFxUnlocked(num)
{
	return self isUnlocked(level.assets["fx"], num, level.special_roles["vip"]);
}

isUnlocked(assets, num, vip)
{
	if (num > assets.size || num <= -1)
		return 0;
	if (isDefined(vip) && self sr\sys\_admins::isVIP() >= vip)
		return vip;
	if (self.pers["prestige"] < assets[num]["prestige"])
		return 0;
	if (self.pers["rank"] < assets[num]["rank"] && self.pers["prestige"] <= assets[num]["prestige"])
		return 0;
	return 1;
}
