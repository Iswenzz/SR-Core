#include sr\sys\_events;
#include sr\utils\_common;
#include sr\game\_perks;

main()
{
	level.defragVisuals = [];
	level.defragWeapons = [];
	level.defragStartWeapons = [];

	addWeapon("rl", "gl_ak47_mp");
	addWeapon("pl", "gl_g3_mp");

	addPerk("haste", undefined, ::haste);

	defaultWeapons();

	thread visuals();
	thread triggersSection();
	thread triggersWeapon();
	thread triggersPerk();

	event("spawn", ::onSpawn);
}

onSpawn()
{
	self.defragCooldowns = [];
}

defaultWeapons()
{
	level.defragStartWeapons = getArrayKeys(level.defragWeapons);
}

addWeapon(name, item)
{
	level.defragWeapons[name] = item;
}

visuals()
{
	while (true)
	{
		players = getPlayingPlayers();

		for (i = 0; i < level.defragVisuals.size; i++)
		{
			level.defragVisuals[i] hide();

			for (j = 0; j < players.size; j++)
			{
				if (isDefined(players[j].sr_mode) && players[j].sr_mode == "Defrag")
					level.defragVisuals[i] showToPlayer(players[j]);
			}
		}
		wait 1;
	}
}

visualLoop(model)
{
	if (!isDefined(model))
		return;

	self.preview = spawn("script_model", self.origin - (0, 0, 30));
	self.preview setModel(model);

	level.defragVisuals[level.defragVisuals.size] = self.preview;
	wait 0.05;
	playLoopedFX(level.fx["pickup"], 3, self.preview.origin  - (0, 0, 30));

	while (true)
	{
		self.preview rotateYaw(360, 3);
		wait 3;
	}
}

triggersSection()
{
	waitMapLoad();

	triggers = getEntArray("defrag_section", "targetname");
	for (i = 0; i < triggers.size; i++)
		triggers[i] thread triggerSectionLoop();
}

triggerSectionLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player thread playerSection(self);
	}
}

playerSection(trigger)
{
	self thread [[trigger.callback]]();
	self removeCooldown(trigger);
}

triggersWeapon()
{
	waitMapLoad();

	triggers = getEntArray("defrag_weapon", "targetname");
	for (i = 0; i < triggers.size; i++)
	{
		trigger = triggers[i];

		weapon = getWeaponModel(level.defragWeapons[trigger.weapon]);
		trigger thread visualLoop(weapon);
		trigger thread triggerWeaponLoop();
	}
}

triggerWeaponLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player thread playerWeapon(self);
	}
}

playerWeapon(trigger)
{
	weapon = level.defragWeapons[trigger.weapon];

	self giveWeapon(weapon);
	self switchToWeapon(weapon);
	self setWeaponAmmoClip(weapon, trigger.ammo);
	self removeCooldown(trigger);
}

triggersPerk()
{
	waitMapLoad();

	triggers = getEntArray("defrag_perk", "targetname");
	for (i = 0; i < triggers.size; i++)
	{
		trigger = triggers[i];

		perk = level.perks[trigger.perk];
		trigger thread visualLoop(perk.model);
		trigger thread triggerPerkLoop();
	}
}

triggerPerkLoop()
{
	while (true)
	{
		self waittill("trigger", player);

		if (!player canTrigger(self))
			continue;

		player playerPerk(self);
	}
}

playerPerk(trigger)
{
	self playerSetPerk(trigger.perk);
	self removeCooldown(trigger);
}

canTrigger(trigger)
{
	if (self.sr_mode != "Defrag" || isDefined(self.defragCooldowns[trigger.id]))
		return false;
	self.defragCooldowns[trigger.id] = true;
	return true;
}

removeCooldown(trigger)
{
	wait 3;

	self.defragCooldowns[trigger.id] = undefined;
}

haste()
{
	self.moveSpeedScale = sr\api\_map::getMoveSpeedScale(1.0);
	self setMoveSpeedScale(self.moveSpeedScale);
}
