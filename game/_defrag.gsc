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

	addPerk("haste", "Haste", undefined, ::haste);

	defaultWeapons();
	thread visuals();

	event("map", ::triggers);
	event("spawn", ::onSpawn);
}

triggers()
{
	sections = getEntArray("defrag_section", "targetname");
	for (i = 0; i < sections.size; i++)
		sections[i] thread triggerSection();

	weapons = getEntArray("defrag_weapon", "targetname");
	for (i = 0; i < weapons.size; i++)
		weapons[i] thread triggerWeapon();

	perks = getEntArray("defrag_perk", "targetname");
	for (i = 0; i < perks.size; i++)
		perks[i] thread triggerPerk();
}

onSpawn()
{
	self.defragCooldowns = [];

	self endon("spawned");
	self endon("disconnect");
	self endon("death");

	if (!self isDefrag())
		return;

	self.bhopPrevAirVelocity = (0, 0, 0);
	self.bhopPrevOnGround = true;

	while (true)
	{
		if (!isDefined(self.jumpHeight) || !isDefined(self.gravity))
		{
			wait 0.05;
			continue;
		}

		self.bhopAirVelocity = self getVelocity();
		self.bhopOnGround = self isOnGround();
		self.bhopHeight = sqrt((self.jumpHeight * 2) * self.gravity);

		if (self.bhopOnGround && !self.bhopPrevOnGround && self jumpButtonPressed() && self getStance() == "stand")
		{
			velocity = self.bhopPrevAirVelocity - self.bhopAirVelocity;

			flags = self PmFlags();
			flags &= 4294966911;
  			flags |= 16384;
			self SetPmFlags(flags);
			self SetPmTime(0);

			self setVelocity((self.bhopAirVelocity[0], self.bhopAirVelocity[1], 0)
				+ (velocity[0], velocity[1], self.bhopHeight));
		}
		wait 0.05;

		self.bhopPrevAirVelocity = self.bhopAirVelocity;
		self.bhopPrevOnGround = self.bhopOnGround;
	}
}

defaultWeapons()
{
	level.defragStartWeapons[level.defragStartWeapons.size] = "rl";
	level.defragStartWeapons[level.defragStartWeapons.size] = "pl";
}

addWeapon(name, item)
{
	level.defragWeapons[name] = item;
}

visuals()
{
	while (true)
	{
		players = getAllPlayers();

		for (i = 0; i < level.defragVisuals.size; i++)
		{
			level.defragVisuals[i] hide();

			for (j = 0; j < players.size; j++)
			{
				player = IfUndef(players[j] getSpectatorClient(), players[j]);
				if (player isDefrag())
					level.defragVisuals[i] showToPlayer(players[j]);
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

	level.defragVisuals[level.defragVisuals.size] = self.preview;
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
	weapon = getWeaponModel(level.defragWeapons[self.weapon]);
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
	weapon = level.defragWeapons[trigger.weapon];

	self giveWeapon(weapon);
	self switchToWeapon(weapon);

	if (trigger.ammo > 0)
		self setWeaponAmmoClip(weapon, trigger.ammo);

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
	self playerSetPerk(trigger.perk);

	if (trigger.time > 0)
	{
		wait trigger.time;
		self playerRemovePerk(trigger.perk);
	}

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
