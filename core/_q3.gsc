#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	level.q3Visuals = [];
	level.q3Weapons = [];
	level.q3StartWeapons = [];

	addWeapon("rl", "gl_ak47_mp");
	addWeapon("pl", "gl_g3_mp");

	sr\core\_perks::addPerk("haste", "Haste", undefined, ::haste);

	defaultWeapons();
	thread visuals();

	event("map", ::triggers);
	event("spawn", ::onSpawn);
}

triggers()
{
	sections = getEntArray("q3_section", "targetname");
	for (i = 0; i < sections.size; i++)
		sections[i] thread triggerSection();

	weapons = getEntArray("q3_weapon", "targetname");
	for (i = 0; i < weapons.size; i++)
		weapons[i] thread triggerWeapon();

	perks = getEntArray("q3_perk", "targetname");
	for (i = 0; i < perks.size; i++)
		perks[i] thread triggerPerk();
}

onSpawn()
{
	self.q3Cooldowns = [];
}

defaultWeapons()
{
	level.q3StartWeapons[level.q3StartWeapons.size] = "rl";
	level.q3StartWeapons[level.q3StartWeapons.size] = "pl";
}

addWeapon(name, item)
{
	level.q3Weapons[name] = item;
}

visuals()
{
	while (true)
	{
		players = getAllPlayers();

		for (i = 0; i < level.q3Visuals.size; i++)
		{
			level.q3Visuals[i] hide();

			for (j = 0; j < players.size; j++)
			{
				player = IfUndef(players[j] getSpectatorClient(), players[j]);
				if (player isQ3())
					level.q3Visuals[i] showToPlayer(players[j]);
			}
		}
		wait 1;
	}
}

visualLoop(model)
{
	self.preview = spawn("script_model", self.origin - (0, 0, 30));
	if (isDefined(model))
		self.preview setModel(model);

	level.q3Visuals[level.q3Visuals.size] = self.preview;
	wait 0.05;
	playLoopedFX(level.gfx["pickup"], 3, self.preview.origin  - (0, 0, 30));

	while (true)
	{
		self.preview rotateYaw(360, 3);
		wait 3;
	}
}

triggerSection()
{
	self thread triggerSectionLoop();
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

triggerWeapon()
{
	weapon = getWeaponModel(level.q3Weapons[self.weapon]);
	self thread visualLoop(weapon);
	self thread triggerWeaponLoop();
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
	weapon = level.q3Weapons[trigger.weapon];

	self giveWeapon(weapon);
	self switchToWeapon(weapon);

	if (trigger.ammo > 0)
		self setWeaponAmmoStock(weapon, trigger.ammo);

	self removeCooldown(trigger);
}

triggerPerk()
{
	perk = level.perks[self.perk];
	self thread visualLoop(perk.model);
	self thread triggerPerkLoop();
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
	self sr\core\_perks::playerSetPerk(trigger.perk);

	if (trigger.time > 0)
	{
		wait trigger.time;
		self sr\core\_perks::playerRemovePerk(trigger.perk);
	}

	self removeCooldown(trigger);
}

canTrigger(trigger)
{
	if (self.sr_mode != "Q3" || self.sr_mode != "Q3CPM" || self.sr_mode != "Q3CPMW" || isDefined(self.q3Cooldowns[trigger.id]))
		return false;
	self.q3Cooldowns[trigger.id] = true;
	return true;
}

removeCooldown(trigger)
{
	wait 3;

	self.q3Cooldowns[trigger.id] = undefined;
}

haste()
{
	self.moveSpeedScale = sr\api\_map::getMoveSpeedScale(1.0);
	self setMoveSpeedScale(self.moveSpeedScale);
}
